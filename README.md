# LLM Command Executor

> Transform natural language into executable Linux commands using AI

A terminal tool that lets you describe what you want to do in plain English and automatically generates and executes the appropriate Linux commands using a local LLM (via Ollama).

## 🚀 Features

- 🗣️ **Natural Language Interface** - Describe commands in plain English
- 🤖 **Local LLM Powered** - Uses Ollama for privacy and offline capability
- 🔒 **Safety First** - Always shows commands before execution with confirmation prompt
- 🎨 **Color-Coded Output** - Easy-to-read terminal feedback
- 🔧 **Two Versions** - Bash (full-featured) and POSIX sh (maximum compatibility)
- 🌐 **Remote LLM Support** - Connect to Ollama running on different machines
- ⚡ **Fast & Efficient** - Quick command generation and execution

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [Examples](#examples)
- [Choosing the Right Version](#choosing-the-right-version)
- [Troubleshooting](#troubleshooting)
- [Security](#security)
- [Contributing](#contributing)
- [License](#license)

## 📦 Prerequisites

- **Ollama** installed and running (local or remote)
- **curl** (for API calls)
- **Basic shell** (`sh` or `bash` depending on version)
- A compatible LLM model downloaded in Ollama (e.g., `llama2`, `codellama`, `mistral`)

### Installing Ollama

```bash
# Linux
curl -fsSL https://ollama.ai/install.sh | sh

# macOS
brew install ollama

# Start Ollama
ollama serve
```

### Download a Model

```bash
# Recommended models for command generation
ollama pull llama2          # Good general purpose (3.8GB)
ollama pull codellama       # Best for code/commands (3.8GB)
ollama pull mistral         # Fast and efficient (4.1GB)
```

## 🔧 Installation

### Quick Install

```bash
# Download the script (choose bash or sh version)
curl -o llm-exec.sh https://raw.githubusercontent.com/yourusername/llm-exec/main/llm-exec.sh

# Make it executable
chmod +x llm-exec.sh

# Move to system PATH
sudo mv llm-exec.sh /usr/local/bin/llm-exec
```

### Manual Install

1. Copy the script content from this repository
2. Create a new file: `nano llm-exec.sh`
3. Paste the content
4. Save and exit
5. Make executable: `chmod +x llm-exec.sh`
6. Move to PATH: `sudo mv llm-exec.sh /usr/local/bin/llm-exec`

## ⚙️ Configuration

### Basic Configuration

Set environment variables in your shell profile (`~/.bashrc`, `~/.zshrc`, or `~/.profile`):

```bash
# Ollama server URL (default: http://localhost:11434)
export OLLAMA_HOST="http://localhost:11434"

# Model to use (default: llama2)
export OLLAMA_MODEL="codellama"
```

Apply changes:
```bash
source ~/.bashrc
```

### Remote Ollama Setup

If you want to run Ollama on a different machine (e.g., a powerful desktop or server) and access it from other devices:

#### On the Ollama Server Machine:

**1. Stop the Ollama service:**
```bash
sudo systemctl stop ollama
```

**2. Edit the systemd service file:**
```bash
sudo systemctl edit ollama.service
```

**3. Add these lines:**
```ini
[Service]
Environment="OLLAMA_HOST=0.0.0.0:11434"
```

**4. Save and reload:**
```bash
sudo systemctl daemon-reload
sudo systemctl restart ollama
```

**5. Verify it's working:**
```bash
sudo systemctl status ollama
```

**6. Configure firewall (if enabled):**
```bash
sudo ufw allow 11434
```

#### On Client Machines:

```bash
# Point to your Ollama server IP
export OLLAMA_HOST="http://192.168.1.100:11434"
```

**Test the connection:**
```bash
curl http://192.168.1.100:11434/api/tags
```

## 📖 Usage

### Basic Syntax

```bash
llm-exec "your request in natural language"
```

### Workflow

1. Type your request in natural language
2. LLM generates the appropriate command
3. Review the generated command
4. Confirm execution (y/n)
5. See the results

### Optional Aliases

Add to your shell profile for convenience:

```bash
alias llm="llm-exec"
alias ai="llm-exec"
alias cmd="llm-exec"
```

Now you can use: `ai "your request"`

## 💡 Examples

### File Operations

```bash
# Find files
llm-exec "find all PDF files in current directory"
# Generates: find . -name "*.pdf"

llm-exec "find files modified in the last 24 hours"
# Generates: find . -type f -mtime -1

llm-exec "search for files larger than 100MB"
# Generates: find . -type f -size +100M

# File manipulation
llm-exec "count lines in all Python files"
# Generates: find . -name "*.py" -exec wc -l {} +
```

### System Monitoring

```bash
llm-exec "show me the largest files in this directory"
# Generates: du -ah --max-depth=1 | sort -hr | head -n 10

llm-exec "show running processes sorted by memory usage"
# Generates: ps aux --sort=-%mem | head -n 20

llm-exec "check disk usage"
# Generates: df -h

llm-exec "show CPU temperature"
# Generates: sensors
```

### Text Processing

```bash
llm-exec "search for TODO comments in all code files"
# Generates: grep -r "TODO" --include="*.py" --include="*.js" .

llm-exec "count occurrences of word error in log files"
# Generates: grep -o "error" *.log | wc -l

llm-exec "find all unique IP addresses in access.log"
# Generates: grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" access.log | sort -u
```

### Network Operations

```bash
llm-exec "show all open ports"
# Generates: netstat -tuln

llm-exec "check if port 8080 is open"
# Generates: nc -zv localhost 8080

llm-exec "show active network connections"
# Generates: ss -tunapl
```

### Git Operations

```bash
llm-exec "show git log for last 5 commits"
# Generates: git log -5 --oneline

llm-exec "find all branches containing the word feature"
# Generates: git branch -a | grep feature

llm-exec "show files changed in last commit"
# Generates: git diff --name-only HEAD~1
```

## 🎯 Choosing the Right Version

### Bash Version (llm-exec-bash.sh)

**Use when:**
- You have modern Linux with bash installed
- You want the best user experience
- You need single-character confirmation (`y` without pressing Enter)
- Your system: Ubuntu, Debian, Fedora, Arch, most desktop Linux

**Features:**
- Rich colored output
- Single-key confirmation
- Better error messages
- Modern bash features

### POSIX sh Version (llm-exec-sh.sh)

**Use when:**
- You're on minimal/embedded systems
- Bash is not available
- You need maximum compatibility
- Your system: NAS devices, BusyBox, Alpine Linux, embedded systems

**Features:**
- Works on any POSIX-compliant shell
- Minimal dependencies
- Smaller footprint
- Universal compatibility

**Check your shell:**
```bash
echo $SHELL           # See your default shell
which bash            # Check if bash is available
sh --version          # Check sh version
```

## 🐛 Troubleshooting

### "Failed to connect to Ollama"

**Problem:** Can't reach the Ollama server

**Solutions:**
```bash
# Check if Ollama is running
curl http://localhost:11434/api/tags

# Start Ollama (if local)
ollama serve

# Check systemd service
sudo systemctl status ollama
sudo systemctl restart ollama

# For remote Ollama, verify network connectivity
ping YOUR_OLLAMA_SERVER_IP
curl http://YOUR_OLLAMA_SERVER_IP:11434/api/tags

# Check firewall
sudo ufw status
sudo ufw allow 11434
```

### "LLM did not return a valid command"

**Problem:** The LLM response couldn't be parsed

**Solutions:**
- Try a different model: `export OLLAMA_MODEL="codellama"`
- Make your request more specific
- Check if the model is fully downloaded: `ollama list`
- Restart Ollama: `sudo systemctl restart ollama`

### "Command exited with code 1"

**Problem:** The generated command failed

**Common causes:**
- Wrong command syntax for your system (GNU vs BSD tools)
- Missing required tools
- Permission issues
- File/directory doesn't exist

**Solutions:**
- Check if required tools are installed
- Try running the command manually to see the full error
- Rephrase your request to be more specific
- Check file permissions

### Colors Not Showing

**Problem:** Terminal doesn't display colors

**Solution:**
```bash
# Check terminal support
echo $TERM

# Try setting TERM
export TERM=xterm-256color
```

### Unicode Character Issues

**Problem:** Commands have garbled characters

**Solution:**
- The script handles this automatically with `decode_unicode()`
- If issues persist, check locale settings: `locale`
- Set UTF-8: `export LC_ALL=en_US.UTF-8`

## 🔒 Security

### Important Security Considerations

⚠️ **This tool executes commands on your system. Always review commands before execution!**

### Best Practices

1. **Always review generated commands** before confirming execution
2. **Never run as root** unless absolutely necessary
3. **Be extra careful with destructive commands** (rm, dd, mkfs, format, etc.)
4. **Test in safe directories** first
5. **Use read-only operations** when learning
6. **Keep logs** of executed commands for audit trails
7. **Don't blindly trust the LLM** - it can make mistakes

### Dangerous Commands to Watch For

- `rm -rf /` or `rm -rf /*` - Deletes everything
- `dd if=/dev/zero of=/dev/sda` - Wipes disk
- `chmod -R 777 /` - Makes everything world-writable
- `:(){ :|:& };:` - Fork bomb
- `mkfs.*` - Formats drives

### Network Security

When exposing Ollama on `0.0.0.0`:
- Only do this on trusted networks
- Use firewall rules to restrict access
- Consider VPN for remote access
- Monitor access logs regularly

## 🎨 Customization

### Custom System Prompt

Edit the script to modify how the LLM generates commands:

```bash
system_prompt="You are a Linux command generator specialized in 
file operations. Generate commands that are safe and use long-form 
flags for clarity..."
```

### Adding Command Aliases

Create shortcuts for common operations:

```bash
# Add to ~/.bashrc
alias find-large="llm-exec 'find files larger than 100MB'"
alias show-ports="llm-exec 'show all listening ports'"
alias git-status="llm-exec 'show git status with branch info'"
```

### Logging Executed Commands

Add this to the script before `eval "$COMMAND"`:

```bash
# Log to file
echo "$(date '+%Y-%m-%d %H:%M:%S') - $COMMAND" >> ~/.llm-exec.log
```

## 📊 Performance Tips

### Model Selection

| Model | Size | Speed | Quality | Best For |
|-------|------|-------|---------|----------|
| TinyLlama | 1.1GB | ⚡⚡⚡ | ⭐⭐ | Testing, limited resources |
| Llama2 7B | 3.8GB | ⚡⚡ | ⭐⭐⭐ | General use |
| CodeLlama 7B | 3.8GB | ⚡⚡ | ⭐⭐⭐⭐ | Command generation |
| Mistral 7B | 4.1GB | ⚡⚡ | ⭐⭐⭐⭐ | Balanced performance |
| CodeLlama 13B | 7.4GB | ⚡ | ⭐⭐⭐⭐⭐ | Best quality |

**Recommendation:** Use `codellama:7b` for the best balance of speed and quality.

### Ollama Performance Tuning

```bash
# Use GPU acceleration (if available)
export OLLAMA_NUM_GPU=1

# Adjust context window
export OLLAMA_NUM_CTX=2048

# Set thread count
export OLLAMA_NUM_THREADS=8
```

## 🤝 Contributing

Contributions are welcome! Here are some ways you can help:

- 🐛 Report bugs
- 💡 Suggest new features
- 📝 Improve documentation
- 🔧 Submit pull requests
- ⭐ Star the repository

### Development Setup

```bash
# Clone the repository
git clone https://github.com/yourusername/llm-exec.git
cd llm-exec

# Test the script
./llm-exec.sh "list files"

# Run with debug mode (add to script)
set -x  # Enable debug mode
```

## 📄 License

MIT License - feel free to use, modify, and distribute.

## 🙏 Acknowledgments

- [Ollama](https://ollama.ai) - For making local LLMs accessible
- The open-source LLM community
- Contributors and users who provide feedback

## 📞 Support

- 📖 [Full Documentation](link-to-blog-post)
- 🐛 [Issue Tracker](https://github.com/yourusername/llm-exec/issues)
- 💬 [Discussions](https://github.com/yourusername/llm-exec/discussions)

## 🗺️ Roadmap

- [ ] Command history and favorites
- [ ] Interactive mode for multiple commands
- [ ] Explanation mode (ask LLM to explain commands)
- [ ] Template system for common operations
- [ ] Web UI interface
- [ ] Support for other LLM providers (OpenAI, Anthropic)
- [ ] Command validation and safety checks
- [ ] Multi-language support

---

**Made with ❤️ by developers who forget command syntax**

*Remember: With great power comes great responsibility. Always review commands before execution!*
