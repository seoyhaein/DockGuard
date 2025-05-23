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

### TODO 실제 dockerfile 검사 및 conda, 기존 있는 여러 dockerfile 등 적용.
- 먼저 rego 완성한다.
- 이후 dockerfile parser 적용하고, 세부적인것을 적용한다. 메뉴얼 작성이라던지 이런것들.
- bio 부분 확장해서 적용한다.
- conftest 사용할지 말지 고민하자. 지금 필요 없을 듯 한데 조금더 고민해보자. rego 코드가 더 지저분해지는 거 같다.  