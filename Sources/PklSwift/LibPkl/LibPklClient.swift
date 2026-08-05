//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the Pkl project authors. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//===----------------------------------------------------------------------===//

#if libpkl

#if libpkl_shared && libpkl_static
#error("'libpkl_shared' and 'libpkl_static' are mutually exclusive traits")
#endif

#if libpkl_shared
import CLibPklShared
#else
import CLibPklStatic
#endif
import Foundation

private final class ResponseContext {
    let continuation: AsyncThrowingStream<[UInt8], Error>.Continuation

    init(continuation: AsyncThrowingStream<[UInt8], Error>.Continuation) {
        self.continuation = continuation
    }
}

func messageResponseHandler(length: UInt32, message: UnsafeMutablePointer<CChar>?, userData: UnsafeMutableRawPointer?) {
    // in practice, we can count on these never being nil.
    // we have to declare them nullable because that's how Swift synthesizes bindings for the C code.
    guard let userData, let message else {
        return
    }
    let context = Unmanaged<ResponseContext>.fromOpaque(userData).takeUnretainedValue()
    let bytes = [UInt8](UnsafeRawBufferPointer(start: message, count: Int(length)))
    context.continuation.yield(bytes)
}

final class LibPklClient {
    private let stream: AsyncThrowingStream<[UInt8], Error>
    private let continuation: AsyncThrowingStream<[UInt8], Error>.Continuation
    private let thread = SerialThread("LibPklClient")
    private let context: ResponseContext
    private let contextPtr: UnsafeMutableRawPointer
    private let exec: UnsafeMutablePointer<OpaquePointer?>
    public var closed: Bool = false

    static func getVersion() throws -> String {
        if let version = pkl_version() {
            return String(cString: version)
        }
        throw PklError("pkl_version returned a null pointer")
    }

    init() throws {
        let (stream, continuation) = AsyncThrowingStream<[UInt8], Error>.makeStream()
        self.stream = stream
        self.continuation = continuation

        let context = ResponseContext(continuation: continuation)
        self.context = context
        let contextPtr = Unmanaged.passRetained(context).toOpaque()
        self.contextPtr = contextPtr

        let exec: UnsafeMutablePointer<OpaquePointer?> = .allocate(capacity: 1)
        exec.initialize(to: nil)
        self.exec = exec

        var initError: Error?
        self.thread.run {
            var error = pkl_error_t()
            let response = pkl_init(messageResponseHandler, contextPtr, exec, &error)
            if response != 0 {
                initError = PklError("Failed to call pkl_init: \(String(cString: error.message))")
            }
        }
        if let initError {
            Unmanaged<ResponseContext>.fromOpaque(contextPtr).release()
            exec.deallocate()
            throw initError
        }
    }

    func sendMessage(bytes: [UInt8]) throws {
        let exec = self.exec
        var sendError: Error?
        self.thread.run {
            guard let pexec = exec.pointee else {
                sendError = PklError("LibPklClient is closed")
                return
            }
            var mutableBytes = bytes
            var error = pkl_error_t()
            let response = mutableBytes.withUnsafeMutableBytes { buffer -> Int32 in
                let charPtr = buffer.baseAddress?.assumingMemoryBound(to: CChar.self)
                return pkl_send_message(pexec, UInt32(buffer.count), charPtr, &error)
            }
            if response != 0 {
                sendError = PklError("Failed to call pkl_send_message: \(String(cString: error.message))")
            }
        }
        if let sendError {
            throw sendError
        }
    }

    func getMessages() -> AsyncThrowingStream<[UInt8], Error> {
        self.stream
    }

    func close() throws {
        if self.closed {
            return
        }
        defer { thread.close() }
        let exec = self.exec
        var err: Error?
        self.thread.run {
            if let pexec = exec.pointee {
                var error = pkl_error_t()
                let response = pkl_close(pexec, &error)
                if response != 0 {
                    err = PklError("Failed to call pkl_close: \(String(cString: error.message))")
                }
            }
        }
        if let err {
            throw err
        }
        exec.deallocate()
        self.continuation.finish()
        Unmanaged<ResponseContext>.fromOpaque(self.contextPtr).release()
        self.closed = true
    }
}
#endif
