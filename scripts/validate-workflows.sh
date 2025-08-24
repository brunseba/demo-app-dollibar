#!/bin/bash
set -e

echo "🔍 Validating GitHub Actions workflows..."

# Check if .github/workflows directory exists
if [ ! -d ".github/workflows" ]; then
    echo "❌ .github/workflows directory not found"
    exit 1
fi

# Count workflow files
WORKFLOW_COUNT=$(find .github/workflows -name "*.yml" -o -name "*.yaml" | wc -l)
echo "📄 Found $WORKFLOW_COUNT workflow files"

# Validate each workflow file exists and has content
for workflow in .github/workflows/*.yml .github/workflows/*.yaml; do
    if [ -f "$workflow" ]; then
        echo "✅ $workflow exists"
        
        # Check if file has content
        if [ ! -s "$workflow" ]; then
            echo "❌ $workflow is empty"
            exit 1
        fi
        
        # Check for required sections
        if ! grep -q "^name:" "$workflow"; then
            echo "⚠️  $workflow missing 'name' field"
        fi
        
        if ! grep -q "^on:" "$workflow"; then
            echo "❌ $workflow missing 'on' trigger section"
            exit 1
        fi
        
        if ! grep -q "^jobs:" "$workflow"; then
            echo "❌ $workflow missing 'jobs' section"
            exit 1
        fi
        
        echo "✅ $workflow has required structure"
    fi
done

# List all workflows
echo ""
echo "📋 Available workflows:"
for workflow in .github/workflows/*.yml .github/workflows/*.yaml; do
    if [ -f "$workflow" ]; then
        name=$(grep "^name:" "$workflow" | cut -d ':' -f2- | xargs)
        echo "  - $(basename "$workflow"): $name"
    fi
done

echo ""
echo "✅ All workflows validated successfully!"
echo "🚀 Ready to push to GitHub for testing"
