# 🚀 Vercel Deploy Script

A powerful bash script that automates your entire deployment workflow from git commit to Vercel deployment monitoring with real-time feedback.

## ✨ Features

- **Smart commit messages** with interactive menu or custom input
- **Automated git workflow** (status → add → commit → push)
- **Real-time Vercel monitoring** tracks deployment status from Building → Ready
- **Audio feedback** with system sounds (success/failure)
- **macOS notifications** for deployment results
- **Colorized terminal output** for better readability
- **One-command deployment** for maximum productivity

## 🎬 Demo

```bash
$ blah
Quick commit options:
1. fix: bug fixes
2. feat: new feature
3. style: UI changes
Or enter custom message:
Choice: 1

🟡 Running: git status
🟡 Running: git add .
🟡 Running: git commit -m "fix: bug fixes"
🟡 Running: git push origin main

⏳ Waiting for Vercel to pick up the deployment...
🔍 Finding the latest deployment...
📦 Monitoring deployment: https://your-app-xyz.vercel.app

🔄 Status: Building (still working...)
🔄 Status: Building (still working...)
✅ Deployment READY! 🎉
🔗 URL: https://your-app-xyz.vercel.app

✅ All done!
```

## 📋 Prerequisites

- **macOS** (for system sounds and notifications)
- **Git** configured with your repository
- **Vercel CLI** installed and authenticated (`npm i -g vercel`)
- **GitHub ↔ Vercel integration** set up for automatic deployments

## 🛠 Installation

### Option 1: Quick Install (Recommended)

```bash
# Download and install
curl -L https://raw.githubusercontent.com/adamludwin/blah/main/install.sh | bash
```

### Option 2: Manual Install

```bash
# Clone the repository
git clone https://github.com/adamludwin/blah.git
cd blah

# Make it executable
chmod +x deploy.sh

# Add to your shell profile
echo "source $(pwd)/deploy.sh" >> ~/.zshrc  # for zsh
# OR
echo "source $(pwd)/deploy.sh" >> ~/.bashrc  # for bash

# Reload your shell
source ~/.zshrc  # or ~/.bashrc
```

## 🎯 Usage

### Interactive Mode
```bash
blah
# Shows menu with options 1-3 or custom message
```

### Direct Message
```bash
blah "feat: add new dashboard component"
blah "fix: resolve mobile layout issue"
blah "style: update button colors"
```

## 🔧 Configuration

The script works out of the box, but you can customize:

### Change Sound Effects
Edit the sound files in `deploy.sh`:
```bash
# Success sound (line ~67)
afplay /System/Library/Sounds/Hero.aiff &

# Failure sound (line ~74) 
afplay /System/Library/Sounds/Basso.aiff &
```

Available macOS sounds: `Basso`, `Blow`, `Bottle`, `Frog`, `Funk`, `Glass`, `Hero`, `Morse`, `Ping`, `Pop`, `Purr`, `Sosumi`, `Submarine`, `Tink`

### Customize Quick Commit Messages
Edit the predefined messages (lines ~8-10):
```bash
echo "1. fix: bug fixes"
echo "2. feat: new feature" 
echo "3. style: UI changes"
```

## 🎵 Audio & Notifications

- **🎊 Success**: Hero sound + "Deployment successful!" notification
- **💥 Failure**: Basso sound + "Deployment failed!" notification  
- **🔕 Silent mode**: Comment out `afplay` lines to disable sounds

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built for developers who love streamlined workflows
- Inspired by the need for better deployment feedback
- Uses Vercel's excellent CLI and deployment platform

## 🐛 Issues & Support

If you encounter any issues or have suggestions:
1. Check existing [Issues](https://github.com/adamludwin/blah/issues)
2. Create a new issue with detailed information
3. Include your macOS version and Vercel CLI version

---

**Made with ❤️ for the developer community** 