# colab-cli Command Reference

Source: https://github.com/xeodou/colab-cli

## Commands

### auth
Authenticate with Google account via OAuth2.
```bash
colab-cli auth
```
Opens browser for consent. Token cached at `~/.config/colab-cli/token.json`.

### exec
Execute code on a Colab runtime.
```bash
# Execute a notebook (all cells)
colab-cli exec notebook.ipynb

# Execute a Python file
colab-cli exec script.py

# Execute inline code
colab-cli exec -c "import torch; print(torch.cuda.is_available())"
```
Output is streamed in real-time via WebSocket connection to the Jupyter kernel.

### upload
Upload a local file to the Colab runtime filesystem.
```bash
colab-cli upload local_file.ipynb
colab-cli upload data.csv
```

### download
Download a file from the Colab runtime to local.
```bash
colab-cli download /content/results.csv ./results.csv
colab-cli download /content/drive/MyDrive/output.png ./output.png
```

### quota
Display remaining Colab compute quota.
```bash
colab-cli quota
```
Shows GPU hours remaining, current runtime type.

### status
Show current runtime information.
```bash
colab-cli status
```
Shows: connection state, RAM usage, disk usage, GPU type (if any).

### stop
Release the current Colab runtime.
```bash
colab-cli stop
```
Frees GPU/TPU resources. Data in `/content/` is lost (use Drive for persistence).

## Requirements

- Go 1.21+ (for installation)
- Google account with Colab access
- Network access to Google services

## Limitations

- OAuth2 test app: max 100 users, "unverified app" warning on first auth
- Colab free tier: ~12 hour session limit, 90 min idle timeout
- GPU availability depends on Colab quota and demand
