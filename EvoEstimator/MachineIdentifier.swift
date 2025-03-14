import Foundation

// provides device model identification
struct MachineIdentifier {
    // maps device identifiers to marketing names
    private static let modelMap: [String: String] = [
        // iPhone 12 Series
        "iPhone13,1": "iPhone 12 Mini",
        "iPhone13,2": "iPhone 12",
        "iPhone13,3": "iPhone 12 Pro",
        "iPhone13,4": "iPhone 12 Pro Max",
        
        // iPhone 13 Series
        "iPhone14,4": "iPhone 13 Mini",
        "iPhone14,5": "iPhone 13",
        "iPhone14,2": "iPhone 13 Pro",
        "iPhone14,3": "iPhone 13 Pro Max",
        
        // iPhone 14 Series
        "iPhone14,7": "iPhone 14",
        "iPhone14,8": "iPhone 14 Plus",
        "iPhone15,2": "iPhone 14 Pro",
        "iPhone15,3": "iPhone 14 Pro Max",
        
        // iPhone 15 Series
        "iPhone15,4": "iPhone 15",
        "iPhone15,5": "iPhone 15 Plus",
        "iPhone16,1": "iPhone 15 Pro",
        "iPhone16,2": "iPhone 15 Pro Max",
        
        // iPhone 16 Series
        "iPhone17,1": "iPhone 16",
        "iPhone17,2": "iPhone 16 Plus",
        "iPhone17,3": "iPhone 16 Pro",
        "iPhone17,4": "iPhone 16 Pro Max"
    ]
    
    // gets the marketing name for the current device
    static func model() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String(validatingUTF8: ptr)
            }
        }
        
        if let modelCode = modelCode {
            return modelMap[modelCode] ?? "iPhone"
        }
        
        return "iPhone"
    }
} 