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

/// Duration is the Swift representation of Pkl's `pkl.Duration`.
public struct Duration: Hashable {
    /// The value of this ``Duration`` in the unit set in ``unit``.
    public let value: Float64

    /// The unit of this ``Duration``, for example, millisecond, second, minute.
    public let unit: DurationUnit

    public init(_ value: some BinaryInteger, unit: DurationUnit) {
        self.value = Float64(value)
        self.unit = unit
    }

    public init(_ value: some BinaryFloatingPoint, unit: DurationUnit) {
        self.value = Float64(value)
        self.unit = unit
    }
}

extension Duration: PklSerializableValueUnitType {
    public static let messageTag: PklValueType = .duration

    public typealias UnitType = DurationUnit
}

extension Duration: CustomStringConvertible {
    public var description: String {
        "\(format(fractional: self.value)!).\(self.unit)"
    }
}

extension Duration {
    /// Converts this ``Duration`` to the specified unit.
    ///
    /// - Parameter unit: The unit to convert to
    /// - Returns: The converted duration.
    public func toUnit(_ unit: DurationUnit) -> Duration {
        Duration(
            self.value * self.unit.factorForConversion(to: unit),
            unit: unit
        )
    }

    /// Converts this duration to a ``Swift.Duration``.
    ///
    /// - Returns: The swift duration.
    public func toSwiftDuration() -> Swift.Duration {
        Swift.Duration.nanoseconds(Int64(self.value * self.unit.factorForConversion(to: .ns)))
    }
}

extension Swift.Duration {
    /// Converts this duration to a Pkl ``Duration``.
    public func toPklDuration() -> Duration {
        Duration(
            Float64(components.attoseconds / 1_000_000_000 + components.seconds * 1_000_000_000),
            unit: .ns
        )
    }
}

/// Convenient constructor functions
extension Duration {
    public static func nanoseconds(_ value: some BinaryInteger) -> Self {
        Self(value, unit: .nanoseconds)
    }

    public static func nanoseconds(_ value: some BinaryFloatingPoint) -> Self {
        Self(value, unit: .nanoseconds)
    }

    public static func microseconds(_ value: some BinaryInteger) -> Self {
        Self(value, unit: .microseconds)
    }

    public static func microseconds(_ value: some BinaryFloatingPoint) -> Self {
        Self(value, unit: .microseconds)
    }

    public static func milliseconds(_ value: some BinaryInteger) -> Self {
        Self(value, unit: .milliseconds)
    }

    public static func milliseconds(_ value: some BinaryFloatingPoint) -> Self {
        Self(value, unit: .milliseconds)
    }

    public static func seconds(_ value: some BinaryInteger) -> Self {
        Self(value, unit: .seconds)
    }

    public static func seconds(_ value: some BinaryFloatingPoint) -> Self {
        Self(value, unit: .seconds)
    }

    public static func minutes(_ value: some BinaryInteger) -> Self {
        Self(value, unit: .minutes)
    }

    public static func minutes(_ value: some BinaryFloatingPoint) -> Self {
        Self(value, unit: .minutes)
    }

    public static func hours(_ value: some BinaryInteger) -> Self {
        Self(value, unit: .hours)
    }

    public static func hours(_ value: some BinaryFloatingPoint) -> Self {
        Self(value, unit: .hours)
    }

    public static func days(_ value: some BinaryInteger) -> Self {
        Self(value, unit: .days)
    }

    public static func days(_ value: some BinaryFloatingPoint) -> Self {
        Self(value, unit: .days)
    }
}

/// A unit (magnitude) of duration.
public enum DurationUnit: String, CaseIterable, Decodable {
    /// Nanosecond
    case ns

    /// Microsecond
    case us

    /// Millisecond
    case ms

    /// Second
    case s

    /// Minute
    case min

    /// Hour
    case h

    /// Day
    case d

    /// More verbose synonym.
    public static let nanoseconds: Self = .ns

    /// More verbose synonym.
    public static let microseconds: Self = .us

    /// More verbose synonym.
    public static let milliseconds: Self = .ms

    /// More verbose synonym.
    public static let seconds: Self = .s

    /// More verbose synonym.
    public static let minutes: Self = .min

    /// More verbose synonym.
    public static let hours: Self = .h

    /// More verbose synonym.
    public static let days: Self = .d

    public var inNanoSeconds: Int64 {
        switch self {
        case .ns:
            return 1
        case .us:
            return 1000
        case .ms:
            return 1_000_000
        case .s:
            return 1_000_000_000
        case .min:
            return 60_000_000_000
        case .h:
            return 3_600_000_000_000
        case .d:
            return 86_400_000_000_000
        }
    }

    public func factorForConversion(to targetUnit: Self) -> Float64 {
        Float64(self.inNanoSeconds) / Float64(targetUnit.inNanoSeconds)
    }
}
