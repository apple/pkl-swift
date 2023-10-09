// ===----------------------------------------------------------------------===//
// Copyright © 2023 Apple Inc. and the Pkl project authors. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//	https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// ===----------------------------------------------------------------------===//

import Foundation
import MessagePack

/// DataSize is the Swift representation of Pkl's `pkl.DataSize`.
public struct DataSize: Hashable {
    /// The value of this ``DataSize`` in the unit set in ``unit``.
    let value: Float64

    /// The unit of this ``DataSize``, for example, byte, megabyte, and terabyte.
    let unit: DataSizeUnit

    public init(_ value: some BinaryInteger, unit: DataSizeUnit) {
        self.value = Float64(value)
        self.unit = unit
    }

    public init(_ value: some BinaryFloatingPoint, unit: DataSizeUnit) {
        self.value = Float64(value)
        self.unit = unit
    }
}

extension DataSize: PklSerializableValueUnitType {
    public typealias UnitType = DataSizeUnit

    public static let messageTag: PklValueType = .dataSize
}

extension DataSize: CustomStringConvertible {
    public var description: String {
        "\(format(fractional: self.value)!).\(self.unit)"
    }
}

/// Convenient constructor functions
extension DataSize {
    public static func bytes(_ value: some BinaryInteger) -> Self {
        Self(value, unit: .bytes)
    }

    public static func bytes(_ value: some BinaryFloatingPoint) -> Self {
        Self(value, unit: .bytes)
    }

    public static func kilobytes(_ value: some BinaryInteger) -> Self {
        Self(value, unit: .kilobytes)
    }

    public static func kilobytes(_ value: some BinaryFloatingPoint) -> Self {
        Self(value, unit: .kilobytes)
    }

    public static func kibibytes(_ value: some BinaryInteger) -> Self {
        Self(value, unit: .kibibytes)
    }

    public static func kibibytes(_ value: some BinaryFloatingPoint) -> Self {
        Self(value, unit: .kibibytes)
    }

    public static func megabytes(_ value: some BinaryInteger) -> Self {
        Self(value, unit: .megabytes)
    }

    public static func megabytes(_ value: some BinaryFloatingPoint) -> Self {
        Self(value, unit: .megabytes)
    }

    public static func mebibytes(_ value: some BinaryInteger) -> Self {
        Self(value, unit: .mebibytes)
    }

    public static func mebibytes(_ value: some BinaryFloatingPoint) -> Self {
        Self(value, unit: .mebibytes)
    }

    public static func gigabytes(_ value: some BinaryInteger) -> Self {
        Self(value, unit: .gigabytes)
    }

    public static func gigabytes(_ value: some BinaryFloatingPoint) -> Self {
        Self(value, unit: .gigabytes)
    }

    public static func gibibytes(_ value: some BinaryInteger) -> Self {
        Self(value, unit: .gibibytes)
    }

    public static func gibibytes(_ value: some BinaryFloatingPoint) -> Self {
        Self(value, unit: .gibibytes)
    }

    public static func terabytes(_ value: some BinaryInteger) -> Self {
        Self(value, unit: .terabytes)
    }

    public static func terabytes(_ value: some BinaryFloatingPoint) -> Self {
        Self(value, unit: .terabytes)
    }

    public static func tebibytes(_ value: some BinaryInteger) -> Self {
        Self(value, unit: .tebibytes)
    }

    public static func tebibytes(_ value: some BinaryFloatingPoint) -> Self {
        Self(value, unit: .tebibytes)
    }

    public static func petabytes(_ value: some BinaryInteger) -> Self {
        Self(value, unit: .petabytes)
    }

    public static func petabytes(_ value: some BinaryFloatingPoint) -> Self {
        Self(value, unit: .petabytes)
    }

    public static func pebibytes(_ value: some BinaryInteger) -> Self {
        Self(value, unit: .pebibytes)
    }

    public static func pebibytes(_ value: some BinaryFloatingPoint) -> Self {
        Self(value, unit: .pebibytes)
    }
}

extension DataSize {
    /// Converts this ``DataSize`` to the specified unit.
    public func toUnit(_ unit: DataSizeUnit) -> DataSize {
        DataSize(
            self.value * self.unit.factorForConversion(to: unit),
            unit: unit
        )
    }
}

/// The unit of a ``DataSize``.
public enum DataSizeUnit: String, CaseIterable, Decodable {
    /// byte
    case b

    /// kilobyte
    case kb

    /// kibibyte
    case kib

    /// megabyte
    case mb

    /// mebibyte
    case mib

    /// gigabyte
    case gb

    /// gibibyte
    case gib

    /// terabyte
    case tb

    /// tebibyte
    case tib

    /// petabyte
    case pb

    /// pebibyte
    case pib

    /// More verbose synonym.
    public static let bytes: Self = .b

    /// More verbose synonym.
    public static let kilobytes: Self = .kb

    /// More verbose synonym.
    public static let kibibytes: Self = .kib

    /// More verbose synonym.
    public static let megabytes: Self = .mb

    /// More verbose synonym.
    public static let mebibytes: Self = .mib

    /// More verbose synonym.
    public static let gigabytes: Self = .gb

    /// More verbose synonym.
    public static let gibibytes: Self = .gib

    /// More verbose synonym.
    public static let terabytes: Self = .tb

    /// More verbose synonym.
    public static let tebibytes: Self = .tib

    /// More verbose synonym.
    public static let petabytes: Self = .pb

    /// More verbose synonym.
    public static let pebibytes: Self = .pib

    public var inBytes: Int64 {
        switch self {
        case .b:
            return 1
        case .kb:
            return 1000
        case .kib:
            return 1024
        case .mb:
            return 1_000_000
        case .mib:
            return 1_048_576
        case .gb:
            return 1_000_000_000
        case .gib:
            return 1_073_741_824
        case .tb:
            return 1_000_000_000_000
        case .tib:
            return 1_099_511_627_776
        case .pb:
            return 1_000_000_000_000_000
        case .pib:
            return 1_125_899_906_842_624
        }
    }

    public func factorForConversion(to targetUnit: Self) -> Float64 {
        Float64(self.inBytes) / Float64(targetUnit.inBytes)
    }
}
