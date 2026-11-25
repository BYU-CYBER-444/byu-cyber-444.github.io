---
title: "Self-Check & Grading"
parent: "IT LAB 14 - AI Inference Server Setup and Governance"
grand_parent: Labs
nav_order: 6
---

# Self-Check & Grading
{: .no_toc }

---

## Self-Check Script

Run this script from `it-lab14-ai01` to verify your files pass the same checks the grader uses. Your instructor grades your VM directly — no file upload required.

```bash
#!/bin/bash
SUBDIR=~/lab14-submission
PASS=0; FAIL=0

check() {
    if eval "$2"; then echo "  PASS: $1"; ((PASS++));
    else echo "  FAIL: $1"; ((FAIL++)); fi
}

echo "=== Part 1 ==="
check "part1_models.txt contains llama3.2:1b" \
    "grep -q 'llama3.2:1b' $SUBDIR/part1_models.txt"
check "part1_models.txt contains mistral:7b" \
    "grep -q 'mistral' $SUBDIR/part1_models.txt"
check "part1_service.txt == active" \
    "grep -qx 'active' $SUBDIR/part1_service.txt"
check "part1_override.txt contains OLLAMA_MAX_LOADED_MODELS=2" \
    "grep -q 'OLLAMA_MAX_LOADED_MODELS=2' $SUBDIR/part1_override.txt"
check "part1_override.txt contains OLLAMA_NUM_PARALLEL=4" \
    "grep -q 'OLLAMA_NUM_PARALLEL=4' $SUBDIR/part1_override.txt"

echo "=== Part 2 ==="
check "benchmark_results.json is valid JSON with 9 entries" \
    "python3 -c \"import json; d=json.load(open('$SUBDIR/benchmark_results.json')); assert len(d)==9\""
check "benchmark_results.json all tokens_per_sec > 0" \
    "python3 -c \"import json; d=json.load(open('$SUBDIR/benchmark_results.json')); assert all(r['tokens_per_sec']>0 for r in d)\""
check "part2_summary.json is valid JSON" \
    "python3 -c \"import json; json.load(open('$SUBDIR/part2_summary.json'))\""
check "part2_summary.json ratio_1b_to_7b_short > 1.0" \
    "python3 -c \"import json; d=json.load(open('$SUBDIR/part2_summary.json')); assert d['ratio_1b_to_7b_short'] > 1.0\""

echo "=== Part 3 ==="
check "part3_auth_test.json valid_key_status == 200" \
    "python3 -c \"import json; d=json.load(open('$SUBDIR/part3_auth_test.json')); assert d['valid_key_status']==200\""
check "part3_auth_test.json wrong_key_status == 401" \
    "python3 -c \"import json; d=json.load(open('$SUBDIR/part3_auth_test.json')); assert d['wrong_key_status']==401\""
check "part3_auth_test.json blocked_endpoint_status == 403" \
    "python3 -c \"import json; d=json.load(open('$SUBDIR/part3_auth_test.json')); assert d['blocked_endpoint_status']==403\""
check "part3_auth_directive.txt contains auth_request" \
    "grep -qi 'auth_request' $SUBDIR/part3_auth_directive.txt"

echo "=== Part 4 ==="
check "part4_metrics.txt contains ollama_models_loaded" \
    "grep -q 'ollama_models_loaded' $SUBDIR/part4_metrics.txt"
check "part4_metrics.txt contains ollama_model_size_bytes" \
    "grep -q 'ollama_model_size_bytes' $SUBDIR/part4_metrics.txt"
check "part4_prom_query.json status == success" \
    "python3 -c \"import json; d=json.load(open('$SUBDIR/part4_prom_query.json')); assert d['status']=='success'\""
check "part4_prom_query.json has >= 3 results" \
    "python3 -c \"import json; d=json.load(open('$SUBDIR/part4_prom_query.json')); assert len(d['data']['result'])>=3\""

echo "=== Part 5 ==="
check "policy.md exists" \
    "test -f $SUBDIR/policy.md"
check "policy.md >= 600 words" \
    "test \$(wc -w < $SUBDIR/policy.md) -ge 600"
check "policy.md has all 8 sections" \
    "python3 -c \"
import re, sys
t = open('$SUBDIR/policy.md').read()
missing = [str(i) for i in range(1,9) if not re.search(rf'\b{i}\.', t)]
sys.exit(1 if missing else 0)
\""
check "policy.md >= 6 prohibited types with Rationale" \
    "test \$(grep -c '— Rationale:' $SUBDIR/policy.md) -ge 6"
check "policy.md contains 'prompt injection'" \
    "grep -qi 'prompt injection' $SUBDIR/policy.md"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ $FAIL -eq 0 ] && echo "All checks pass — your VM is ready for grading." || echo "Fix the failures above before the lab deadline."
```

---

## Grading

| Item | Points | Automated check |
|---|---|---|
| `part1_models.txt` — all 3 models present | 5 | grep for each model name |
| `part1_service.txt` — value is `active` | 5 | exact match |
| `part1_override.txt` — `OLLAMA_MAX_LOADED_MODELS=2` and `OLLAMA_NUM_PARALLEL=4` | 5 | grep both strings |
| `benchmark_results.json` — valid JSON, 9 entries, all `tokens_per_sec > 0` | 10 | schema + value check |
| `part2_summary.json` — `ratio_1b_to_7b_short > 1.0` and consistent with benchmark data | 10 | value range + cross-check |
| `part3_auth_test.json` — status codes 200, 401, 403 | 15 | exact value match |
| `part3_auth_directive.txt` — contains `auth_request` | 10 | grep case-insensitive |
| `part4_metrics.txt` — contains `ollama_models_loaded` and `ollama_model_size_bytes` | 10 | grep both strings |
| `part4_prom_query.json` — `status == "success"`, ≥ 3 results with `model` labels | 5 | JSON field checks |
| `policy.md` — all 8 sections, ≥ 6 items with `— Rationale:`, "prompt injection" present | 15 | grep + wc |
| `policy.md` — ≥ 600 words | 10 | `wc -w` |
| **Total** | **100** | |

---

[← Prev: Part 5](part5)

[← Back to Labs]({{ site.baseurl }}/labs/)
