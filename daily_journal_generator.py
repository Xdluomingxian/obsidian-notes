#!/usr/bin/env python3
"""
Daily Journal Generator for Obsidian
Generates daily journal entries with AI assistance summary
"""

import os
import datetime
import json
from pathlib import Path

class DailyJournalGenerator:
    def __init__(self, journal_dir="/home/ubuntu/.openclaw/workspace/obsidian-notes/daily-journal"):
        self.journal_dir = Path(journal_dir)
        self.journal_dir.mkdir(parents=True, exist_ok=True)
        
    def get_today_date(self):
        """Get today's date in YYYY-MM-DD format"""
        return datetime.date.today().strftime("%Y-%m-%d")
    
    def get_yesterday_date(self):
        """Get yesterday's date"""
        yesterday = datetime.date.today() - datetime.timedelta(days=1)
        return yesterday.strftime("%Y-%m-%d")
    
    def load_memory_files(self):
        """Load memory files to extract daily activities"""
        memory_content = ""
        memory_dir = Path("/home/ubuntu/.openclaw/workspace/memory")
        
        if memory_dir.exists():
            # Load today's memory file
            today_file = memory_dir / f"{self.get_today_date()}.md"
            if today_file.exists():
                with open(today_file, 'r', encoding='utf-8') as f:
                    memory_content += f.read()
            
            # Load yesterday's memory file  
            yesterday_file = memory_dir / f"{self.get_yesterday_date()}.md"
            if yesterday_file.exists():
                with open(yesterday_file, 'r', encoding='utf-8') as f:
                    memory_content += f.read()
        
        return memory_content
    
    def generate_journal_entry(self):
        """Generate today's journal entry"""
        today = self.get_today_date()
        journal_file = self.journal_dir / f"{today}.md"
        
        # Check if journal already exists
        if journal_file.exists():
            print(f"✅ Journal for {today} already exists")
            return
        
        # Get memory content
        memory_content = self.load_memory_files()
        
        # Generate journal content
        journal_content = self.create_journal_template(today, memory_content)
        
        # Write journal file
        with open(journal_file, 'w', encoding='utf-8') as f:
            f.write(journal_content)
        
        print(f"📝 Created journal for {today}")
        return journal_file
    
    def create_journal_template(self, date, memory_content):
        """Create journal template with sections"""
        template = f"""# Daily Journal - {date}

## 📅 Date
{date}

## 🎯 Today's Summary
Brief overview of today's main activities and achievements.

## 🛠️ Skills Learned & Installed
- List of new skills or tools learned today
- Installation and configuration details

## 🔧 Technical Operations Performed
- System configurations
- Tool installations  
- Code development
- Debugging sessions

## ❓ Problems Encountered & Solutions
### Problem 1
- **Issue**: 
- **Root Cause**: 
- **Solution**: 
- **Lessons Learned**: 

### Problem 2  
- **Issue**: 
- **Root Cause**: 
- **Solution**: 
- **Lessons Learned**: 

## 💡 Key Insights & Learnings
- Important realizations or discoveries
- Best practices identified
- Efficiency improvements

## 📚 Resources & References
- Useful documentation found
- Helpful tutorials or guides
- Relevant GitHub repositories

## 🎯 Tomorrow's Goals
- Planned tasks and objectives
- Skills to explore
- Issues to resolve

## 📊 Metrics & Progress
- Number of skills installed: 
- Problems solved: 
- New capabilities gained: 

---
*Generated automatically by OpenClaw AI Assistant*
"""
        
        return template
    
    def sync_to_github(self):
        """Sync journal to GitHub repository"""
        try:
            # Change to obsidian-notes directory
            os.chdir("/home/ubuntu/.openclaw/workspace/obsidian-notes")
            
            # Add all changes
            os.system("git add .")
            
            # Check if there are changes to commit
            result = os.popen("git status --porcelain").read()
            if result.strip():
                # Commit with timestamp
                commit_message = f"Update daily journal - {self.get_today_date()}"
                os.system(f'git commit -m "{commit_message}"')
                
                # Push to GitHub
                os.system("git push origin main")
                print("✅ Successfully synced journal to GitHub")
            else:
                print("ℹ️ No changes to sync to GitHub")
                
        except Exception as e:
            print(f"❌ Error syncing to GitHub: {e}")
    
    def run_daily_journal(self):
        """Main function to run daily journal generation"""
        print("🚀 Starting daily journal generation...")
        
        # Generate today's journal
        journal_file = self.generate_journal_entry()
        
        if journal_file:
            # Sync to GitHub
            self.sync_to_github()
            
            print(f"🎉 Daily journal completed: {journal_file}")
        else:
            print("ℹ️ Daily journal already exists for today")

if __name__ == "__main__":
    generator = DailyJournalGenerator()
    generator.run_daily_journal()