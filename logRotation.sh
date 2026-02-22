#!/bin/bash
# ====================================================================
#  JIRA: FINSERV-4105 — Log Rotation Script Filling Up Production Disk
# ====================================================================
#  Priority: P0 — Sev1 | Sprint: Sprint 8 | Points: 2
#  Reporter: Amit Verma (DevOps Lead)
#  Assignee: You (Intern)
#  Due: ASAP — estimated 6 hours to disk full on 3 production servers
#  Labels: production, devops, disk-space, bash, infrastructure
#
#  DESCRIPTION:
#  Production servers are running out of disk space. /var/log/app/ has
#  grown to 45GB of uncompressed log files. This cron job runs daily
#  at 2:00 AM but logs are NOT being compressed or deleted. If the disk
#  fills up completely, the database will crash (can't write transaction
#  logs) and all client services go down.
#
#  IMPACT:
#  - 3 production servers at >90% disk utilization
#  - Estimated time to disk full: ~6 hours
#  - If disk fills: database crash → full service outage
#  - All client environments affected
#
#  ACCEPTANCE CRITERIA:
#  - [ ] Script compresses .log files older than 7 days (gzip)
#  - [ ] Script deletes .gz files older than 30 days
#  - [ ] Lock file (/tmp/log_rotation.lock) prevents concurrent runs
#  - [ ] Lock file is cleaned up on exit (even on error)
#  - [ ] Missing LOG_DIR is detected and script exits with error
#  - [ ] Only regular files are processed (not directories or symlinks)
#  - [ ] Script exits 0 on success, 1 on any error
#  - [ ] Works correctly when run multiple times (idempotent)
#
#  DISK USAGE (current):
#  ─────────────────────
#  /dev/sda1  100G  92G  8.0G  92% /
#  /dev/sdb1  200G 185G   15G  93% /var
#
#  /var/log/app/ breakdown:
#  app.log        12G  (current, DO NOT COMPRESS)
#  app.log.1      11G  Feb 11
#  app.log.2     9.5G  Feb 10
#  app.log.3     7.2G  Feb 9
#  app.log.4     5.3G  Feb 8
#  No .gz files found — rotation is NOT working!
#
#  SLACK THREAD — #devops — Feb 12, 11:00 AM:
#  ────────────────────────────────────────────
#  @amit.verma (DevOps Lead) 11:00 AM:
#    "🚨 Disk alerts on prod-1,2,3. All above 90%. /var/log/app = 45GB."
#
#  @sanjay.reddy (SRE) 11:03 AM:
#    "Didn't we have a rotation script? Why isn't it compressing?"
#
#  @amit.verma 11:05 AM:
#    "Script runs via cron at 2AM daily but nothing happens. I think
#     the find command flags are wrong. Also no lock file — I've seen
#     two cron instances overlap and corrupt gzip output."
#
#  @sanjay.reddy 11:08 AM:
#    "@intern — Fix this script. Key issues:
#     1. Add -type f to find (it's trying to gzip directories)
#     2. Add a lock file with trap for cleanup
#     3. The deletion logic never works — think about WHY the mtime
#        of a .gz file would always be recent (hint: we just created it)
#     4. Exit with proper error codes"
#
#  @amit.verma 11:10 AM:
#    "Also add error handling. If gzip fails, we need to know, not
#     silently continue with exit 0."
#
#  CRON LOG:
#  ─────────
#  Feb 12 02:00:01 prod-1 CRON: /opt/scripts/logRotation.sh — exit 0
#  Feb 11 02:00:01 prod-1 CRON: /opt/scripts/logRotation.sh — exit 0
#  Feb 10 02:00:01 prod-1 CRON: /opt/scripts/logRotation.sh — exit 0
#  (always exit 0 even though nothing is being compressed)
# ====================================================================

LOG_DIR="/var/log/app"
COMPRESS_AFTER_DAYS=7
DELETE_AFTER_DAYS=30
LOCK_FILE="/tmp/log_rotation.lock"

# ─── No lock file mechanism ───────────────────────────────────────────
# BUG: Should check for lock file, create one, and trap cleanup on EXIT
# Without this, two cron instances can run simultaneously and corrupt
# gzip output when both try to compress the same file

echo "Starting log rotation at $(date)"

# ─── Check if log directory exists ─────────────────────────────────────
# BUG: No check if LOG_DIR exists — find will silently return nothing
# Should: [ -d "$LOG_DIR" ] || { echo "ERROR: $LOG_DIR not found"; exit 1; }

# ─── Compress old logs ────────────────────────────────────────────────
# BUG 1: Missing -type f — this will also match directories named *.log
# BUG 2: Does not search subdirectories correctly — -name "*.log" only
#         matches in the current find path, but logs might be in subdirs
find $LOG_DIR -name "*.log" -mtime +$COMPRESS_AFTER_DAYS -exec gzip {} \;

# ─── Delete expired compressed logs ───────────────────────────────────
# BUG: The .gz files were JUST CREATED by the gzip command above, so
# their modification time is TODAY. This means -mtime +30 will NEVER
# match them. Old compressed logs accumulate forever.
# FIX: Use the original file's timestamp, or track compression dates
find $LOG_DIR -name "*.gz" -mtime +$DELETE_AFTER_DAYS -exec rm {} \;

# ─── No error handling ────────────────────────────────────────────────
# BUG: No check if find/gzip/rm commands succeeded
# Should track errors and exit with code 1 if any operation failed

echo "Log rotation complete at $(date)"

# BUG: Always exits 0 even if everything failed
exit 0
