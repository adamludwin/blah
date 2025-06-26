#!/bin/bash

deploy() {
  # Handle commit message
  if [ -z "$1" ]; then
    echo "Quick commit options:"
    echo "1. fix: bug fixes"
    echo "2. feat: new feature" 
    echo "3. style: UI changes"
    echo "Or enter custom message:"
    echo -n "Choice: "
    read choice
    
    case "$choice" in
      1)
        COMMIT_MSG="fix: bug fixes"
        ;;
      2)
        COMMIT_MSG="feat: new feature"
        ;;
      3)
        COMMIT_MSG="style: UI changes"
        ;;
      "")
        echo "❌ No commit message provided. Exiting."
        return 1
        ;;
      *)
        COMMIT_MSG="$choice"
        ;;
    esac
  else
    COMMIT_MSG="$*"
  fi

  echo -e "\n\033[33m🟡 Running: git status\033[0m"
  git status

  echo -e "\n🟡 Running: git add ."
  git add .

  echo -e "\n🟡 Running: git commit -m \"$COMMIT_MSG\""
  git commit -m "$COMMIT_MSG"

  echo -e "\n🟡 Running: git push origin main"
  git push origin main

  echo -e "\n⏳ Waiting for Vercel to pick up the deployment..."
  sleep 8  # Give Vercel a bit more time to detect the push

  # Get the most recent deployment URL
  echo -e "\n🔍 Finding the latest deployment..."
  DEPLOYMENT_URL=$(vercel ls 2>/dev/null | grep -o 'https://[^[:space:]]*' | head -n1)
  
  if [ -z "$DEPLOYMENT_URL" ]; then
    echo "⚠️  Could not find any deployments."
    return 1
  fi
  
  echo "📦 Monitoring deployment: $DEPLOYMENT_URL"
  
  # Monitor the deployment status
  echo -e "\n🔄 Checking deployment status..."
  while true; do
    # Save vercel output to temp file for easier parsing
    TEMP_FILE="/tmp/vercel_status_$$.txt"
    vercel inspect "$DEPLOYMENT_URL" > "$TEMP_FILE" 2>&1
    
    if [ $? -ne 0 ]; then
      echo "❌ Could not inspect deployment. URL might be invalid."
      echo "🔗 Try checking manually: $DEPLOYMENT_URL"
      rm -f "$TEMP_FILE"
      return 1
    fi
    
    # Extract status - look for the status line and get the word after ●
    STATE=$(grep 'status' "$TEMP_FILE" | sed 's/.*● *//' | awk '{print $1}')
    
    # Clean up temp file
    rm -f "$TEMP_FILE"
    
    if [ -z "$STATE" ]; then
      echo "⚠️  Could not parse deployment state. Let me show you what I got:"
      vercel inspect "$DEPLOYMENT_URL" | head -15
      return 1
    fi
    
    case "$STATE" in
      "Building"|"Queued"|"Initializing")
        echo "🔄 Status: $STATE (still working...)"
        sleep 5
        ;;
      "Ready")
        echo -e "\n\033[32m✅ Deployment READY! 🎉\033[0m"
        echo "🔗 URL: $DEPLOYMENT_URL"
        # Play success sound
        afplay /System/Library/Sounds/Hero.aiff &
        # Success notification
        osascript -e 'display notification "Deployment successful!" with title "🚀 Vercel Deploy"' &
        break
        ;;
      "Error"|"Failed"|"Canceled")
        echo -e "\n\033[31m❌ Deployment FAILED!\033[0m"
        echo "🔗 Check logs: $DEPLOYMENT_URL"
        # Play failure sound
        afplay /System/Library/Sounds/Basso.aiff &
        # Failure notification  
        osascript -e 'display notification "Deployment failed!" with title "💥 Vercel Deploy" sound name "Basso"' &
        return 1
        ;;
      *)
        echo "🤔 Unknown state: $STATE (continuing to monitor...)"
        sleep 5
        ;;
    esac
  done

  echo -e "\n✅ All done!"
} 