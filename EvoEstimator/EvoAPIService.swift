//
//  EvoAPIService.swift
//  EvoEstimator
//
//  Created by Derek Martin on 2025-03-14.
//

import Foundation
import CoreLocation

// decoding evo car info from json
struct EvoCar: Decodable {
    let id: String
    let latitude: Double
    let longitude: Double
    let fuelLevel: Int?
    let model: String
    let plate: String
    
    enum CodingKeys: String, CodingKey {
        case description
        case location
        case status
    }
    
    enum DescriptionKeys: String, CodingKey {
        case id
        case model
        case plate
    }
    
    enum LocationKeys: String, CodingKey {
        case position
    }
    
    enum PositionKeys: String, CodingKey {
        case lat
        case lon
    }
    
    enum StatusKeys: String, CodingKey {
        case energyLevel
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // grab car details
        let descriptionContainer = try container.nestedContainer(keyedBy: DescriptionKeys.self, forKey: .description)
        id = try descriptionContainer.decode(String.self, forKey: .id)
        model = try descriptionContainer.decode(String.self, forKey: .model)
        plate = try descriptionContainer.decode(String.self, forKey: .plate)
        
        // get location coords
        let locationContainer = try container.nestedContainer(keyedBy: LocationKeys.self, forKey: .location)
        let positionContainer = try locationContainer.nestedContainer(keyedBy: PositionKeys.self, forKey: .position)
        latitude = try positionContainer.decode(Double.self, forKey: .lat)
        longitude = try positionContainer.decode(Double.self, forKey: .lon)
        
        // fuel level stuff
        let statusContainer = try container.nestedContainer(keyedBy: StatusKeys.self, forKey: .status)
        fuelLevel = try statusContainer.decode(Int.self, forKey: .energyLevel)
    }
}

class EvoAPIService {
    
    static let shared = EvoAPIService()
    
    private init() {} // singleton for api calls

    private let baseUrl = "https://java-us01.vulog.com/apiv5"
    private let cityId = "fc256982-77d1-455c-8ab0-7862c170db6a"
    private let apiKey = "f52e5e56-c7db-4af0-acf5-0d8b13ac4bfc"
    
    // calculate haversine distance between two points
    private func distance(userLat: Double, userLon: Double, carLat: Double, carLon: Double) -> Double {
        let R = 6371.0 // earth's radius in km
        
        let lat1 = userLat * .pi / 180
        let lat2 = carLat * .pi / 180
        let deltaLat = (carLat - userLat) * .pi / 180
        let deltaLon = (carLon - userLon) * .pi / 180
        
        let a = sin(deltaLat/2) * sin(deltaLat/2) +
                cos(lat1) * cos(lat2) *
                sin(deltaLon/2) * sin(deltaLon/2)
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        
        return R * c // return km distance
    }
    
    // fetch evo cars using a dynamic token then filter for nearby ones
    func fetchEvoCarsWithDynamicToken(latitude: Double, longitude: Double, completion: @escaping ([EvoCar]?) -> Void) {
        // get access token
        guard let tokenUrl = URL(string: "https://java-us01.vulog.com/auth/realms/BCAA-CAYVR/protocol/openid-connect/token") else {
            print("invalid token url")
            completion(nil)
            return
        }
        
        var tokenRequest = URLRequest(url: tokenUrl)
        tokenRequest.httpMethod = "POST"
        tokenRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let tokenParams = [
            "scope": "",
            "client_id": "BCAA-CAYVR_anon",
            "client_secret": "dbe490f4-2f4a-4bef-8c0b-52c0ecedb6c8",
            "grant_type": "client_credentials"
        ]
        let tokenBody = tokenParams.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        tokenRequest.httpBody = tokenBody.data(using: .utf8)
        
        URLSession.shared.dataTask(with: tokenRequest) { data, response, error in
            if let error = error {
                print("token api error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("no data from token api")
                completion(nil)
                return
            }
            
            do {
                if let tokenJson = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let accessToken = tokenJson["access_token"] as? String {
                    
                    print("got token: \(accessToken)")
                    
                    // now call vehicles endpoint with token
                    let vehiclesUrlString = "\(self.baseUrl)/availableVehicles/\(self.cityId)"
                    guard let vehiclesUrl = URL(string: vehiclesUrlString) else {
                        print("invalid vehicles url")
                        completion(nil)
                        return
                    }
                    
                    var vehiclesRequest = URLRequest(url: vehiclesUrl)
                    vehiclesRequest.httpMethod = "GET"
                    vehiclesRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                    vehiclesRequest.setValue(self.apiKey, forHTTPHeaderField: "x-api-key")
                    vehiclesRequest.setValue("application/json", forHTTPHeaderField: "Accept")
                    vehiclesRequest.setValue("\(latitude)", forHTTPHeaderField: "user-lat")
                    vehiclesRequest.setValue("\(longitude)", forHTTPHeaderField: "user-lon")
                    
                    URLSession.shared.dataTask(with: vehiclesRequest) { data, response, error in
                        if let error = error {
                            print("vehicles api error: \(error.localizedDescription)")
                            completion(nil)
                            return
                        }
                        
                        guard let data = data else {
                            print("no data from vehicles api")
                            completion(nil)
                            return
                        }
                        
                        // print raw response and filter for closeby rides
                        if let rawResponse = String(data: data, encoding: .utf8) {
                            do {
                                if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                                    let nearbyVehicles = jsonArray.filter { vehicle in
                                        if let location = vehicle["location"] as? [String: Any],
                                           let position = location["position"] as? [String: Any],
                                           let carLat = position["lat"] as? Double,
                                           let carLon = position["lon"] as? Double {
                                            
                                            let dist = self.distance(userLat: latitude, userLon: longitude, carLat: carLat, carLon: carLon)
                                            return dist <= 1.0
                                        }
                                        return false
                                    }
                                    
                                    print("cars within 1km:")
                                    if let prettyPrintedData = try? JSONSerialization.data(withJSONObject: nearbyVehicles, options: .prettyPrinted),
                                       let prettyPrintedString = String(data: prettyPrintedData, encoding: .utf8) {
                                        print(prettyPrintedString)
                                    }
                                }
                            } catch {
                                print("error filtering nearby vehicles: \(error)")
                            }
                        }
                        
                        do {
                            let decoder = JSONDecoder()
                            let allCars = try decoder.decode([EvoCar].self, from: data)
                            print("decoded cars: \(allCars.count)")
                            
                            // filter for cars within 1km radius
                            let nearbyCars = allCars.filter { car in
                                let dist = self.distance(userLat: latitude, userLon: longitude, carLat: car.latitude, carLon: car.longitude)
                                print("car at (\(car.latitude), \(car.longitude)) is \(dist)km away")
                                return dist <= 1.0
                            }
                            
                            print("found \(nearbyCars.count) nearby cars")
                            for car in nearbyCars {
                                print("nearby: \(car.model) (\(car.plate)) at (\(car.latitude), \(car.longitude))")
                            }
                            
                            completion(nearbyCars)
                        } catch {
                            print("decoding error: \(error)")
                            if let decodingError = error as? DecodingError {
                                switch decodingError {
                                case .keyNotFound(let key, let context):
                                    print("missing key \(key): \(context.debugDescription)")
                                case .valueNotFound(let type, let context):
                                    print("missing value for \(type): \(context.debugDescription)")
                                case .typeMismatch(let type, let context):
                                    print("type mismatch for \(type): \(context.debugDescription)")
                                case .dataCorrupted(let context):
                                    print("data corrupted: \(context.debugDescription)")
                                @unknown default:
                                    print("unknown decoding error")
                                }
                            }
                            completion(nil)
                        }
                    }.resume()
                    
                } else {
                    print("token not found")
                    completion(nil)
                }
            } catch {
                print("error parsing token json: \(error.localizedDescription)")
                completion(nil)
            }
        }.resume()
    }
}