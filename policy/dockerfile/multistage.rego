# policy/dockerfile/multistage.rego
package dockerfile.multistage

import future.keywords.in

# --- helper: default args list for missing Value or Args ---
# returns inst.Value if present, else inst.Args if present, else empty list
args_or_empty(inst) := a if {
    a := inst.Value
} else := a if {
    a := []
}

# --- helper: default raw string for missing Raw or Original ---
# returns inst.Raw if present, else inst.Original if present, else empty string
raw_or_empty(inst) := r if {
    r := inst.Raw
} else := r if {
    r := ""
}

# --- normalize helper: unify AST shape from different parsers ---
# returns a single object with cmd, args, raw fields
normalize(inst) := res if {
    # Moby parser AST case
    inst.Cmd
    res := {
        "cmd":  lower(inst.Cmd),
        "args": args_or_empty(inst),
        "raw":  raw_or_empty(inst),
    }
} else := res if {
    # Conftest default parser AST case
    inst.Instruction
    res := {
        "cmd":  lower(inst.Instruction),
        "args": args_or_empty(inst),
        "raw":  raw_or_empty(inst),
    }
}

# 공통: normalize를 통한 FROM 인스트럭션 리스트
froms := [inst | some inst in input; lower(inst.Cmd) == "from"]
count_froms := count(froms)


# DFM001: FROM은 반드시 하나
deny contains msg if {
  count_froms != 1
  msg := "DFM001: 사용자 Dockerfile에는 환경 준비용으로 FROM 명령을 정확히 한 번만 사용해야 합니다."
}

# DFM002: (guard) FROM이 하나일 때만 AS builder 확인
deny contains msg if {
  count_froms == 1         # 여기서 선행조건을 걸어 줌
  inst := normalize(froms[0])
  not regex.match(`(?i)^FROM\s+.+\s+AS\s+builder$`, inst.raw)
  msg := "DFM002: FROM 명령에 `AS builder` 별칭을 지정하세요. (예: FROM ubuntu:20.04 AS builder)"
}

# DFM003: 최종 스테이지 정의 금지 (FROM이 하나라도 final이면 안 됨)
deny contains msg if {
    raw := input[_]
    inst := normalize(raw)
    inst.cmd == "from"
    regex.match(`(?i)^FROM\s+.+\s+AS\s+final$`, inst.raw)
    msg := "DFM003: 사용자 Dockerfile에 최종 스테이지(FROM ... AS final)를 정의하지 마세요; 시스템이 자동 생성합니다."
}

# DFM004: COPY --from=builder 금지
deny contains msg if {
    raw := input[_]
    inst := normalize(raw)
    inst.cmd == "copy"
    some i
    inst.args[i] == "--from=builder"
    msg := "DFM004: 사용자 Dockerfile에서 `COPY --from=builder` 옵션 사용은 금지됩니다."
}
