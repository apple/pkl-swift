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
