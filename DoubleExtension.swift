//
//  DoubleExtension.swift
//  Seismometer
//
//  Created by fasih zaidi on 23/07/2024.
//

extension Double {
    func dscribeAsFixedLengthString(integerDigits: Int = 2, fractionDigits: Int = 2) -> String {
        self.formatted(.number
            .sign(strategy: .always())
            .precision(.integerAndFractionLength(integer: integerDigits, fraction: fractionDigits))
        )
    }
}

