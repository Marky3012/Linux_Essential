Smart Recon (snippet)

Run the script in dry-run mode to preview what will be executed and generate a report without installing or running external tools:

```bash
# run non-interactively for example.com, only DNS tools dig and host
./smart_recon.sh --target example.com --categories 1 --tools dig,host --dry-run
```

The report will be saved to the `reports/` directory (default `reports/smart_recon_report.md`).

Using Google AI Studio (Gemini) via HTTP API
-------------------------------------------
If you want the script to call Google AI Studio (Gemini) via the HTTP endpoint, set these environment variables before running with `--summarize`:

- `LLM_API_URL` — The Google AI Studio endpoint URL for your model (for example the REST endpoint provided by AI Studio)
- `GOOGLE_AI_STUDIO_API_KEY` — Your API key from Google AI Studio

Example (replace with your actual endpoint and key):

```bash
export LLM_API_URL="https://api.oauth2.ai.google/v1/your-model-endpoint"
export GOOGLE_AI_STUDIO_API_KEY="ya29.your_api_key_here"
./smart_recon.sh --target example.com --categories 1 --tools dig,host --summarize
```

Notes:
- The summarizer will use the AI Studio key as a Bearer token. If your AI Studio setup requires the key as a query parameter, set `GOOGLE_AI_USE_QUERY=1` to include it in the URL as `?key=...`.
- For a more robust production integration use the official Google Cloud client libraries and service accounts (see Vertex AI option in the code).

Environment file (.env)
------------------------
You can store confidential credentials in a local `.env` file (do NOT commit it). A `.env.example` file is provided. To use it:

```bash
cp .env.example .env
# edit .env and add your keys
source .env
./smart_recon.sh --target example.com --categories 1 --tools dig,host --summarize
```

The repository includes a folder-level `.gitignore` that ignores `.env` and enhanced reports by default.
