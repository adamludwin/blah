#!/bin/bash

# Vercel Deploy Script Installer
echo "🚀 Installing Vercel Deploy Script..."

# Detect shell
SHELL_NAME=$(basename "$SHELL")
if [[ "$SHELL_NAME" == "zsh" ]]; then
    SHELL_RC="$HOME/.zshrc"
elif [[ "$SHELL_NAME" == "bash" ]]; then
    SHELL_RC="$HOME/.bashrc"
else
    echo "⚠️  Unsupported shell: $SHELL_NAME"
    echo "Please manually add the script to your shell configuration."
    exit 1
fi

# Create installation directory
INSTALL_DIR="$HOME/.vercel-deploy-script"
mkdir -p "$INSTALL_DIR"

# Download the script
echo "📥 Downloading deploy script..."
curl -L https://raw.githubusercontent.com/adamludwin/blah/main/deploy.sh -o "$INSTALL_DIR/deploy.sh"

if [ $? -ne 0 ]; then
    echo "❌ Failed to download script"
    exit 1
fi

# Make it executable
chmod +x "$INSTALL_DIR/deploy.sh"

# Add to shell configuration if not already present
if ! grep -q "vercel-deploy-script" "$SHELL_RC"; then
    echo "" >> "$SHELL_RC"
    echo "# Vercel Deploy Script" >> "$SHELL_RC"
    echo "source $INSTALL_DIR/deploy.sh" >> "$SHELL_RC"
    echo "✅ Added to $SHELL_RC"
else
    echo "✅ Already configured in $SHELL_RC"
fi

echo ""
echo "🎉 Installation complete!"
echo ""
echo "To start using the script:"
echo "1. Restart your terminal, or run: source $SHELL_RC"
echo "2. Navigate to your project directory"
echo "3. Run: deploy"
echo ""
echo "Prerequisites:"
echo "• Vercel CLI installed: npm i -g vercel"
echo "• Vercel authenticated: vercel login"
echo "• GitHub ↔ Vercel integration configured"
echo ""
echo "Happy deploying! 🚀" 