//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2023 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for Swift project authors
//

#if !defined(PKLS_DISCOVERY_H)
#define PKLS_DISCOVERY_H

#include "Defines.h"

#include <stdbool.h>

PKLS_ASSUME_NONNULL_BEGIN

/// The type of callback that is called by `pkls_enumerateTypes()`.
///
/// - Parameters:
///   - typeMetadata: A type metadata pointer that can be bitcast to `Any.Type`.
///   - context: An arbitrary pointer passed by the caller to
///     `pkls_enumerateTypes()`.
typedef void (* PKLSTypeEnumerator)(void *typeMetadata, void *_Null_unspecified context);

/// The type name filter that is called by `pkls_enumerateTypes()`.
///
/// - Parameters:
///   - typeName: The name of the type being considered, as a C string.
///   - context: An arbitrary pointer passed by the caller to
///     `pkls_enumerateTypes()`.
///
/// - Returns: Whether or not the type named by `typeName` should be passed to
///   the corresponding enumerator function.
typedef bool (* PKLSTypeNameFilter)(const char *typeName, void *_Null_unspecified context);

/// Enumerate all types known to Swift found in the current process.
///
/// - Parameters:
///   - nameFilter: If not `nullptr`, a filtering function that checks if a type
///     name is valid before realizing the type.
///   - body: A function to invoke. `context` is passed to it along with a
///     type metadata pointer (which can be bitcast to `Any.Type`.)
///   - context: An arbitrary pointer to pass to `body`.
///
/// This function may enumerate the same type more than once (for instance, if
/// it is present in an image's metadata table multiple times, or if it is an
/// Objective-C class implemented in Swift.) Callers are responsible for
/// deduping type metadata pointers passed to `body`.
PKLS_EXTERN void pkls_enumerateTypes(PKLSTypeNameFilter _Nullable nameFilter, PKLSTypeEnumerator body, void *_Null_unspecified context);

PKLS_ASSUME_NONNULL_END

#endif
