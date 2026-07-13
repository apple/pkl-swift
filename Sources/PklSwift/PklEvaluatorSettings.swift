//===----------------------------------------------------------------------===//
// Copyright © 2024-2026 Apple Inc. and the Pkl project authors. All rights reserved.
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
public struct PklEvaluatorSettings: Decodable, Hashable, Sendable {
    public init(
        externalProperties: [String: String]? = nil,
        env: [String: String]? = nil,
        allowedModules: [String]? = nil,
        allowedResources: [String]? = nil,
        noCache: Bool? = nil,
        modulePath: [String]? = nil,
        timeout: Duration? = nil,
        moduleCacheDir: String? = nil,
        rootDir: String? = nil,
        http: Http? = nil,
        externalModuleReaders: [String: ExternalReader]? = nil,
        externalResourceReaders: [String: ExternalReader]? = nil,
        color: PklEvaluatorSettingsColor? = nil,
        traceMode: TraceMode? = nil
    ) {
        self.externalProperties = externalProperties
        self.env = env
        self.allowedModules = allowedModules
        self.allowedResources = allowedResources
        self.noCache = noCache
        self.modulePath = modulePath
        self.timeout = timeout
        self.moduleCacheDir = moduleCacheDir
        self.rootDir = rootDir
        self.http = http
        self.externalModuleReaders = externalModuleReaders
        self.externalResourceReaders = externalResourceReaders
        self.color = color
        self.traceMode = traceMode
    }

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

    /// Added in Pkl 0.30
    let traceMode: TraceMode?
}

public enum PklEvaluatorSettingsColor: String, CaseIterable, Decodable, Hashable, Sendable {
    /// Never format.
    case never

    /// Format if the process' stdin, stdout, or stderr are connected to a console.
    case auto

    /// Always format.
    case always
}

/// Settings that control how Pkl talks to HTTP(S) servers.
public struct Http: Codable, Hashable, Sendable {
    /// PEM format certificates to trust when making HTTP requests.
    ///
    /// If empty, Pkl will trust its own built-in certificates.
    var caCertificates: [UInt8]?

    /// Configuration of the HTTP proxy to use.
    ///
    /// If `nil`, uses the operating system's proxy configuration.
    /// Configuration of the HTTP proxy to use.
    var proxy: Proxy?

    /// HTTP URL rewrite rules.
    ///
    /// Added in Pkl 0.29.
    /// This field is ignored if targeting Pkl 0.28 and older.
    ///
    /// Each key-value pair designates a source prefix to a target prefix.
    /// Each rewrite rule must start with `http://` or `https://`, and end with `/`.
    ///
    /// This option is often used for setting up package mirroring.
    ///
    /// The following example will rewrite a request https://example.com/foo/bar to https://my.other.website/foo/bar:
    ///
    ///		Rewrites: [
    ///			"https://example.com/": "https://my.other.website/"
    ///		]
    var rewrites: [String: String]?

    /// HTTP headers to add to outbound requests.
    /// Each key is a glob pattern, and each value is a mapping of header name to header value(s).
    ///
    /// Before an HTTP request is made, each key is matched against the request URL.
    /// For all matches, each of their described headers are added to the request.
    ///
    /// To add headers to all HTTP requests, use `**` as the glob pattern.
    var headers: [String: [String: HeaderValue]]?

    public enum HeaderValue: Codable, Hashable, Sendable {
        case value(String)
        case values([String])

        public func encode(to encoder: any Encoder) throws {
            switch self {
            case .value(let value):
                try value.encode(to: encoder)
            case .values(let values):
                try values.encode(to: encoder)
            }
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.singleValueContainer()
            do {
                self = try .value(container.decode(String.self))
            } catch DecodingError.typeMismatch(_, _) {
                self = try .values(container.decode([String].self))
            }
        }
    }
}

/// Settings that control how Pkl talks to HTTP proxies.
public struct Proxy: Codable, Hashable, Sendable {
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

public struct ExternalReader: Codable, Hashable, Sendable {
    /// The absolute path to the executable, or a simple name.
    ///
    /// In the case of a simple name, it is resolved off of the `PATH` environment variable.
    var executable: String

    /// The command line arguments to pass to the process.
    var arguments: [String]? = nil

    /// The working directory to use for the executable process.
    ///
    /// Added in Pkl 0.32.
    var workingDir: String? = nil
}
