# Beginner Explanatory Guide: S-W01-Hotfix-02: Fix log rotation script issues

> **Task Type**: Service Task  
> **Domain/Focus**: Bash (Shell Scripting)

---

## 1. The Goal (In-Depth Beginner Explanation)

### The Core Problem
The task at hand involves fixing a critical bug in a Bash script named `logRotation.sh`, which is responsible for managing log files in an application. Log rotation is essential for maintaining system performance and preventing disk space exhaustion by archiving or deleting old log files. Currently, the script has several issues that prevent it from functioning correctly, particularly concerning the management of lock files. Lock files are used to ensure that only one instance of the script runs at a time, preventing potential conflicts and data corruption.

The absence of proper lock file handling means that if the script is executed multiple times simultaneously, it could lead to race conditions where multiple processes attempt to modify the same log files. This could result in incomplete log rotations, data loss, or even system crashes. Fixing these bugs is crucial not only for the stability of the application but also for ensuring that users have access to accurate and complete log data, which is vital for troubleshooting and monitoring system health.

### Jargon Buster (Key Terms Explained)
* **Lock File**: A lock file is a temporary file created by a process to indicate that a resource (like a script) is currently in use. For example, if `logRotation.sh` creates a lock file named `logRotation.lock`, any subsequent attempts to run the script would check for this file and exit if it exists, preventing concurrent executions.

* **Bash Script**: A Bash script is a text file containing a series of commands that the Bash shell can execute. For instance, a simple Bash script might include commands to create directories, copy files, or automate system tasks. It allows users to automate repetitive tasks efficiently.

* **Error Handling**: Error handling refers to the process of responding to and managing errors that occur during the execution of a program. In Bash, this can be done using conditional statements to check if commands succeed or fail, allowing the script to take appropriate actions, such as logging an error message or exiting gracefully.

* **Find Command**: The `find` command in Unix/Linux is used to search for files and directories based on various criteria, such as name, type, or modification date. For example, `find /var/log -name "*.log"` searches for all files with a `.log` extension in the `/var/log` directory.

### Expected Outcome
After implementing the necessary fixes, the `logRotation.sh` script should correctly handle the creation and management of lock files, ensuring that only one instance of the script can run at a time. This will prevent conflicts and ensure that log files are rotated properly without data loss. 

**Before vs. After Comparison**:
- **Before**: The script could run multiple instances simultaneously, leading to potential data corruption and incomplete log rotations.
- **After**: The script checks for an existing lock file before execution, creating one if it doesn't exist, and ensures that only one instance runs at a time, thus maintaining data integrity and system stability.

---

## 2. Related Coding Concepts & Syntax (50% Theory, 50% Practice)

### Concept 1: Lock Files
#### 📘 Theoretical Overview (50%)
Lock files are a fundamental concept in scripting and programming that help manage access to shared resources. When a script or program needs to perform operations that should not be interrupted or duplicated, it creates a lock file. This file acts as a signal to other instances of the script that it is already running. If another instance attempts to run, it checks for the presence of the lock file and exits if it finds it, thus preventing concurrent execution.

Without lock files, multiple instances of a script could interfere with each other, leading to unpredictable behavior, data corruption, or crashes. For example, if two instances of a log rotation script run simultaneously, they might both try to delete or compress the same log files, resulting in incomplete operations.

#### 💻 Syntax & Practical Examples (50%)
* **Language Syntax**:
  ```bash
  LOCK_FILE="/tmp/my_script.lock"

  if [ -f "$LOCK_FILE" ]; then
      echo "Already running!"
      exit 1
  fi
  touch "$LOCK_FILE"
  trap "rm -f $LOCK_FILE" EXIT
  ```
  - `LOCK_FILE="/tmp/my_script.lock"`: Defines the path for the lock file.
  - `if [ -f "$LOCK_FILE" ]; then`: Checks if the lock file exists.
  - `touch "$LOCK_FILE"`: Creates the lock file if it doesn't exist.
  - `trap "rm -f $LOCK_FILE" EXIT`: Ensures the lock file is removed when the script exits.

* **Real-World Application**:
  ```bash
  # Example of a log rotation script with lock file handling
  LOCK_FILE="/tmp/logRotation.lock"

  if [ -f "$LOCK_FILE" ]; then
      echo "Log rotation script is already running!"
      exit 1
  fi

  touch "$LOCK_FILE"
  trap "rm -f $LOCK_FILE" EXIT

  # Proceed with log rotation logic here
  echo "Rotating logs..."
  # Example log rotation logic
  find /var/log -name "*.log" -type f -mtime +7 -exec gzip {} \;
  echo "Log rotation completed."
  ```
  In this example, the script checks for an existing lock file before proceeding with the log rotation logic, ensuring that only one instance runs at a time.

---

## 3. Step-by-Step Logic & Walkthrough

1. **Step 1: Locate and Analyze the Target File**
   * Navigate to the folder `s-w01-hotfix-02` and open the file `logRotation.sh`. This file contains the code that needs to be fixed.
   * Look for comments marked with `BUG` to identify the specific lines where issues are present.

2. **Step 2: Input Verification & Validation**
   * Before making changes, ensure that the script checks for the existence of the lock file. This is crucial to prevent multiple instances from running simultaneously.

3. **Step 3: Core Implementation / Modification**
   * Add the lock file handling code at the beginning of the script. This includes checking for the lock file, creating it if it doesn't exist, and setting up a trap to remove it upon script exit.
   * Example modification:
     ```bash
     LOCK_FILE="/tmp/logRotation.lock"

     if [ -f "$LOCK_FILE" ]; then
         echo "Log rotation script is already running!"
         exit 1
     fi
     touch "$LOCK_FILE"
     trap "rm -f $LOCK_FILE" EXIT
     ```

4. **Step 4: Output Verification & Testing**
   * After implementing the changes, run the script to ensure it behaves as expected. Check that it correctly creates the lock file and prevents multiple executions.
   * If tests are included at the bottom of the file, run them to verify that the script functions correctly after the modifications.

---

## 4. Detailed Walkthrough of Test Cases

### Test Case 1: Standard / Success Case
* **Description**: This test represents a successful execution of the log rotation script when no other instance is running.
* **Inputs**:
  ```json
  {
    "log_directory": "/var/log",
    "log_file_pattern": "*.log",
    "age_limit": 7
  }
  ```
* **Step-by-Step Execution Trace**:
  1. The script starts and checks for the lock file.
  2. Since the lock file does not exist, it creates one.
  3. The script proceeds to find and compress log files older than 7 days.
  4. The final result indicates that log rotation was completed successfully.
* **Expected Output**: 
  ```
  Rotating logs...
  Log rotation completed.
  ```

### Test Case 2: Edge Case / Validation Fail
* **Description**: This test represents a scenario where the script is executed while another instance is already running.
* **Inputs**:
  ```json
  {
    "log_directory": "/var/log",
    "log_file_pattern": "*.log",
    "age_limit": 7
  }
  ```
* **Step-by-Step Execution Trace**:
  1. The script starts and checks for the lock file.
  2. The lock file exists, indicating that another instance is running.
  3. The script outputs a message and exits without performing any log rotation.
* **Expected Output**: 
  ```
  Log rotation script is already running!
  ``` 

This detailed guide should provide a comprehensive understanding of the task at hand, the concepts involved, and the steps necessary to implement the required fixes in the `logRotation.sh` script.