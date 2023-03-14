//
//  DecimalNumPad.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

public struct DecimalNumPad {
    
    // MARK: - parameters
    
    internal var sValue: String
    internal let precision: Int
    internal let formatter: NumberFormatter
    internal let range: ClosedRange<Decimal>

    public init(_ dvalue: Decimal = 0,
                precision: Int = 2,
                range: ClosedRange<Decimal> = 0 ... NSDecimalNumber.maximum.decimalValue)
    {
        formatter = {
            let nf = NumberFormatter()
            nf.locale = Locale.current
            nf.numberStyle = .decimal
            nf.usesGroupingSeparator = false
            nf.isLenient = true
            nf.minimumFractionDigits = 0
            nf.maximumFractionDigits = precision
            nf.generatesDecimalNumbers = true
            return nf
        }()

        let clampedValue = dvalue.clamped(to: range)

        sValue = formatter.string(from: NSDecimalNumber(decimal: clampedValue)) ?? "0"
        self.precision = precision
        self.range = range
    }
    
    // MARK: - Public Properties

    public var stringValue: String {
        sValue
    }

    public var decimalValue: Decimal? {
        toDecimal(sValue)
    }

    // MARK: - Internal Properties/Helpers
    
    internal func toDecimal(_ str: String) -> Decimal? {
        formatter.number(from: str)?.decimalValue
    }

    internal var currentPrecision: Int {
        guard let di = decimalPointIndex else { return 0 }
        return sValue.distance(from: di, to: sValue.endIndex) - 1
    }

    internal var decimalPointIndex: String.Index? {
        sValue.firstIndex(of: ".")
    }

    // MARK: - Public Actions

    public mutating func clearAction() {
        sValue = "0"
    }

    public mutating func digitAction(_ digit: Int) {
        guard (0 ... 9).contains(digit) else { return }
        let strNum = "\(digit)"
        if sValue == "0" {
            sValue = strNum
        } else {
            let cp = currentPrecision
            if cp > 0, cp == precision { return } // ignore additional input

            let nuValue = sValue.appending(strNum)

            guard let nuDValue = toDecimal(nuValue),
                  range.contains(nuDValue) else { return }

            sValue = nuValue
        }
    }

    public mutating func backspaceAction() {
        if sValue.count <= 1 {
            clearAction()
        } else {
            sValue.removeLast()
        }
    }

    public mutating func decimalPointAction() {
        guard decimalPointIndex == nil else { return }
        sValue.append(".")
    }
}
