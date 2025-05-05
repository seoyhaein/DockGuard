# policy/dockerfile/multistage.rego
package dockerfile.multistage

# DFM001: 오직 한 번의 FROM만 허용 — 환경 준비만 정의
deny[msg] {
  count([inst | inst := input[_]; lower(inst.Cmd) == "from"]) != 1
  msg := "DFM001: 사용자 Dockerfile에는 환경 준비용으로 FROM 명령을 정확히 한 번만 사용해야 합니다."
}

# DFM002: FROM에 AS builder 별칭 필수
deny[msg] {
  inst := [inst | inst := input[_]; lower(inst.Cmd) == "from"][0]
  not re_match("(?i)^FROM\\s+.+\\s+AS\\s+builder$", inst.Raw)
  msg := "DFM002: FROM 명령에 `AS builder` 별칭을 지정하세요. (예: FROM ubuntu:20.04 AS builder)"
}

# DFM003: 최종 스테이지(FROM ... AS final) 정의 금지
deny[msg] {
  inst := input[_]
  lower(inst.Cmd) == "from"
  re_match("(?i)^FROM\\s+.+\\s+AS\\s+final$", inst.Raw)
  msg := "DFM003: 사용자 Dockerfile에 최종 스테이지(FROM ... AS final)를 정의하지 마세요; 시스템이 자동 생성합니다."
}

# DFM004: COPY --from 옵션 사용 금지 (시스템 내부에서 처리)
deny[msg] {
  inst := input[_]
  lower(inst.Cmd) == "copy"
  some i
  inst.Value[i] == "--from=builder"
  msg := "DFM004: 사용자 Dockerfile에서 `COPY --from=builder` 옵션 사용은 금지됩니다."
}
