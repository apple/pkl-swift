// Code generated from Pkl module `pkl.swift.GeneratorSettings`. DO NOT EDIT.
import PklSwift

public enum GeneratorSettings {}

extension GeneratorSettings {
  /// Settings used to configure code generation.
  public struct Module: PklRegisteredType, Decodable, Hashable {
    public static let registeredIdentifier: String = "pkl.swift.GeneratorSettings"

    /// The set of modules to turn into Swift code.
    ///
    /// A module's dependencies are also included in code generation.
    /// Therefore, in most cases, it is only necessary to provide the entrypoint for code generation.
    public var inputs: [String]?

    /// The output path to write generated files into.
    ///
    /// Defaults to `.out`. Relative paths are resolved against the enclosing directory.
    public var outputPath: String?

    /// If [true], prints the filenames that would be created, but skips writing any files.
    public var dryRun: Bool?

    /// The Generator.pkl script to use for code generation.
    ///
    /// This is an internal setting that's meant for development purposes.
    public var generateScript: String?

    public init(inputs: [String]?, outputPath: String?, dryRun: Bool?, generateScript: String?) {
      self.inputs = inputs
      self.outputPath = outputPath
      self.dryRun = dryRun
      self.generateScript = generateScript
    }
  }

  /// Load the Pkl module at the given source and evaluate it into `GeneratorSettings.Module`.
  ///
  /// - Parameter source: The source of the Pkl module.
  public static func loadFrom(source: ModuleSource) async throws -> GeneratorSettings.Module {
    try await PklSwift.withEvaluator { evaluator in
      try await loadFrom(evaluator: evaluator, source: source)
    }
  }

  /// Load the Pkl module at the given source and evaluates it with the given evaluator into
  /// `GeneratorSettings.Module`.
  ///
  /// - Parameter evaluator: The evaluator to use for evaluation.
  /// - Parameter source: The module to evaluate.
  public static func loadFrom(
    evaluator: PklSwift.Evaluator,
    source: PklSwift.ModuleSource
  ) async throws -> GeneratorSettings.Module {
    try await evaluator.evaluateModule(source: source, as: Module.self)
  }
}