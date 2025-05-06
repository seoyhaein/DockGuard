# Makefile

OPA      ?= opa
CONFTEST ?= conftest

POLICY_DIR      := policy/dockerfile
OPA_TEST_FILES  := $(wildcard $(POLICY_DIR)/*_test.rego)
EXAMPLES_DIR := examples

.PHONY: all fmt test-rego test-conftest test

all: test

# Rego 파일 포맷/린트 확인 (policy 하위 모든 .rego)
fmt:
	@echo "==> opa fmt -l $(POLICY_DIR)"
	@$(OPA) fmt -l $(POLICY_DIR)

# 1) OPA 유닛 테스트: POLICY_DIR 아래 모든 _test.rego 파일
test-rego: $(OPA_TEST_FILES)
	@echo "==> opa test $(POLICY_DIR)"
	@$(OPA) test $(POLICY_DIR)

# 2) Conftest 통합 린트: POLICY_DIR 전체
test-conftest:
	@echo "==> conftest test $(EXAMPLES_DIR) --policy $(POLICY_DIR) --parser dockerfile"
	@$(CONFTEST) test $(EXAMPLES_DIR) \
	  --policy $(POLICY_DIR) \
	  --parser dockerfile \
	  --rego-version v1

# 3) 전체 테스트 (fmt → opa test → conftest test)
test: fmt test-rego test-conftest
	@echo "✅ All policy tests passed!"
