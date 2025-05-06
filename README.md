# DockGuard

## Install Opa CLI
- https://www.openpolicyagent.org/docs/latest/#running-opa  

## Install conftest 
- https://www.conftest.dev/install/  


## Makefile 구조

```makefile
OPA      ?= opa
CONFTEST ?= conftest

POLICY_DIR      := policy/dockerfile
OPA_TEST_FILES  := $(wildcard $(POLICY_DIR)/*_test.rego)

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
	@echo "==> conftest test --policy $(POLICY_DIR)"
	@$(CONFTEST) test --policy $(POLICY_DIR)

# 3) 전체 테스트 (fmt → opa test → conftest test)
test: fmt test-rego test-conftest
	@echo "✅ All policy tests passed!"
```


## Usage

### 전체 검사

```bash
make test
```

* `fmt` → `test-rego` → `test-conftest` 순서로 실행됩니다.

### 개별 단계 실행

* 포맷/린트 검사만:

  ```bash
  make fmt
  ```

* OPA 유닛 테스트만:

  ```bash
  make test-rego
  ```

* Conftest 린트만:

  ```bash
  make test-conftest
  ```

### TODO 실제 dockerfile 검사 및 