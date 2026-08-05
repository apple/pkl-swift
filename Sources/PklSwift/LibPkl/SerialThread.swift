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
import Foundation

final class SerialThread: @unchecked Sendable {
    private let semaphore = DispatchSemaphore(value: 0)
    private let lock = NSLock()
    private var jobs: [() -> Void] = []
    private var thread: Thread!
    private var stopped = false

    init(_ name: String) {
        self.thread = Thread { [weak self] in
            guard let self else { return }
            while true {
                self.semaphore.wait()
                self.lock.lock()
                if self.jobs.isEmpty {
                    let stopped = self.stopped
                    self.lock.unlock()
                    if stopped { return }
                    continue
                }
                let job = self.jobs.removeFirst()
                self.lock.unlock()
                job()
            }
        }
        self.thread.name = name
        self.thread.start()
    }

    func run(_ job: @escaping () -> Void) {
        let result = DispatchSemaphore(value: 0)
        self.lock.lock()
        guard !self.stopped else {
            self.lock.unlock()
            return
        }
        self.jobs.append {
            job()
            result.signal()
        }
        self.lock.unlock()
        self.semaphore.signal()
        result.wait()
    }

    /// Stops the dedicated thread once any queued work has drained.
    ///
    /// Safe to call more than once; jobs submitted via `run` after this point are ignored.
    func close() {
        self.lock.lock()
        self.stopped = true
        self.lock.unlock()
        self.semaphore.signal()
    }
}
#endif
