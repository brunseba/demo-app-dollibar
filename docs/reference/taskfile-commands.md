# Taskfile Commands Reference

This document provides a comprehensive reference of all available Task commands for managing your Dolibarr Docker installation.

## Table of Contents

- [Setup Commands](#setup-commands)
- [Service Management](#service-management)
- [Configuration Commands](#configuration-commands)
- [Backup Commands](#backup-commands)
- [Maintenance Commands](#maintenance-commands)
- [Utility Commands](#utility-commands)

---

## Setup Commands

### `task setup:init`

**Description**: Initialize Dolibarr setup by creating required directories and setting permissions

**Usage**:
```bash
task setup:init
```

**What it does**:
- Creates required directories: `custom/`, `logs/`, `db-init/`, `backups/`
- Sets proper permissions (755) on all directories
- Prepares the environment for first-time setup

**When to use**: Run this command after cloning the repository and before starting services for the first time

**Example output**:
```
✅ Dolibarr directories initialized
```

---

## Service Management

### `task services:start`

**Description**: Start Dolibarr with internal database

**Usage**:
```bash
task services:start
```

**What it does**:
- Starts Dolibarr application container
- Starts internal MariaDB database container
- Uses `internal-db` profile

**Ports opened**:
- Dolibarr: `${DOLIBARR_PORT}` (default: 8080)
- Database: `${DB_EXTERNAL_PORT}` (default: 3306)

**Example output**:
```
✅ Dolibarr started with internal database
```

---

### `task services:start-with-tools`

**Description**: Start Dolibarr with internal database and phpMyAdmin for development

**Usage**:
```bash
task services:start-with-tools
```

**What it does**:
- Starts Dolibarr application container
- Starts internal MariaDB database container
- Starts phpMyAdmin container for database management
- Uses `internal-db` and `internal-db-tools` profiles

**Ports opened**:
- Dolibarr: `${DOLIBARR_PORT}` (default: 8080)
- phpMyAdmin: `${PHPMYADMIN_PORT}` (default: 8081)
- Database: `${DB_EXTERNAL_PORT}` (default: 3306)

**Example output**:
```
✅ Dolibarr started with internal database and phpMyAdmin
```

---

### `task services:start-external`

**Description**: Start Dolibarr with external database connection

**Usage**:
```bash
task services:start-external
```

**What it does**:
- Starts only Dolibarr application container
- Connects to external database specified in environment variables
- Uses `external-db` profile

**Prerequisites**: 
- External database must be accessible
- Configure `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD` in `.env`

**Example output**:
```
✅ Dolibarr started with external database
```

---

### `task services:stop`

**Description**: Stop all Dolibarr services

**Usage**:
```bash
task services:stop
```

**What it does**:
- Stops all running containers
- Removes containers but preserves volumes and data

**Example output**:
```
✅ Dolibarr services stopped
```

---

### `task services:status`

**Description**: Show status of all services

**Usage**:
```bash
task services:status
```

**What it does**:
- Displays current status of all Docker Compose services
- Shows container names, states, and port mappings

**Example output**:
```
NAME                  IMAGE                          COMMAND                  SERVICE         STATUS          PORTS
dolibarr-app         dolibarr/dolibarr:latest       "docker-php-entrypoi…"   dolibarr        running         0.0.0.0:8080->80/tcp
dolibarr-db          mariadb:10.11                  "docker-entrypoint.s…"   dolibarr-db     running         0.0.0.0:3306->3306/tcp
dolibarr-phpmyadmin  phpmyadmin/phpmyadmin:latest   "/docker-entrypoint.…"   phpmyadmin      running         0.0.0.0:8081->80/tcp
```

---

### `task services:logs`

**Description**: Show logs from all services with real-time following

**Usage**:
```bash
task services:logs
```

**What it does**:
- Displays logs from all running containers
- Follows logs in real-time (similar to `tail -f`)
- Press `Ctrl+C` to stop following

**Use cases**:
- Monitor application startup
- Debug service issues
- Monitor real-time activity

---

### `task services:logs-app`

**Description**: Show Dolibarr application logs only

**Usage**:
```bash
task services:logs-app
```

**What it does**:
- Displays logs only from the Dolibarr application container
- Follows logs in real-time
- Useful for application-specific debugging

---

### `task services:logs-db`

**Description**: Show database logs only

**Usage**:
```bash
task services:logs-db
```

**What it does**:
- Displays logs only from the database container
- Follows logs in real-time
- Useful for database-specific debugging

---

## Configuration Commands

### `task config:enable-modules`

**Description**: Enable essential Dolibarr modules for full functionality

**Usage**:
```bash
task config:enable-modules
```

**Prerequisites**: Dolibarr must be running (`task services:start`)

**Modules enabled**:
- Third parties (`MAIN_MODULE_SOCIETE`)
- Invoices (`MAIN_MODULE_FACTURE`)
- Orders (`MAIN_MODULE_COMMANDE`)
- Proposals (`MAIN_MODULE_PROPAL`)
- Products/Services (`MAIN_MODULE_PRODUCT`)
- Stock (`MAIN_MODULE_STOCK`)
- Projects (`MAIN_MODULE_PROJET`)
- Events/Agenda (`MAIN_MODULE_ACTIONCOMM`)
- Categories (`MAIN_MODULE_CATEGORIE`)

**Example output**:
```
Enabling essential Dolibarr modules...
Essential modules enabled successfully
```

---

### `task config:enable-api`

**Description**: Enable REST API module and configure API access

**Usage**:
```bash
task config:enable-api
```

**Prerequisites**: Dolibarr must be running

**What it does**:
- Enables the REST API module (`MAIN_MODULE_API`)
- Provides information about API key generation
- Shows API documentation URL

**Post-configuration**:
- Generate API keys via: Users & Groups > Users > Edit User > API Keys
- API Documentation: `http://localhost:${DOLIBARR_PORT}/api/index.php/explorer`

**Example output**:
```
Enabling REST API module...
API enabled. Generate API keys via Users & Groups > Users > Edit User > API Keys
API Documentation available at http://localhost:18080/api/index.php/explorer
```

---

### `task config:list-modules`

**Description**: List all available and enabled modules

**Usage**:
```bash
task config:list-modules
```

**Prerequisites**: Dolibarr must be running

**What it does**:
- Queries the database for all module configurations
- Shows module names and their status (Enabled/Disabled)
- Sorted alphabetically by module name

**Example output**:
```
Listing Dolibarr modules...
+--------------------+-----------+
| Module             | Status    |
+--------------------+-----------+
| ACTIONCOMM         | Enabled   |
| API                | Enabled   |
| CATEGORIE          | Enabled   |
| COMMANDE           | Enabled   |
| FACTURE            | Enabled   |
| PRODUCT            | Enabled   |
| PROPAL             | Enabled   |
| PROJET             | Enabled   |
| SOCIETE            | Enabled   |
| STOCK              | Enabled   |
+--------------------+-----------+
```

---

### `task config:configure-company`

**Description**: Configure company information and settings

**Usage**:
```bash
task config:configure-company
```

**Prerequisites**: Dolibarr must be running

**What it configures**:
- Company name: "Demo Company Inc."
- Company email: "contact@demo-company.com"
- Currency: "EUR"

**Customization**: Edit the task in `.taskfile/config.yml` to set your own company information

**Example output**:
```
Configuring company information...
Company information configured successfully
```

---

### `task config:setup-dev-environment`

**Description**: Complete development environment setup

**Usage**:
```bash
task config:setup-dev-environment
```

**Prerequisites**: Dolibarr must be running with tools (`task services:start-with-tools`)

**What it does**:
- Runs `task config:enable-modules`
- Runs `task config:enable-api`
- Runs `task config:configure-company`
- Provides access URLs

**Example output**:
```
Setting up development environment...
Enabling essential Dolibarr modules...
Essential modules enabled successfully
Enabling REST API module...
API enabled. Generate API keys via Users & Groups > Users > Edit User > API Keys
API Documentation available at http://localhost:18080/api/index.php/explorer
Configuring company information...
Company information configured successfully
Development environment setup completed!
Dolibarr http://localhost:18080
API Explorer http://localhost:18080/api/index.php/explorer
```

---

### `task config:show-config`

**Description**: Display current Dolibarr configuration status

**Usage**:
```bash
task config:show-config
```

**Prerequisites**: Dolibarr must be running

**What it shows**:
- List of enabled modules
- Company information settings
- Current configuration values

**Example output**:
```
Current Dolibarr Configuration Status

Enabled Modules
+--------------------+
| Module             |
+--------------------+
| ACTIONCOMM         |
| API                |
| CATEGORIE          |
| COMMANDE           |
| FACTURE            |
| PRODUCT            |
| PROPAL             |
| PROJET             |
| SOCIETE            |
| STOCK              |
+--------------------+

Company Information
+-------------------------+------------------------+
| Setting                 | Value                  |
+-------------------------+------------------------+
| MAIN_INFO_SOCIETE_MAIL  | contact@demo-company.com |
| MAIN_INFO_SOCIETE_NOM   | Demo Company Inc.      |
| MAIN_MONNAIE           | EUR                    |
+-------------------------+------------------------+
```

---

## Backup Commands

### `task backup:backup`

**Description**: Create complete backup (database + application data)

**Usage**:
```bash
task backup:backup
```

**Prerequisites**: Services must be running

**What it creates**:
- Database backup (compressed SQL dump)
- Application data backup (documents, custom modules)
- Timestamped backup directory

**Dependencies**: 
- Calls `task backup:backup-db`
- Calls `task backup:backup-app`

**Backup location**: `./backups/YYYY-MM-DD_HH-MM-SS/`

**Example output**:
```
✅ Database backup created
✅ Application backup created
✅ Complete backup created in ./backups/2024-01-15_14-30-45
```

---

### `task backup:backup-db`

**Description**: Create database backup only

**Usage**:
```bash
task backup:backup-db
```

**Prerequisites**: Database container must be running

**What it creates**:
- Compressed SQL dump of the database
- Includes routines and triggers
- Uses single-transaction for consistency

**File format**: `database_YYYY-MM-DD_HH-MM-SS.sql.gz`

**Example output**:
```
✅ Database backup created
```

---

### `task backup:backup-app`

**Description**: Create application data backup (documents, custom modules)

**Usage**:
```bash
task backup:backup-app
```

**What it backs up**:
- `/var/www/documents` (uploaded files, generated documents)
- `/var/www/html` (application files)
- `./custom/` (custom modules)

**File format**: `app_data_YYYY-MM-DD_HH-MM-SS.tar.gz`

**Example output**:
```
✅ Application backup created
```

---

### `task backup:list-backups`

**Description**: List available backups

**Usage**:
```bash
task backup:list-backups
```

**What it shows**:
- All backup directories with timestamps
- File sizes and creation dates
- Handles case when no backups exist

**Example output**:
```
📁 Available backups:
drwxr-xr-x  4 user  staff   128 Jan 15 14:30 2024-01-15_14-30-45
drwxr-xr-x  4 user  staff   128 Jan 14 10:15 2024-01-14_10-15-22
-rw-r--r--  1 user  staff  1.2M Jan 15 14:30 database_2024-01-15_14-30-45.sql.gz
-rw-r--r--  1 user  staff  5.8M Jan 15 14:30 app_data_2024-01-15_14-30-45.tar.gz
```

---

## Maintenance Commands

### `task maintenance:reset-data`

**Description**: Reset all data (DANGEROUS - removes all volumes and data)

**Usage**:
```bash
task maintenance:reset-data
```

**⚠️ WARNING**: This command will delete ALL Dolibarr data including database and documents

**What it does**:
- Prompts for confirmation
- Stops all services
- Removes all Docker volumes
- Prunes Docker volumes
- Clears application logs

**Use cases**:
- Start fresh installation
- Clean development environment
- Remove all test data

**Example output**:
```
This will delete ALL Dolibarr data including database and documents. Continue? [y/N]
✅ All data reset. Use 'task services:start' to initialize fresh installation
```

---

### `task maintenance:reset-logs`

**Description**: Clear application logs

**Usage**:
```bash
task maintenance:reset-logs
```

**What it does**:
- Removes all files from `logs/` directory
- Recreates the logs directory structure

**Example output**:
```
✅ Application logs cleared
```

---

### `task maintenance:reset-custom`

**Description**: Clear custom modules (keeps directory structure)

**Usage**:
```bash
task maintenance:reset-custom
```

**What it does**:
- Prompts for confirmation
- Removes all `.php`, `.js`, and `.css` files from `custom/` directory
- Removes empty directories
- Preserves the `custom/` directory structure

**Example output**:
```
This will delete all custom Dolibarr modules. Continue? [y/N]
✅ Custom modules cleared
```

---

### `task maintenance:cleanup`

**Description**: Clean up Docker resources (images, containers, networks)

**Usage**:
```bash
task maintenance:cleanup
```

**What it does**:
- Stops and removes containers
- Removes locally built images
- Removes volumes and orphaned containers
- Prunes Docker system resources

**Use cases**:
- Free up disk space
- Clean development environment
- Remove unused Docker resources

**Example output**:
```
✅ Docker cleanup completed
```

---

### `task maintenance:update`

**Description**: Update Dolibarr containers to latest versions

**Usage**:
```bash
task maintenance:update
```

**What it does**:
- Pulls latest container images
- Recreates containers with new images
- Maintains data persistence

**Recommendation**: Create a backup before updating

**Example output**:
```
✅ Containers updated and restarted
```

---

## Utility Commands

### `task utilities:shell-app`

**Description**: Open shell in Dolibarr application container

**Usage**:
```bash
task utilities:shell-app
```

**Prerequisites**: Dolibarr container must be running

**What it does**:
- Opens an interactive bash shell inside the Dolibarr container
- Useful for debugging, file inspection, and manual configuration

**Shell access**:
- Working directory: `/var/www/html`
- User: `www-data`
- Available tools: PHP CLI, composer, basic Linux utilities

**Example usage**:
```bash
task utilities:shell-app
# Inside container:
www-data@container:/var/www/html$ ls -la
www-data@container:/var/www/html$ php -v
www-data@container:/var/www/html$ exit
```

---

### `task utilities:shell-db`

**Description**: Open MySQL shell in database container

**Usage**:
```bash
task utilities:shell-db
```

**Prerequisites**: Database container must be running (internal database only)

**What it does**:
- Opens MySQL command-line interface
- Automatically connects to the Dolibarr database
- Uses root credentials from environment variables

**Example usage**:
```bash
task utilities:shell-db
# Inside MySQL shell:
MariaDB [dolibarr]> SHOW TABLES;
MariaDB [dolibarr]> SELECT * FROM llx_const WHERE name LIKE 'MAIN_MODULE_%';
MariaDB [dolibarr]> exit
```

---

### `task utilities:permissions`

**Description**: Fix file permissions for Dolibarr

**Usage**:
```bash
task utilities:permissions
```

**Prerequisites**: Dolibarr container must be running

**What it does**:
- Sets correct ownership for web files (`www-data:www-data`)
- Fixes permissions for `/var/www/html` directory
- Fixes permissions for `/var/www/documents` directory

**When to use**:
- After manual file modifications
- When encountering permission errors
- After restoring from backup

**Example output**:
```
✅ File permissions fixed
```

---

### `task utilities:health`

**Description**: Check health of all services

**Usage**:
```bash
task utilities:health
```

**What it checks**:
- Docker container status
- Web interface accessibility
- phpMyAdmin accessibility (if running)

**Example output**:
```
🔍 Checking service health...
NAME                  IMAGE                          COMMAND                  SERVICE         STATUS          PORTS
dolibarr-app         dolibarr/dolibarr:latest       "docker-php-entrypoi…"   dolibarr        running         0.0.0.0:8080->80/tcp
dolibarr-db          mariadb:10.11                  "docker-entrypoint.s…"   dolibarr-db     running         0.0.0.0:3306->3306/tcp

🌐 Testing web access...
Dolibarr web interface: 200
phpMyAdmin: 200
```

**HTTP Status Codes**:
- `200`: Service is accessible and working
- `unreachable` or `not available`: Service is not accessible

---

## Global Command: `task`

**Description**: Show all available tasks

**Usage**:
```bash
task
# or
task --list
```

**What it shows**:
- All available tasks grouped by namespace
- Brief descriptions for each task

**Example output**:
```
task: Available tasks for this project:

* backup:backup:                Create complete backup (database + application data)
* backup:backup-app:            Create application data backup (documents, custom modules)
* backup:backup-db:             Create database backup
* backup:list-backups:          List available backups
* config:configure-company:     Configure company information and settings
* config:enable-api:            Enable REST API module and configure API access
* config:enable-modules:        Enable essential Dolibarr modules for full functionality
* config:list-modules:          List all available and enabled modules
* config:setup-dev-environment: Complete development environment setup
* config:show-config:           Display current Dolibarr configuration status
* default:                      Show available tasks
* maintenance:cleanup:          Clean up Docker resources (images, containers, networks)
* maintenance:reset-custom:     Clear custom modules (keeps directory structure)
* maintenance:reset-data:       Reset all data (DANGEROUS - removes all volumes and data)
* maintenance:reset-logs:       Clear application logs
* maintenance:update:           Update Dolibarr containers to latest versions
* services:logs:                Show logs from all services
* services:logs-app:            Show Dolibarr application logs
* services:logs-db:             Show database logs
* services:start:               Start Dolibarr with internal database
* services:start-external:      Start Dolibarr with external database
* services:start-with-tools:    Start Dolibarr with internal database and phpMyAdmin
* services:status:              Show status of all services
* services:stop:                Stop all Dolibarr services
* setup:init:                   Initialize Dolibarr setup (create directories and set permissions)
* utilities:health:             Check health of all services
* utilities:permissions:        Fix file permissions for Dolibarr
* utilities:shell-app:          Open shell in Dolibarr application container
* utilities:shell-db:           Open MySQL shell in database container
```

---

## Common Workflows

### First Time Setup
```bash
# 1. Initialize directories
task setup:init

# 2. Start with development tools
task services:start-with-tools

# 3. Configure development environment
task config:setup-dev-environment

# 4. Check health
task utilities:health
```

### Daily Development
```bash
# Start development environment
task services:start-with-tools

# View logs
task services:logs-app

# Make changes...

# Check configuration
task config:show-config

# Stop when done
task services:stop
```

### Production Deployment
```bash
# Start production services (without tools)
task services:start

# Configure for business
task config:configure-company
task config:enable-modules

# Create backup
task backup:backup

# Check health
task utilities:health
```

### Maintenance Tasks
```bash
# Create backup before maintenance
task backup:backup

# Update containers
task maintenance:update

# Clean up if needed
task maintenance:cleanup

# Verify after maintenance
task utilities:health
```
