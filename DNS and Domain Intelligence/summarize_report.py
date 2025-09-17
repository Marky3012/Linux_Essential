#!/usr/bin/env python3
"""
summarize_report.py

Reads a report markdown file and produces an enhanced report with a summary and insights.
- In DRY_RUN mode (env DRY_RUN=1) it produces a placeholder summary.
- Otherwise it can call an LLM API. This script supports a generic HTTP JSON API (POST) and
  includes a helper to call Google Vertex AI (Gemini) if environment variables are set.

Environment variables (optional):
- DRY_RUN=1                -> Create a placeholder summary (no network calls)
- LLM_API_URL              -> Generic LLM endpoint URL that accepts JSON {"prompt": "..."}
- LLM_API_KEY              -> API key for the generic endpoint (sent as Authorization: Bearer)
- GOOGLE_VERTEX_PROJECT    -> If set, use Vertex AI client (requires google-cloud-aiplatform installed and configured)
- GOOGLE_VERTEX_LOCATION   -> Vertex location (e.g. "us-central1")
- GOOGLE_VERTEX_MODEL      -> Model resource name or id (e.g. "models/text-bison@001")

Usage:
    summarize_report.py <input_report.md> <output_enhanced.md>

"""
import os
import sys
import json
from textwrap import shorten

try:
    import requests
except Exception:
    requests = None


def load_report(path):
    with open(path, 'r', encoding='utf-8') as f:
        return f.read()


def write_enhanced(path, content):
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)


def generate_placeholder_summary(report_text):
    lines = [l.strip() for l in report_text.splitlines() if l.strip()]
    top_lines = '\n'.join(lines[:20])
    summary = (
        "Summary (DRY_RUN placeholder):\n"
        "This is a placeholder summary generated in DRY_RUN mode.\n\n"
        "Top content excerpt:\n" + shorten(top_lines, width=800)
    )
    insights = "Insights:\n- No network calls performed; this is a dry-run summary."
    return summary + "\n\n" + insights


def call_generic_llm(api_url, api_key, prompt):
    if requests is None:
        raise RuntimeError("requests library is required to call external LLM endpoints")
    headers = {"Content-Type": "application/json"}
    # Prefer Authorization header; some services (e.g. older Google AI Studio setups) also accept the key as a query param
    if api_key:
        headers["Authorization"] = f"Bearer {api_key}"
    payload = {"prompt": prompt, "max_tokens": 800}
    # Allow using query param if explicitly requested via env var
    use_query = os.environ.get("GOOGLE_AI_USE_QUERY", "0") == "1"
    url = api_url
    if api_key and use_query:
        sep = '&' if ('?' in url) else '?'
        url = f"{url}{sep}key={api_key}"
    resp = requests.post(url, headers=headers, json=payload, timeout=30)
    resp.raise_for_status()
    data = resp.json()
    # Expecting either {'text': '...'} or {'result': '...'} or {'output': '...'}
    for key in ("text", "result", "output", "choices"):
        if key in data:
            if key == "choices":
                return data["choices"][0].get("text") or data["choices"][0].get("message", {}).get("content")
            return data[key]
    return json.dumps(data, indent=2)


def call_vertex_ai(prompt):
    # Lazy import to avoid hard dependency unless used
    try:
        from google.cloud import aiplatform
    except Exception as e:
        raise RuntimeError("google-cloud-aiplatform is required for Vertex AI calls: " + str(e))
    project = os.environ.get("GOOGLE_VERTEX_PROJECT")
    location = os.environ.get("GOOGLE_VERTEX_LOCATION", "us-central1")
    model = os.environ.get("GOOGLE_VERTEX_MODEL")
    if not (project and model):
        raise RuntimeError("GOOGLE_VERTEX_PROJECT and GOOGLE_VERTEX_MODEL must be set for Vertex AI calls")
    client = aiplatform.PredictionServiceClient()
    endpoint = client.endpoint_path(project=project, location=location, endpoint=model) if False else model
    # Create a simple request — precise usage depends on the model signature
    response = client.predict(
        endpoint=endpoint,
        instances=[{"content": prompt}],
        parameters={"temperature": 0.2},
    )
    # Extract text output depending on model
    if response and response.predictions:
        return str(response.predictions[0])
    return str(response)


def build_prompt(report_text):
    # Build a compact prompt asking the LLM to summarize findings and list insights.
    prompt = (
        "You are an expert security analyst. Summarize the following reconnaissance report in 4 parts:\n"
        "1) Short summary (3 sentences)\n"
        "2) Key findings and evidence (bullet list)\n"
        "3) Actionable next steps (bullet list)\n"
        "4) Potential false positives or missing data (bullet list)\n\n"
        "Report:\n" + report_text
    )
    return prompt


def main(argv):
    if len(argv) < 3:
        print("Usage: summarize_report.py <input_report.md> <output_enhanced.md>")
        sys.exit(2)
    inp = argv[1]
    out = argv[2]
    report = load_report(inp)
    if os.environ.get("DRY_RUN") == "1":
        enhanced = generate_placeholder_summary(report)
    else:
        # If GOOGLE_AI_STUDIO_API_KEY is provided along with LLM_API_URL use it (Google AI Studio)
        if os.environ.get("GOOGLE_AI_STUDIO_API_KEY") and os.environ.get("LLM_API_URL"):
            prompt = build_prompt(report)
            enhanced = call_generic_llm(os.environ.get("LLM_API_URL"), os.environ.get("GOOGLE_AI_STUDIO_API_KEY"), prompt)
        # Prefer Vertex AI if configured
        elif os.environ.get("GOOGLE_VERTEX_PROJECT") and os.environ.get("GOOGLE_VERTEX_MODEL"):
            prompt = build_prompt(report)
            enhanced = call_vertex_ai(prompt)
        elif os.environ.get("LLM_API_URL"):
            prompt = build_prompt(report)
            enhanced = call_generic_llm(os.environ.get("LLM_API_URL"), os.environ.get("LLM_API_KEY"), prompt)
        else:
            enhanced = (
                "No LLM configured. Set DRY_RUN=1 for placeholder output, or set LLM_API_URL/LLM_API_KEY or Google Vertex env vars.\n"
            )
    # Build an enhanced markdown file: original report + summary block
    enhanced_md = report + "\n\n---\n\n## Automated Summary and Insights\n\n" + enhanced
    write_enhanced(out, enhanced_md)
    print(f"Enhanced report written to: {out}")


if __name__ == '__main__':
    main(sys.argv)
