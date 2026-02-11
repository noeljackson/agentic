View Gitea Actions workflow runs for the sonica repository.

## Steps

1. Get the Gitea token from Infisical:
   ```bash
   TOKEN=$(infisical secrets get GITEA_REGISTRY_TOKEN --path /ci --plain)
   ```

2. Query the Gitea API for recent workflow runs:
   ```bash
   curl -s -H "Authorization: token $TOKEN" \
     "https://git.noel.sh/api/v1/repos/sonica/sonica/actions/runs?limit=15"
   ```

3. Parse and display the results. The API returns:
   - `status`: "queued", "running", "completed"
   - `conclusion`: "success", "failure", "cancelled" (only for completed runs)

   Use icons based on status + conclusion:
   - ✅ completed + success
   - ❌ completed + failure
   - ⚠️ completed + cancelled
   - ⏳ queued
   - 🔄 running

4. Display format: `ICON #RUN_NUMBER TITLE (WORKFLOW)`

5. Show link to web UI: https://git.noel.sh/sonica/sonica/actions

## Example jq Command

```bash
jq -r '.workflow_runs[:15][] |
  "\(if .status == "queued" then "⏳"
    elif .status == "running" then "🔄"
    elif .conclusion == "success" then "✅"
    elif .conclusion == "failure" then "❌"
    elif .conclusion == "cancelled" then "⚠️"
    else "❓" end) #\(.run_number) \(.display_title | .[0:45]) (\(.path | split("@")[0]))"'
```

## Important

- Use `git.noel.sh` as the Gitea URL (NOT git.sonica.cloud)
- Token is at Infisical path `/ci` with key `GITEA_REGISTRY_TOKEN`
- API returns all runs - use jq slice `[:15]` to limit output
- `display_title` contains the commit message
- `path` contains workflow file like "deploy.yml@refs/heads/main"
