#!/bin/sh

echo -e "\n\nInstalling AppStore packages via mas..."
echo "=============================="

formulas=(
    803453959 # Slack
    1423210932 # Flow
    904280696 # Things
)

for formula in "${formulas[@]}"; do
    if mas list | grep "$formula" > /dev/null 2>&1; then
        echo "$formula already installed... skipping."
    else
        mas install $formula
    fi
done
