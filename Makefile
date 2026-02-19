SNIPPET_INPUTS := $(shell find codegen/snippet-tests/input/*.pkl)
FIXTURES_INPUTS := $(shell find Tests/PklSwiftTests/Fixtures/*.pkl)
PKL_CODEGEN_INPUTS := $(shell find codegen/src/**/*.pkl)
PKL_TESTS := $(shell find codegen/src/tests/*.pkl)
PKL_TEST_OUTPUT := $(PKL_TESTS:.pkl=.xml)
MAKEFLAGS += -j$(NPROCS)
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
generate-snippets: clean-snippets
	$(PKL_EXEC) run --project-dir codegen/src codegen/src/gen.pkl $(SNIPPET_INPUTS) -o codegen/snippet-tests/output

.PHONY: generate-fixtures
generate-fixtures: clean-fixtures
	$(PKL_EXEC) run --project-dir codegen/src codegen/src/gen.pkl $(FIXTURES_INPUTS) -o Tests/PklSwiftTests/Fixtures/Generated

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

.PHONY: pkl-package
pkl-package:
	$(PKL_EXEC) project package codegen/src/

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
