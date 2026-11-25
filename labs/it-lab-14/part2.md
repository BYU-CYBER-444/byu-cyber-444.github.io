---
title: "Part 2 - Inference Benchmarking"
parent: "IT LAB 14 - AI Inference Server Setup and Governance"
grand_parent: Labs
nav_order: 2
---

# Part 2 - Inference Benchmarking
{: .no_toc }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

Write a Python benchmarking script named `benchmark_inference.py`. Save it to your home directory and run it with `python3`. A reference implementation is provided below - read it, understand what each section does, then save and run it:

```python
#!/usr/bin/env python3
# Benchmark Ollama inference performance across models
import json
import time
import requests
import statistics

OLLAMA_URL = "http://localhost:11434"

MODELS = [
    "hf.co/bartowski/Llama-3.2-1B-Instruct-GGUF:Q4_K_M",
    "hf.co/bartowski/Llama-3.2-3B-Instruct-GGUF:Q4_K_M",
    "hf.co/bartowski/Mistral-7B-Instruct-v0.3-GGUF:Q4_K_M",
]
PROMPTS = [
    ("short", "What is DNS? Answer in one sentence."),
    ("medium", "Explain the difference between TCP and UDP in 3 paragraphs."),
    ("long", "Write a detailed explanation of how TLS 1.3 works, including the handshake process, key exchange, and cipher suites. Include specific differences from TLS 1.2."),
]

def benchmark_model(model, prompt_name, prompt, runs=3):
    times = []
    tokens = []
    for _ in range(runs):
        start = time.perf_counter()
        resp = requests.post(f"{OLLAMA_URL}/api/generate", json={
            "model": model,
            "prompt": prompt,
            "stream": False,
        }, timeout=300)
        elapsed = time.perf_counter() - start
        data = resp.json()
        times.append(elapsed)
        tokens.append(data.get("eval_count", 0))

    avg_time = statistics.mean(times)
    avg_tokens = statistics.mean(tokens)
    tok_per_sec = avg_tokens / avg_time if avg_time > 0 else 0

    return {
        "model": model,
        "prompt_type": prompt_name,
        "avg_latency_s": round(avg_time, 2),
        "avg_tokens": int(avg_tokens),
        "tokens_per_sec": round(tok_per_sec, 1),
    }

results = []
for model in MODELS:
    print(f"\nBenchmarking {model}...")
    for pname, prompt in PROMPTS:
        result = benchmark_model(model, pname, prompt)
        results.append(result)
        print(f"  {pname}: {result['tokens_per_sec']} tok/s, {result['avg_latency_s']}s latency")

# Print results table
print("\n\n=== BENCHMARK RESULTS ===")
print(f"{'Model':<40} {'Prompt':<10} {'Latency(s)':<12} {'Tok/s':<10}")
print("-" * 75)
for r in results:
    print(f"{r['model']:<40} {r['prompt_type']:<10} {r['avg_latency_s']:<12} {r['tokens_per_sec']:<10}")

with open("benchmark_results.json", "w") as f:
    json.dump(results, f, indent=2)
print("\nResults saved to benchmark_results.json")
```

**If a run times out:** The 7B model with the long prompt may approach the 300-second
timeout on a CPU-only server. If `requests.exceptions.Timeout` is raised, reduce
`runs=3` to `runs=1` for that model/prompt combination and re-run.

## Part 2 Capture Commands

```bash
cp benchmark_results.json ~/lab14-submission/

python3 << 'EOF' > ~/lab14-submission/part2_summary.json
import json, os

d = json.load(open(os.path.expanduser("~/lab14-submission/benchmark_results.json")))
short = {r["model"]: r["tokens_per_sec"] for r in d if r["prompt_type"] == "short"}
fastest = max(short, key=short.get)
m1b = next(m for m in short if "1B" in m)
m7b = next(m for m in short if "7B" in m or "Mistral" in m)
ratio = round(short[m1b] / short[m7b], 2)
candidates = {m: v for m, v in short.items() if "7B" not in m and "Mistral" not in m}
recommended = max(candidates, key=candidates.get)

import json as j
print(j.dumps({
    "ratio_1b_to_7b_short": ratio,
    "fastest_model_short_prompt": fastest,
    "recommended_model_5_concurrent_users": recommended
}, indent=2))
EOF
```

---

{: .highlight }
> **Before moving on - Part 2 complete when:**
> - The benchmark script ran to completion without errors for all three models
> - `benchmark_results.json` exists and contains 9 entries (3 models × 3 prompt types)
> - Every entry shows a `tokens_per_sec` value greater than zero
> - `part2_summary.json` shows a ratio greater than 1.0 (the 1B model should be faster than the 7B)

---

[← Prev: Part 1](part1) · [Next: Part 3 →](part3)

[← Back to Labs]({{ site.baseurl }}/labs/)
