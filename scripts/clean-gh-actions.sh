#!/bin/bash
set -e

echo "🧹 GitHub Actions History Cleanup"
echo "=================================="

# Function to show current status
show_status() {
    echo "📊 Current GitHub Actions Status:"
    TOTAL=$(gh api repos/:owner/:repo/actions/runs | jq -r '.total_count')
    echo "Total runs: $TOTAL"
    
    echo "Runs by status:"
    gh api repos/:owner/:repo/actions/runs | jq -r '.workflow_runs[] | "\(.name): \(.status) (\(.conclusion // "running"))"'
    echo ""
}

# Show current status
show_status

# Get failed workflow runs
echo "📋 Finding failed workflow runs..."
FAILED_RUNS=$(gh api repos/:owner/:repo/actions/runs --paginate | jq -r '.workflow_runs[] | select(.conclusion == "failure") | .id' | tr '\n' ' ')

if [ -z "$FAILED_RUNS" ]; then
    echo "✅ No failed runs found!"
    exit 0
fi

echo "Found failed runs:"
for run_id in $FAILED_RUNS; do
    if [ -n "$run_id" ]; then
        echo "  - Run ID: $run_id"
    fi
done

echo ""
read -p "Do you want to delete all failed runs? (y/N): " confirm

if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
    echo "🗑️ Deleting failed runs..."
    
    DELETED_COUNT=0
    for run_id in $FAILED_RUNS; do
        if [ -n "$run_id" ]; then
            echo "Deleting run $run_id..."
            if gh api repos/:owner/:repo/actions/runs/$run_id -X DELETE > /dev/null 2>&1; then
                echo "✅ Deleted $run_id"
                ((DELETED_COUNT++))
            else
                echo "❌ Failed to delete run $run_id"
            fi
        fi
    done
    
    echo ""
    echo "✅ Cleanup complete! Deleted $DELETED_COUNT failed runs."
    echo ""
    show_status
else
    echo "❌ Cleanup cancelled"
fi
