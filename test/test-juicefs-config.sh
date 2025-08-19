#!/usr/bin/env bash

# Basic syntax validation for JuiceFS configuration files

echo "Testing JuiceFS configuration files..."

# Test that all Nix files have valid syntax
echo "Checking Nix syntax..."

for file in modules/juicefs.nix manifests/juicefs.nix; do
    if [[ -f "$file" ]]; then
        echo "Checking $file..."
        # Basic syntax check - just try to parse the file
        nix-instantiate --parse "$file" > /dev/null
        if [[ $? -eq 0 ]]; then
            echo "✓ $file syntax is valid"
        else
            echo "✗ $file has syntax errors"
            exit 1
        fi
    else
        echo "✗ $file not found"
        exit 1
    fi
done

echo "Checking modified files..."
for file in modules/common.nix modules/k3s-manifests.nix systems/master.nix systems/agent.nix manifests/longhorn.nix; do
    if [[ -f "$file" ]]; then
        echo "Checking $file..."
        nix-instantiate --parse "$file" > /dev/null
        if [[ $? -eq 0 ]]; then
            echo "✓ $file syntax is valid"
        else
            echo "✗ $file has syntax errors"
            exit 1
        fi
    else
        echo "✗ $file not found"
        exit 1
    fi
done

echo "✓ All configuration files passed syntax validation"