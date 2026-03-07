#!/bin/bash
# Daily Journal Automation Script

# Set working directory
cd /home/ubuntu/.openclaw/workspace

# Activate virtual environment (for Playwright if needed)
source /home/ubuntu/openclaw-venv/bin/activate

# Run daily journal generator
python3 daily_journal_generator.py

# Deactivate virtual environment
deactivate

echo "Daily journal process completed at $(date)"