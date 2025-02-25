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

/// The Swift representation of standard library module `pkl.EvaluatorSettings`.
public struct PklEvaluatorSettings: Decodable, Hashable {
    let externalProperties: [String: String]?
    let env: [String: String]?
    let allowedModules: [String]?
    let allowedResources: [String]?
    let noCache: Bool?
    let modulePath: [String]?
    let timeout: Duration?
    let moduleCacheDir: String?
    let rootDir: String?
    let http: Http?

    /// Added in Pkl 0.27
    let externalModuleReaders: [String: ExternalReader]?

    /// Added in Pkl 0.27
    let externalResourceReaders: [String: ExternalReader]?

    /// Whether to format messages and test results with ANSI color colors.
    ///
    /// Added in Pkl 0.27
    let color: PklEvaluatorSettingsColor?
}

public enum PklEvaluatorSettingsColor: String, CaseIterable, Decodable, Hashable {
    /// Never format.
    case never

    /// Format if the process' stdin, stdout, or stderr are connected to a console.
    case auto

    /// Always format.
    case always
}

/// Settings that control how Pkl talks to HTTP(S) servers.
public struct Http: Codable, Hashable {
    /// PEM format certificates to trust when making HTTP requests.
    ///
    /// If empty, Pkl will trust its own built-in certificates.
    var caCertificates: [UInt8]?

    /// Configuration of the HTTP proxy to use.
    ///
    /// If `nil`, uses the operating system's proxy configuration.
    /// Configuration of the HTTP proxy to use.
    var proxy: Proxy?
}

/// Settings that control how Pkl talks to HTTP proxies.
public struct Proxy: Codable, Hashable {
    /// The proxy to use for HTTP(S) connections.
    ///
    /// Only HTTP proxies are supported.
    /// The address must start with `"http://"`, and cannot contain anything other than a host and an optional port.
    ///
    /// Example:
    /// ```
    /// "http://my.proxy.example.com:5080"
    /// ```
    var address: String?

    /// Hosts to which all connections should bypass a proxy.
    ///
    ///
    /// Values can be either hostnames, or IP addresses.
    /// IP addresses can optionally be provided using
    /// [CIDR notation](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing#CIDR_notation).
    ///
    /// The value `"*"` is a wildcard that disables proxying for all hosts.
    ///
    /// A hostname matches all subdomains.
    /// For example, `example.com` matches `foo.example.com`, but not `fooexample.com`.
    /// A hostname that is prefixed with a dot matches the hostname itself,
    /// so `.example.com` matches `example.com`.
    ///
    /// Hostnames do not match their resolved IP addresses.
    /// For example, the hostname `localhost` will not match `127.0.0.1`.
    ///
    /// Optionally, a port can be specified.
    /// If a port is omitted, all ports are matched.
    ///
    /// Example:
    ///
    /// ```
    /// [ "127.0.0.1",
    ///   "169.254.0.0/16",
    ///   "example.com",
    ///   "localhost:5050" ]
    /// ```
    var noProxy: [String]?
}

public struct ExternalReader: Codable, Hashable {
    var executable: String
    var arguments: [String]? = nil
}
