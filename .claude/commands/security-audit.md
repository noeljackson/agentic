---
name: security-audit
description: Run comprehensive macOS security audit - check for malware, suspicious processes, unauthorized access
user_invocable: true
---

# Security Audit

Run a comprehensive security audit on this macOS system. Check for signs of compromise, malware, or unauthorized access.

## Checks to Perform

### 1. Process Analysis
```bash
# Full process list with parent processes
ps -ae -o pid,ppid,user,%cpu,%mem,command | head -150

# Check for suspicious process names
ps aux | grep -E "nc |netcat|ncat|socat|perl.*-e|python.*-c|ruby.*-e|php.*-r|bash.*-i|/tmp/|/var/tmp/" | grep -v grep
```

### 2. Network Connections
```bash
# Active connections - look for unusual destinations
lsof -i -n -P | grep ESTABLISHED | head -50

# Listening ports - check for backdoors
lsof -i -n -P | grep LISTEN

# Check for connections to suspicious IPs
netstat -an | grep ESTABLISHED
```

### 3. System Integrity
```bash
# Verify critical binaries are Apple-signed
codesign -vvv /usr/bin/login /bin/zsh /bin/bash /usr/sbin/sshd 2>&1

# Check SIP and Gatekeeper status
csrutil status
spctl --status

# Check for kernel extensions (non-Apple)
kextstat | grep -v com.apple
```

### 4. Persistence Mechanisms
```bash
# User launch agents
ls -la ~/Library/LaunchAgents/

# System launch agents/daemons (non-Apple)
ls -la /Library/LaunchAgents/ /Library/LaunchDaemons/ | grep -v "com.apple"

# Cron jobs
crontab -l 2>/dev/null

# Login items
osascript -e 'tell application "System Events" to get name of every login item' 2>/dev/null
```

### 5. PAM Configuration
```bash
# Check PAM files for modifications
ls -la /etc/pam.d/
cat /etc/pam.d/login
cat /etc/pam.d/sudo
```

### 6. SSH Security
```bash
# Authorized keys
cat ~/.ssh/authorized_keys 2>/dev/null

# SSH config
cat ~/.ssh/config 2>/dev/null | head -30

# Check sshd config for backdoors
grep -E "^(PermitRootLogin|PasswordAuthentication|AuthorizedKeysFile)" /etc/ssh/sshd_config 2>/dev/null
```

### 7. Recently Modified Files
```bash
# Recently modified binaries in common attack locations
find /usr/local/bin /opt /tmp /var/tmp -type f -mtime -1 2>/dev/null

# Recently modified in home
find ~ -type f -mtime -1 -name ".*" 2>/dev/null | head -20
```

### 8. User Account Integrity
```bash
# Check user shell
dscl . -read /Users/$USER UserShell

# Check authentication authority
dscl . -read /Users/$USER AuthenticationAuthority

# Terminal shell settings
defaults read com.apple.Terminal Shell 2>/dev/null
defaults read com.googlecode.iterm2 "New Bookmarks" 2>/dev/null | grep -A3 '"Command"'
```

### 9. Browser Extensions (check manually)
- Chrome: chrome://extensions
- Brave: brave://extensions
- Firefox: about:addons
- Safari: Safari > Settings > Extensions

### 10. Environment Variables
```bash
# Check for library injection
env | grep -i "DYLD\|LD_"

# Check shell profile for suspicious additions
tail -20 ~/.zshrc ~/.zprofile ~/.bashrc ~/.bash_profile 2>/dev/null
```

## Red Flags to Watch For

- Processes with high CPU from /tmp or /var/tmp
- Connections to unusual IP addresses or ports
- Non-Apple kernel extensions
- Modified PAM files
- Unauthorized SSH keys
- DYLD_INSERT_LIBRARIES or similar env vars
- Recently modified dotfiles you didn't change
- Unknown launch agents/daemons

## After the Audit

Report findings as:
- **CLEAN**: No issues found
- **SUSPICIOUS**: Items requiring investigation (list them)
- **COMPROMISED**: Clear signs of malware (immediate action needed)

Include specific remediation steps for any issues found.
