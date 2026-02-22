# Learning Guide - Bash (Shell Scripting)

> **Welcome to Service-Track Week 1, Hotfix 2!**
> This is a **hotfix task** - a single file that needs urgent bug fixes.
> Hotfixes simulate real production emergencies where you need to fix code quickly.

---

## What You Need To Do (Summary)

1. **Read the comments** at the top of `logRotation.sh` - they describe the problem
2. **Read** this guide to learn the Bash (Shell Scripting) syntax you'll need
3. **Find the bugs** (search for `BUG` comments in the code)
4. **Fix each bug** using the hints provided
5. **Run the tests** (if included at the bottom of the file)

---

## Bash (Shell Scripting) Quick Reference

### Variables
```bash
NAME="Alice"                  # No spaces around =
COUNT=42
LOG_DIR="/var/log/app"

# Using variables (always use quotes and dollar sign):
echo "Hello, $NAME"
echo "Log dir: $LOG_DIR"
```

### Conditionals
```bash
# File checks:
if [ -d "$LOG_DIR" ]; then    # -d = is it a directory?
    echo "Directory exists"
elif [ -f "$LOG_DIR" ]; then  # -f = is it a file?
    echo "It's a file"
else
    echo "Doesn't exist"
fi

# String comparison:
if [ "$NAME" = "Alice" ]; then
    echo "Hi Alice"
fi

# Number comparison:
if [ $COUNT -gt 10 ]; then   # -gt = greater than
    echo "More than 10"       # -lt = less than, -eq = equal
fi
```

### Loops
```bash
# Loop through files:
for file in $LOG_DIR/*.log; do
    echo "Found: $file"
done

# While loop:
while [ $COUNT -gt 0 ]; do
    echo $COUNT
    COUNT=$((COUNT - 1))
done
```

### Find Command (very important for this task!)
```bash
# Find files by name:
find /var/log -name "*.log"

# Find only regular files (not directories):
find /var/log -name "*.log" -type f    # -type f is CRITICAL

# Find files older than 7 days:
find /var/log -name "*.log" -type f -mtime +7

# Find and execute a command on each:
find /var/log -name "*.log" -type f -mtime +7 -exec gzip {} \;
```

### Error Handling
```bash
# Check if a command succeeded:
if ! gzip "$file"; then
    echo "ERROR: Failed to compress $file"
    exit 1
fi

# Trap - run cleanup on exit (even on error):
cleanup() {
    rm -f "$LOCK_FILE"
}
trap cleanup EXIT    # Runs cleanup() when script exits

# Exit codes:
exit 0    # Success
exit 1    # Error
```

### Lock Files (prevent concurrent runs)
```bash
LOCK_FILE="/tmp/my_script.lock"

if [ -f "$LOCK_FILE" ]; then
    echo "Already running!"
    exit 1
fi
touch "$LOCK_FILE"
trap "rm -f $LOCK_FILE" EXIT
```

---

## Project Structure

This is a **hotfix** - everything is in one file:

| File | Purpose |
|------|---------|
| `logRotation.sh` | The code with bugs - **fix this file** |
| `GUIDE.md` | This learning guide |

---

## Bugs to Fix

### Bug #1
**What's wrong:** Should check for lock file, create one, and trap cleanup on EXIT

**How to find it:** Search for `BUG` in `logRotation.sh` - the comments around each bug explain what's broken.

### Bug #2
**What's wrong:** No check if LOG_DIR exists â€” find will silently return nothing

**How to find it:** Search for `BUG` in `logRotation.sh` - the comments around each bug explain what's broken.

### Bug #3
**What's wrong:** 1: Missing -type f â€” this will also match directories named *.log

**How to find it:** Search for `BUG` in `logRotation.sh` - the comments around each bug explain what's broken.

### Bug #4
**What's wrong:** 2: Does not search subdirectories correctly â€” -name "*.log" only

**How to find it:** Search for `BUG` in `logRotation.sh` - the comments around each bug explain what's broken.

### Bug #5
**What's wrong:** The .gz files were JUST CREATED by the gzip command above, so

**How to find it:** Search for `BUG` in `logRotation.sh` - the comments around each bug explain what's broken.

### Bug #6
**What's wrong:** No check if find/gzip/rm commands succeeded

**How to find it:** Search for `BUG` in `logRotation.sh` - the comments around each bug explain what's broken.

### Bug #7
**What's wrong:** Always exits 0 even if everything failed

**How to find it:** Search for `BUG` in `logRotation.sh` - the comments around each bug explain what's broken.


---

## How to Approach This

1. **Read the top comment block** in `logRotation.sh` carefully - it has:
   - The JIRA ticket description (what's happening in production)
   - Slack thread (discussion about the problem)
   - Acceptance criteria (checklist of what needs to work)
2. **Search for `BUG`** in the file to find each bug location
3. **Read the surrounding code** to understand what it's trying to do
4. **Fix the logic** based on the bug description
5. **Check the tests** at the bottom of the file and make sure they pass

---

## Common Mistakes to Avoid

- Don't change the structure of the code - only fix the buggy logic
- Read **all** the bugs before starting - sometimes fixing one helps you understand another
- Pay attention to the Slack thread comments - they often contain hints about the root cause
