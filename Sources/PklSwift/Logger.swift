// ===----------------------------------------------------------------------===//
// Copyright © 2024 Apple Inc. and the Pkl project authors. All rights reserved.
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

/// Handler to control logging messages emitted by the Pkl evaluator.
///
/// To set a logger, register it on EvaluatorOptions.Logger when building an Evaluator.
public protocol Logger {
    /// Log the message using level TRACE.
    ///
    /// - Parameters:
    ///   - message: The message to log
    ///   - frameUri: A string representing the location where the log message was emitted.
    func trace(message: String, frameUri: String)

    /// Log the message using level WARN.
    ///
    /// - Parameters:
    ///   - message: The message to log
    ///   - frameUri: A string representing the location where the log message was emitted.
    func warn(message: String, frameUri: String)
}

public struct NoopLogger: Logger {
    public func trace(message: String, frameUri: String) {
        // no-op
    }

    public func warn(message: String, frameUri: String) {
        // no-op
    }
}

extension Logger {
    /// The default format for log messages.
    public func formatLogMessage(level: String, message: String, frameUri: String) -> String {
        "pkl: \(level): \(message) (\(frameUri))\n"
    }
}

/// A logger that writes messages to the provided ``FileHandle``.
public struct FileHandleLogger: Logger {
    var fileHandle: FileHandle

    public init(_ fileHandle: FileHandle) {
        self.fileHandle = fileHandle
    }

    public func trace(message: String, frameUri: String) {
        let message = formatLogMessage(level: "TRACE", message: message, frameUri: frameUri)
        self.fileHandle.write(Data(message.utf8))
    }

    public func warn(message: String, frameUri: String) {
        let message = formatLogMessage(level: "WARN", message: message, frameUri: frameUri)
        self.fileHandle.write(Data(message.utf8))
    }
}

public enum Loggers {
    /// A logger that writes everything to stdout.
    public static var standardOutput: Logger { FileHandleLogger(.standardOutput) }

    /// A logger that writes everything to stderr.
    public static var standardError: Logger { FileHandleLogger(.standardError) }

    /// A logger that discards log messages.
    public static var noop: Logger { NoopLogger() }
}
