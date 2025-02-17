//===----------------------------------------------------------------------===//
// Copyright © 2024-2025 Apple Inc. and the Pkl project authors. All rights reserved.
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

public protocol Writer {
    /// Write the given bytes into an output somewhere.
    func write(_ buffer: UnsafeRawBufferPointer) throws

    /// Close the writer interface.
    func close() throws
}

extension Writer {
    func write(_ bytes: [UInt8]) throws {
        try bytes.withUnsafeBytes { try self.write($0) }
    }

    func write(_ byte: UInt8) throws {
        try [byte].withUnsafeBytes { try self.write($0) }
    }
}

public protocol Reader {
    /// Reads bytes from somewhere, writing them into the given bytearray.
    func read(into: UnsafeMutableRawBufferPointer) throws -> Int

    /// Close the reader interface.
    func close() throws
}

/// Writes bytes into an internal buffer.
public class BufferWriter: Writer {
    var bytes: [UInt8] = []

    public func write(_ buffer: UnsafeRawBufferPointer) throws {
        self.bytes.append(contentsOf: buffer)
    }

    public func close() throws {
        // no-op
    }
}

/// Reads bytes from the provided buffer.
public class BufferReader: Reader {
    let bytes: [UInt8]
    var index: Int

    public init(_ bytes: [UInt8]) {
        self.bytes = bytes
        self.index = 0
    }

    public func read(into: UnsafeMutableRawBufferPointer) throws -> Int {
        if self.index == self.bytes.count {
            return 0
        }
        let nextIndex = min(index + into.count, self.bytes.count)
        let slice = self.bytes[self.index..<nextIndex]
        into.copyBytes(from: slice)
        let bytesRead = nextIndex - self.index
        self.index = nextIndex
        return bytesRead
    }

    public func close() throws {
        // no-op
    }
}

/// Like [Reader], but also supports a way to peek bytes.
class PeekableReader: Reader {
    var peekedByte: UInt8?

    let reader: Reader

    init(reader: Reader) {
        self.reader = reader
    }

    func read(into: UnsafeMutableRawBufferPointer) throws -> Int {
        if into.count == 0 {
            return 0
        }
        var bytesRead = 0
        if self.peekedByte != nil {
            into.copyBytes(from: [self.peekedByte!])
            self.peekedByte = nil
            bytesRead += 1
        }
        if into.count > bytesRead {
            let neededBytes = into.count - bytesRead
            let ptr = UnsafeMutableRawBufferPointer.allocate(byteCount: neededBytes, alignment: 1)
            defer { ptr.deallocate() }
            bytesRead += try self.reader.read(into: ptr)
            into.copyBytes(from: ptr)
        }
        return bytesRead
    }

    func peek() throws -> UInt8 {
        if self.peekedByte != nil {
            return self.peekedByte!
        }
        let ptr = UnsafeMutableRawBufferPointer.allocate(byteCount: 1, alignment: 1)
        defer { ptr.deallocate() }
        let bytesRead = try reader.read(into: ptr)
        if bytesRead == 0 {
            let context = DecodingError.Context(
                codingPath: [], debugDescription: "Unexpected end of input"
            )
            throw DecodingError.dataCorrupted(context)
        }
        self.peekedByte = Array(ptr)[0]
        return self.peekedByte!
    }

    func close() throws {
        try self.reader.close()
    }
}
