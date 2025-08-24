# Task Automation System

The Dolibarr Docker setup includes a comprehensive task automation system built on [Task](https://taskfile.dev/) that provides organized, efficient workflows for common operations.

## Overview

The task system is organized into modular files for better maintainability and logical grouping of related operations. Each category of tasks is contained in its own file within the `.taskfile/` directory.

### Modular Structure

```
.taskfile/
├── setup.yml        # 🚀 Initialization and setup tasks
├── services.yml     # ⚙️ Service management (start/stop/status/logs)
├── backup.yml       # 💾 Backup and restore operations
├── maintenance.yml  # 🧹 Cleanup and maintenance tasks
└── utilities.yml    # 🔧 Utility functions (shell, health checks)
```

## Installation

### Prerequisites

- **Task**: Version 3.0 or higher
- **Docker & Docker Compose**: For service management
- **Operating System**: Linux, macOS, or Windows with WSL2

### Install Task

```bash
# macOS
brew install go-task/tap/go-task

# Linux
sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d

# Windows (PowerShell)
iwr -useb get.scoop.sh | iex
scoop bucket add extras
scoop install task

# Manual installation
curl -sL https://github.com/go-task/task/releases/latest/download/task_linux_amd64.tar.gz | tar -xz
sudo mv task /usr/local/bin/
```

### Verify Installation

```bash
task --version
# Should output: Task version: v3.x.x
```

## Quick Start

### List Available Tasks

```bash
# Show all available tasks
task --list
# or
task

# Show tasks from specific category
task services --list
task backup --list
```

### Basic Usage

```bash
# Initialize the environment
task setup:init

# Start services with development tools
task services:start-with-tools

# Check system health
task utilities:health

# Create a backup
task backup:backup
```

## Task Categories

## 🚀 Setup & Initialization (`setup:*`)

### Purpose
Initialize the Dolibarr environment with proper directories and permissions.

### Available Tasks

#### `task setup:init`
**Description**: Initialize Dolibarr setup (create directories and set permissions)

**What it does**:
- Creates required directories: `custom/`, `logs/`, `db-init/`, `backups/`
- Sets appropriate permissions (755) for all directories
- Ensures proper directory structure for Docker volume mounts

**Usage**:
```bash
task setup:init
```

**Example Output**:
```
task: [setup:init] mkdir -p custom logs db-init ./backups
task: [setup:init] chmod 755 custom logs db-init ./backups
task: [setup:init] echo "✅ Dolibarr directories initialized"
✅ Dolibarr directories initialized
```

---

## ⚙️ Service Management (`services:*`)

### Purpose
Manage Docker services for different deployment scenarios.

### Available Tasks

#### `task services:start`
**Description**: Start with internal database

**What it does**:
- Starts Dolibarr application container
- Starts MariaDB database container
- Uses internal database profile

**Usage**:
```bash
task services:start
```

#### `task services:start-with-tools`
**Description**: Start with internal database and phpMyAdmin

**What it does**:
- Starts Dolibarr application
- Starts MariaDB database
- Starts phpMyAdmin for database management
- Ideal for development and administration

**Usage**:
```bash
task services:start-with-tools
```

**Access Points**:
- Dolibarr: http://localhost:8080
- phpMyAdmin: http://localhost:8081

#### `task services:start-external`
**Description**: Start with external database

**What it does**:
- Starts only Dolibarr application
- Connects to external database (configured in .env)
- Suitable for production with existing database

**Prerequisites**:
- External database must be configured in `.env`
- Database must be accessible from Docker network

**Usage**:
```bash
task services:start-external
```

#### `task services:stop`
**Description**: Stop all services

**What it does**:
- Gracefully stops all running containers
- Preserves data in volumes

**Usage**:
```bash
task services:stop
```

#### `task services:status`
**Description**: Show status of all services

**Usage**:
```bash
task services:status
```

**Example Output**:
```
NAME                 IMAGE                         COMMAND                  CREATED       STATUS
dolibarr_dolibarr_1  dolibarr/dolibarr:latest     "docker-entrypoint.s…"   2 hours ago   Up 2 hours
dolibarr_db_1        mariadb:10.11                "docker-entrypoint.s…"   2 hours ago   Up 2 hours
```

### Log Management

#### `task services:logs`
**Description**: Show logs from all services
```bash
task services:logs
```

#### `task services:logs-app`
**Description**: Show Dolibarr application logs only
```bash
task services:logs-app
```

#### `task services:logs-db`
**Description**: Show database logs only
```bash
task services:logs-db
```

---

## 💾 Backup & Restore (`backup:*`)

### Purpose
Comprehensive data protection with automated backup and restore capabilities.

### Available Tasks

#### `task backup:backup`
**Description**: Create complete backup (database + application data)

**What it does**:
- Creates timestamped backup directory
- Backs up database with mysqldump (compressed)
- Backs up application data and custom modules
- Stores everything in `./backups/` directory

**Usage**:
```bash
task backup:backup
```

**Output Structure**:
```
backups/
└── 2024-08-24_14-30-15/
    ├── database_2024-08-24_14-30-15.sql.gz
    └── app_data_2024-08-24_14-30-15.tar.gz
```

#### `task backup:backup-db`
**Description**: Create database backup only

**Prerequisites**:
- Database container must be running

**Usage**:
```bash
task backup:backup-db
```

#### `task backup:backup-app`
**Description**: Create application data backup only

**What it backs up**:
- Document storage volume
- HTML/application files volume
- Custom modules directory

**Usage**:
```bash
task backup:backup-app
```

#### `task backup:list-backups`
**Description**: List available backups

**Usage**:
```bash
task backup:list-backups
```

**Example Output**:
```
📁 Available backups:
total 24
drwxr-xr-x  4 user  staff  128 Aug 24 14:30 2024-08-24_14-30-15
drwxr-xr-x  4 user  staff  128 Aug 24 12:15 2024-08-24_12-15-30
```

### Restore Operations

#### Database Restore
```bash
# Restore database from specific backup
task backup:restore-db BACKUP_FILE=backups/2024-08-24_14-30-15/database_2024-08-24_14-30-15.sql.gz
```

#### Application Data Restore
```bash
# Restore application data from specific backup
task backup:restore-app BACKUP_FILE=backups/2024-08-24_14-30-15/app_data_2024-08-24_14-30-15.tar.gz
```

**⚠️ Important Notes**:
- Restore operations require services to be running
- Application restore will stop services temporarily
- Always test restores in development first

---

## 🧹 Maintenance (`maintenance:*`)

### Purpose
System cleanup, updates, and maintenance operations.

### Available Tasks

#### `task maintenance:cleanup`
**Description**: Clean up Docker resources

**What it does**:
- Removes unused Docker images
- Cleans up stopped containers
- Removes unused networks and volumes
- Frees up disk space

**Usage**:
```bash
task maintenance:cleanup
```

**⚠️ Warning**: This will remove unused Docker resources. Ensure no important data is stored in unnamed volumes.

#### `task maintenance:update`
**Description**: Update containers to latest versions

**What it does**:
- Pulls latest container images
- Recreates containers with new images
- Maintains data volumes

**Usage**:
```bash
task maintenance:update
```

#### `task maintenance:reset-data`
**Description**: Reset all data (DANGEROUS)

**What it does**:
- Stops all services
- Removes all Docker volumes
- Deletes all application data
- **⚠️ THIS OPERATION IS IRREVERSIBLE**

**Usage**:
```bash
task maintenance:reset-data
# Will prompt for confirmation
```

#### `task maintenance:reset-logs`
**Description**: Clear application logs

**Usage**:
```bash
task maintenance:reset-logs
```

#### `task maintenance:reset-custom`
**Description**: Clear custom modules

**What it does**:
- Removes all PHP, JS, and CSS files from custom directory
- Keeps directory structure
- Prompts for confirmation

**Usage**:
```bash
task maintenance:reset-custom
# Will prompt for confirmation
```

---

## 🔧 Utilities (`utilities:*`)

### Purpose
System utilities for troubleshooting, monitoring, and direct access.

### Available Tasks

#### `task utilities:health`
**Description**: Check health of all services

**What it does**:
- Shows container status
- Tests web interface accessibility
- Tests phpMyAdmin accessibility (if running)
- Provides comprehensive system health overview

**Usage**:
```bash
task utilities:health
```

**Example Output**:
```
🔍 Checking service health...
NAME                 COMMAND              STATUS
dolibarr_dolibarr_1  "docker-entrypoint…"  Up 2 hours
dolibarr_db_1        "docker-entrypoint…"  Up 2 hours

🌐 Testing web access...
Dolibarr web interface: 200
phpMyAdmin: 200
```

#### `task utilities:shell-app`
**Description**: Open shell in Dolibarr container

**Prerequisites**:
- Dolibarr container must be running

**Usage**:
```bash
task utilities:shell-app
```

**Common Use Cases**:
```bash
# Inside container shell
ls /var/www/html/                    # View application files
tail -f /var/www/html/documents/dolibarr.log  # View logs
chown -R www-data:www-data /var/www/html      # Fix permissions
```

#### `task utilities:shell-db`
**Description**: Open MySQL shell in database container

**Prerequisites**:
- Database container must be running

**Usage**:
```bash
task utilities:shell-db
```

**Common Use Cases**:
```sql
-- Inside MySQL shell
SHOW DATABASES;
USE dolibarr;
SHOW TABLES;
SELECT COUNT(*) FROM llx_user;
```

#### `task utilities:permissions`
**Description**: Fix file permissions for Dolibarr

**What it does**:
- Sets proper ownership for web files
- Sets proper ownership for document storage
- Fixes common permission issues

**Prerequisites**:
- Dolibarr container must be running

**Usage**:
```bash
task utilities:permissions
```

## Advanced Usage

### Task Composition and Workflows

#### Development Workflow
```bash
# Complete development setup
task setup:init
task services:start-with-tools
task utilities:health

# Work on application...

# Create backup before major changes
task backup:backup

# View logs during development
task services:logs-app
```

#### Production Deployment Workflow
```bash
# Production setup
task setup:init
task services:start-external
task utilities:health

# Regular maintenance
task backup:backup     # Daily
task maintenance:cleanup  # Weekly
task maintenance:update   # Monthly
```

#### Troubleshooting Workflow
```bash
# Diagnose issues
task utilities:health
task services:status
task services:logs

# Access containers for debugging
task utilities:shell-app
task utilities:shell-db

# Fix common issues
task utilities:permissions
```

### Custom Task Variables

Tasks support environment variables and can be customized:

```bash
# Use different backup directory
BACKUP_DIR=./custom-backups task backup:backup

# Use specific backup file
task backup:restore-db BACKUP_FILE=/path/to/specific/backup.sql.gz

# Custom ports
DOLIBARR_PORT=9080 task services:start
```

### Task Dependencies

The task system includes intelligent dependencies:

- `backup:backup` depends on both `backup:backup-db` and `backup:backup-app`
- Tasks with preconditions will check prerequisites before execution
- Failed preconditions provide helpful error messages

### Error Handling

Tasks include comprehensive error handling:

```bash
# Example: Trying to backup without running database
$ task backup:backup-db
task: Failed to run task "backup:backup-db": exit status 1
Database container is not running. Start with: task services:start
```

## Best Practices

### 1. Regular Backup Schedule
```bash
# Add to crontab for automated backups
0 2 * * * cd /path/to/dolibarr && task backup:backup
```

### 2. Health Monitoring
```bash
# Regular health checks
task utilities:health || echo "Services need attention"
```

### 3. Log Monitoring
```bash
# Monitor application logs
task services:logs-app | grep -i error
```

### 4. Safe Maintenance
```bash
# Always backup before maintenance
task backup:backup
task maintenance:update
task utilities:health
```

### 5. Development Environment
```bash
# Use tools profile for development
task services:start-with-tools

# Quick restart during development
task services:stop && task services:start-with-tools
```

## Troubleshooting Tasks

### Common Task Issues

1. **Task not found**
   ```bash
   # Verify task installation
   task --version
   
   # List available tasks
   task --list
   ```

2. **Permission denied**
   ```bash
   # Check Docker permissions
   docker ps
   
   # Fix file permissions
   task utilities:permissions
   ```

3. **Service not responding**
   ```bash
   # Check service status
   task services:status
   
   # View logs
   task services:logs
   
   # Restart services
   task services:stop
   task services:start-with-tools
   ```

### Task Performance

- Tasks are designed to be idempotent (safe to run multiple times)
- Dependencies are automatically resolved
- Preconditions prevent invalid operations
- All operations include progress feedback

This comprehensive task system provides efficient, organized workflows for all aspects of Dolibarr Docker management.
