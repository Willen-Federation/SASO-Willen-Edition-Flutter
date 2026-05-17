FLUTTER     := flutter
DART        := dart
IOS26_DEVICE := E95411CE-1DAF-4FDD-98CB-ED4F0BE0111F

.PHONY: setup gen fmt analyze test test-unit test-widget test-integration \
        test-all build-ios-sim run-ios clean help verify

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*##"}; {printf "  %-20s %s\n", $$1, $$2}'

setup: ## Install Flutter dependencies
	$(FLUTTER) pub get

gen: setup ## Run code generation (freezed, riverpod, json_serializable)
	$(DART) run build_runner build --delete-conflicting-outputs

gen-watch: setup ## Run code generation in watch mode
	$(DART) run build_runner watch --delete-conflicting-outputs

fmt: ## Format all Dart source files
	$(DART) format lib/ test/ integration_test/

analyze: ## Run static analysis
	$(FLUTTER) analyze

verify: ## CI gate — strict analyzer + full test suite
	$(FLUTTER) analyze --fatal-infos --fatal-warnings
	$(FLUTTER) test

test: test-unit test-widget ## Run unit and widget tests

test-unit: ## Run unit tests only
	$(FLUTTER) test test/unit/ --tags unit

test-widget: ## Run widget tests only
	$(FLUTTER) test test/widget/ --tags widget

test-integration: ## Run integration tests on iPhone 17 (iOS 26.4)
	$(FLUTTER) test integration_test/ \
		-d $(IOS26_DEVICE) \
		--timeout 300s

test-all: test test-integration ## Run all tests (unit + widget + integration)

build-ios-sim: ## Build debug app for iOS simulator
	$(FLUTTER) build ios --simulator --debug

run-ios: ## Run app on iPhone 17 (iOS 26.4) simulator
	$(FLUTTER) run -d $(IOS26_DEVICE)

clean: ## Clean build artifacts
	$(FLUTTER) clean
	$(DART) run build_runner clean

lint: fmt analyze ## Format and analyze
