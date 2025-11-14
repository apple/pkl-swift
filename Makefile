SNIPPET_INPUTS := $(shell find codegen/snippet-tests/input/*.pkl)
FIXTURES_INPUTS := $(shell find Tests/PklSwiftTests/Fixtures/*.pkl)
SWIFT_INPUTS := $(shell find Sources/*/**.swift)
PKL_CODEGEN_INPUTS := $(shell find codegen/src/**/*.pkl)
PKL_TESTS := $(shell find codegen/src/tests/*.pkl)
PKL_TEST_OUTPUT := $(PKL_TESTS:.pkl=.xml)
MAKEFLAGS += -j$(NPROCS)
UNAME := $(shell uname -s)
PKL_GEN_SWIFT := $(shell swift build --show-bin-path)/pkl-gen-swift
PKL_GEN_SWIFT_RELEASE :=
ifeq ($(UNAME), Darwin)
	PKL_GEN_SWIFT_RELEASE += ".build/apple/release/pkl-gen-swift"
else
	PKL_GEN_SWIFT_RELEASE := $(shell swift build --configuration release --product pkl-gen-swift --show-bin-path)/pkl-gen-swift
endif
PKL_EXEC ?= pkl

.PHONY: help
help:
	@echo "Snippet tests:"
	@echo $(SNIPPET_INPUTS) | tr ' ' '\n' | sort

	@echo "Fixtures:"
	@echo $(FIXTURES_INPUTS) | tr ' ' '\n' | sort

.PHONY: test
test: test-snippets test-pkl test-swift-lib

.PHONY: generate-snippets
generate-snippets: clean-snippets pkl-gen-swift
	$(PKL_GEN_SWIFT) $(SNIPPET_INPUTS) -o codegen/snippet-tests/output --generate-script codegen/src/Generator.pkl

.PHONY: generate-fixtures
generate-fixtures: clean-fixtures pkl-gen-swift
	$(PKL_GEN_SWIFT) $(FIXTURES_INPUTS) -o Tests/PklSwiftTests/Fixtures/Generated --generate-script codegen/src/Generator.pkl

# TODO how do we inline the logic of test-snippets into here?
.PHONY: test-snippets
test-snippets:
	./scripts/test-snippets.sh

.PHONY: test-swift-lib
test-swift-lib: generate-fixtures
	@swift test

.PHONY: test-pkl
test-pkl: $(PKL_CODEGEN_INPUTS)
	$(PKL_EXEC) test codegen/src/tests/*.pkl --junit-reports .out/test-results/

.PHONY: clean
clean: clean-snippets clean-fixtures clean-build

.PHONY: clean-build
clean-build:
	@rm -rf .build/

.PHONY: clean-snippets
clean-snippets:
	@rm -rf codegen/snippet-tests/output/

.PHONY: clean-fixtures
clean-fixtures:
	@rm -rf Tests/PklSwiftTests/Fixtures/Generated

.PHONY: pkl-gen-swift
pkl-gen-swift: $(PKL_GEN_SWIFT)

$(PKL_GEN_SWIFT): $(SWIFT_INPUTS)
	@swift build

.build/x86_64-apple-macosx/release/pkl-gen-swift: $(SWIFT_INPUTS)
	@swift build \
		--product pkl-gen-swift \
		--configuration release \
		--arch x86_64

.build/arm64-apple-macosx/release/pkl-gen-swift: $(SWIFT_INPUTS)
	@swift build \
		--product pkl-gen-swift \
		--configuration release \
		--arch arm64

ifeq ($(UNAME), Darwin)
# If macOS, build a universal binary
# We should be able to do multi-arch builds, but need to workaround for now
# (see https://github.com/apple/swift-package-manager/issues/6969)
$(PKL_GEN_SWIFT_RELEASE):
	$(MAKE) .build/x86_64-apple-macosx/release/pkl-gen-swift
	$(MAKE) .build/arm64-apple-macosx/release/pkl-gen-swift
	@mkdir -p .build/apple/release/
	@lipo -create \
		-output .build/apple/release/pkl-gen-swift \
		.build/x86_64-apple-macosx/release/pkl-gen-swift \
		.build/arm64-apple-macosx/release/pkl-gen-swift
else
# otherwise, build a binary for the machine's arch.
$(PKL_GEN_SWIFT_RELEASE): $(SWIFT_INPUTS)
	@swift build \
		--product pkl-gen-swift \
		--configuration release
endif

.PHONY: pkl-package
pkl-package:
	$(PKL_EXEC) project package codegen/src/

.PHONY: pkl-gen-swift-release
pkl-gen-swift-release: $(PKL_GEN_SWIFT_RELEASE)

.PHONY: pkl-gen-swift-release-output
pkl-gen-swift-release-output:
	@echo "$(PKL_GEN_SWIFT_RELEASE)" | xargs

.PHONY: gha-config
gha-config:
	$(PKL_EXEC) eval --project-dir .github -m .github .github/index.pkl

.PHONY: swiftformat
swiftformat:
	swift package plugin --allow-writing-to-package-directory swiftformat .

.PHONY: swiftformat-lint
swiftformat-lint:
	swift package plugin --allow-writing-to-package-directory swiftformat --lint .

.PHONY: license-format
license-format: .build/tools/hawkeye
	.build/tools/hawkeye format

.PHONY: pkl-format
pkl-format:
	$(PKL_EXEC) format --grammar-version 1 --write .

.PHONY: pkl-format-lint
pkl-format-lint:
	$(PKL_EXEC) format --grammar-version 1 --diff-name-only .

.PHONY: format
format: swiftformat license-format pkl-format
