# policy/dockerfile/multistage_test.rego
package dockerfile.multistage

import data.dockerfile.multistage

# --- 정상 케이스: 정확히 한 번의 FROM + AS builder ---
test_builder_only_ok {
  input := [
    {"Cmd": "from", "Raw": "FROM ubuntu:20.04 AS builder"}
  ]
  # deny 결과가 empty array 여야 통과
  data.dockerfile.multistage.deny with input as input == []
}

# --- DFM001: FROM이 1개가 아니면 에러 ---
test_dfm001_too_many_from {
  input := [
    {"Cmd": "from", "Raw": "FROM ubuntu:20.04 AS builder"},
    {"Cmd": "from", "Raw": "FROM alpine:3.14 AS builder"}
  ]
  some msg
  msg == "DFM001: 사용자 Dockerfile에는 환경 준비용으로 FROM 명령을 정확히 한 번만 사용해야 합니다."
  # deny 메시지에 DFM001이 포함돼야 함
  data.dockerfile.multistage.deny with input as input[msg]
}

# --- DFM002: AS builder 별칭 누락 ---
test_dfm002_missing_builder_alias {
  input := [
    {"Cmd": "from", "Raw": "FROM ubuntu:20.04"}
  ]
  some msg
  msg == "DFM002: FROM 명령에 `AS builder` 별칭을 지정하세요. (예: FROM ubuntu:20.04 AS builder)"
  data.dockerfile.multistage.deny with input as input[msg]
}

# --- DFM003: 최종 스테이지 정의 금지 ---
test_dfm003_forbidden_final_stage {
  input := [
    {"Cmd": "from", "Raw": "FROM ubuntu:20.04 AS builder"},
    {"Cmd": "from", "Raw": "FROM busybox:latest AS final"}
  ]
  some msg
  msg == "DFM003: 사용자 Dockerfile에 최종 스테이지(FROM ... AS final)를 정의하지 마세요; 시스템이 자동 생성합니다."
  data.dockerfile.multistage.deny with input as input[msg]
}

# --- DFM004: COPY --from=builder 사용 금지 ---
test_dfm004_forbidden_copy_from {
  input := [
    {"Cmd": "from", "Raw": "FROM ubuntu:20.04 AS builder"},
    {"Cmd": "copy", "Value": ["--from=builder", "/src", "/dest"], "Raw": "COPY --from=builder /src /dest"}
  ]
  some msg
  msg == "DFM004: 사용자 Dockerfile에서 `COPY --from=builder` 옵션 사용은 금지됩니다."
  data.dockerfile.multistage.deny with input as input[msg]
}
