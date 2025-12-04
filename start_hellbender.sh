#!/bin/bash

# Script to allocate Hellbender resources and connect VS Code

# Default values
TIME="1:00:00"
PARTITION="interactive"

# Parse options
while getopts "t:p:" opt; do
    case $opt in
        t) TIME="$OPTARG" ;;
        p) PARTITION="$OPTARG" ;;
        *) echo "Usage: $0 [-t time] [-p partition]" >&2; exit 1 ;;
    esac
done

echo "Requesting resources from Hellbender..."

# Get current job count before allocation
initial_jobs=$(ssh hellbender "squeue -u \$USER -h | wc -l")

# Run salloc in the background on hellbender and keep it alive
ssh -f hellbender "salloc --time=$TIME --partition=$PARTITION sleep 3600" > /dev/null 2>&1 &

# Wait a moment for allocation to start
sleep 2

# Check for the NEW allocated node ($PARTITION partition)
echo "Waiting for node allocation..."
for i in {1..30}; do
    # Get the most recent interactive job
    node=$(ssh hellbender "squeue -u \$USER -h -p $PARTITION -o '%N' | head -n 1")
    jobid=$(ssh hellbender "squeue -u \$USER -h -p $PARTITION -o '%i' | head -n 1")
    
    # Check if we have a new job
    current_jobs=$(ssh hellbender "squeue -u \$USER -h | wc -l")
    
    if [ -n "$node" ] && [ "$node" != "" ] && [ "$current_jobs" -gt "$initial_jobs" ]; then
        echo "✓ Allocated node: $node"
        echo "✓ Job ID: $jobid"
        
        # Wait a moment for node to be fully ready
        sleep 2
        
        # Open VS Code and connect (let user choose folder)
        echo "Opening VS Code and connecting to $node..."
        code --remote ssh-remote+$node
        
        echo ""
        echo "✓ VS Code should now be connecting to $node"
        echo "✓ Click 'Open Folder' in VS Code to select your working directory"
        echo "✓ Your session will expire in $TIME"
        echo ""
        echo "Current jobs:"
        ssh hellbender "squeue -u \$USER"
        echo ""
        echo "To cancel this specific job: ssh hellbender 'scancel $jobid'"
        exit 0
    fi
    
    echo -n "."
    sleep 2
done

echo ""
echo "✗ Timeout waiting for node allocation"
echo "Check status with: ssh hellbender 'squeue -u \$USER'"
exit 1