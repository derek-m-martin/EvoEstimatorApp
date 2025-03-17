//
//  PickerViewTemplate.swift
//  EvoEstimator
//
//  Created by Derek Martin on 2025-01-08.
//

import Foundation
import SwiftUI

struct PickerView: UIViewRepresentable {
    var data: [[String]]
    @Binding var selections: [Int]
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: UIViewRepresentableContext<PickerView>) -> UIPickerView {
        let picker = UIPickerView(frame: .zero)
        picker.backgroundColor = .lightBlue // set a light blue background
        picker.dataSource = context.coordinator
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIView(_ view: UIPickerView, context: UIViewRepresentableContext<PickerView>) {
        for i in 0..<self.selections.count {
            view.selectRow(self.selections[i], inComponent: i, animated: true)
        }
        context.coordinator.parent = self // update coordinator with latest data
    }
    
    class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
        var parent: PickerView
        init(_ pickerView: PickerView) {
            self.parent = pickerView
        }
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return parent.data.count
        }
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return parent.data[component].count
        }
        func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
            let label = UILabel()
            label.text = parent.data[component][row]
            label.textAlignment = .center
            label.textColor = .white
            label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
            return label
        }
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            parent.selections[component] = row
        }
    }
}
