//
//  PickerViewTemplate.swift
//  EvoEstimator
//
//  Created by Derek Martin on 2025-01-08.
//


// CREDIT GIVEN TO THE FOLLOWING: https://stackoverflow.com/questions/56567539/multi-component-picker-uipickerview-in-swiftui

import Foundation
import SwiftUI

struct PickerView: UIViewRepresentable {
    var data: [[String]]
    @Binding var selections: [Int]
    
    //makeCoordinator()
    func makeCoordinator() -> PickerView.Coordinator {
        Coordinator(self)
    }

    //makeUIView(context:)
    func makeUIView(context: UIViewRepresentableContext<PickerView>) -> UIPickerView {
        let picker = UIPickerView(frame: .zero)
        picker.backgroundColor = .lightBlue
        picker.dataSource = context.coordinator
        picker.delegate = context.coordinator

        return picker
    }

    //updateUIView(_:context:)
    func updateUIView(_ view: UIPickerView, context: UIViewRepresentableContext<PickerView>) {
        for i in 0...(self.selections.count - 1) {
            view.selectRow(self.selections[i], inComponent: i, animated: true)
        }
        context.coordinator.parent = self // fix
    }
    
    class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
        var parent: PickerView

        //init(_:)
        init(_ pickerView: PickerView) {
            self.parent = pickerView
        }

        //numberOfComponents(in:)
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return self.parent.data.count
        }

        //pickerView(_:numberOfRowsInComponent:)
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return self.parent.data[component].count
        }

        //pickerView(_:viewForRow:forComponent:reusing:)
        func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
            let label = UILabel()
            label.text = self.parent.data[component][row]
            label.textAlignment = .center
            label.textColor = .white
            label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
            return label
        }

        //pickerView(_:didSelectRow:inComponent:)
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            self.parent.selections[component] = row
        }
    }
}
