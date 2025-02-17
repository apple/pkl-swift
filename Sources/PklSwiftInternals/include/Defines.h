/*
 * Copyright © 2024-2025 Apple Inc. and the Pkl project authors. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2024 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for Swift project authors
//

#if !defined(PKLS_DEFINES_H)
#define PKLS_DEFINES_H

#define PKLS_ASSUME_NONNULL_BEGIN _Pragma("clang assume_nonnull begin")
#define PKLS_ASSUME_NONNULL_END _Pragma("clang assume_nonnull end")

#if defined(__cplusplus)
#define PKLS_EXTERN extern "C"
#else
#define PKLS_EXTERN extern
#endif

#if defined(_WIN32)
#define PKLS_IMPORT_FROM_STDLIB PKLS_EXTERN __declspec(dllimport)
#else
#define PKLS_IMPORT_FROM_STDLIB PKLS_EXTERN
#endif

#endif // PKLS_DEFINES_H
