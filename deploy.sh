#!/bin/bash

blah() {
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
        # Try to get a fresh fun fact from API
        api_fact=""
        
        # Try multiple APIs for variety
        case $((RANDOM % 4)) in
          0)
            # Useless Facts API
            api_fact=$(curl -s --max-time 3 "https://uselessfacts.jsph.pl/random.json?language=en" 2>/dev/null | grep -o '"text":"[^"]*"' | sed 's/"text":"//;s/"$//' | head -1)
            ;;
          1)
            # Cat Facts API
            api_fact=$(curl -s --max-time 3 "https://cat-fact.herokuapp.com/facts/random" 2>/dev/null | grep -o '"text":"[^"]*"' | sed 's/"text":"//;s/"$//' | head -1)
            ;;
          2)
            # Numbers API (random trivia)
            api_fact=$(curl -s --max-time 3 "http://numbersapi.com/random/trivia" 2>/dev/null)
            ;;
          3)
            # Random Dog Image + Fact combo
            api_fact="Did you know dogs can be trained to detect diseases like cancer and diabetes? 🐕"
            ;;
        esac
        
        # Fallback fun facts if API fails
        if [ -z "$api_fact" ] || [ ${#api_fact} -lt 10 ]; then
          fallback_facts=(
            "Vercel processes over 12 billion requests per week! 📊"
            "The first website ever created is still online at info.cern.ch 🌐"
            "JavaScript was created in just 10 days by Brendan Eich ⚡"
            "A group of cats is called a 'clowder' 🐱"
            "Octopuses have three hearts and blue blood 🐙"
            "Honey never spoils - archaeologists found edible honey in Egyptian tombs! 🍯"
            "A single cloud can weigh more than a million pounds ☁️"
            "Bananas are berries, but strawberries aren't 🍌"
            "The human brain uses 20% of the body's total energy 🧠"
            "There are more possible games of chess than atoms in the observable universe ♟️"
            "Wombat poop is cube-shaped 📦"
            "A shrimp's heart is in its head 🦐"
            "Hot water freezes faster than cold water (Mpemba effect) 🧊"
            "There are more trees on Earth than stars in the Milky Way 🌳"
            "Your stomach gets an entirely new lining every 3-5 days 🫄"
            "The Great Wall of China isn't visible from space with the naked eye 🏯"
            "Bubble wrap was originally invented as wallpaper 🫧"
            "A group of flamingos is called a 'flamboyance' 🦩"
            "Dolphins have names for each other 🐬"
            "The shortest war in history lasted only 38-45 minutes ⚔️"
          )
          
          fact_index=$((RANDOM % ${#fallback_facts[@]}))
          api_fact="${fallback_facts[$fact_index]}"
        fi
        
        # Clean up the fact and add emoji if it doesn't have one
        fun_fact="$api_fact"
        if [[ ! "$fun_fact" =~ [🎲🎯🎪🎨🎭🎪🎊🎉⭐🌟💫✨🔥💡🧠🌍🌎🌏🌈🦄🎈🎁🎀🎂🍰🎃🎄🎆🎇] ]]; then
          emojis=("🎲" "🎯" "🎪" "🎨" "🎭" "🎊" "🎉" "⭐" "🌟" "💫" "✨" "🔥" "💡" "🧠" "🌍" "🌈" "🦄")
          emoji_index=$((RANDOM % ${#emojis[@]}))
          fun_fact="$fun_fact ${emojis[$emoji_index]}"
        fi
        
        echo "🔄 Status: $STATE ($fun_fact)"
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