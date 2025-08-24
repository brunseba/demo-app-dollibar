# Configuration Reference

This document provides a comprehensive reference for all configuration files, their structure, and common settings used in the Dolibarr Docker setup.

## Table of Contents

- [Configuration Files Overview](#configuration-files-overview)
- [Docker Compose Configuration](#docker-compose-configuration)
- [Environment Configuration](#environment-configuration)
- [Taskfile Configuration](#taskfile-configuration)
- [Database Configuration](#database-configuration)
- [Dolibarr Configuration](#dolibarr-configuration)
- [Custom Module Configuration](#custom-module-configuration)
- [Backup Configuration](#backup-configuration)
- [Development Overrides](#development-overrides)
- [Production Configuration](#production-configuration)

---

## Configuration Files Overview

The Dolibarr Docker setup uses multiple configuration files that work together:

| File | Purpose | Format | Required |
|------|---------|--------|----------|
| `.env` | Environment variables | Key=Value | ✅ Yes |
| `.env.example` | Environment template | Key=Value | ⚠️ Template |
| `docker-compose.yml` | Service definitions | YAML | ✅ Yes |
| `docker-compose.override.yml` | Local overrides | YAML | ❌ Optional |
| `Taskfile.yml` | Task definitions | YAML | ✅ Yes |
| `.taskfile/*.yml` | Task modules | YAML | ✅ Yes |

### Configuration Hierarchy

The configuration system follows this precedence order (highest to lowest):

1. **Environment variables** (runtime)
2. **docker-compose.override.yml** (local overrides)
3. **docker-compose.yml** (base configuration)
4. **Default values** (built into images)

---

## Docker Compose Configuration

### Main Configuration File: `docker-compose.yml`

```yaml
services:
  # Dolibarr Application Service
  dolibarr:
    image: dolibarr/dolibarr:latest
    container_name: dolibarr-app
    restart: unless-stopped
    
    # Port mapping
    ports:
      - "${DOLIBARR_PORT:-8080}:80"
    
    # Environment configuration
    environment:
      # Database settings
      DOLI_DB_TYPE: ${DB_TYPE:-mysqli}
      DOLI_DB_HOST: ${DB_HOST:-dolibarr-db}
      DOLI_DB_PORT: ${DB_PORT:-3306}
      DOLI_DB_NAME: ${DB_NAME:-dolibarr}
      DOLI_DB_USER: ${DB_USER:-dolibarr}
      DOLI_DB_PASSWORD: ${DB_PASSWORD}
      DOLI_DB_ROOT_PASSWORD: ${DB_ROOT_PASSWORD:-}
      
      # Application settings
      DOLI_ADMIN_LOGIN: ${DOLIBARR_ADMIN_LOGIN:-admin}
      DOLI_ADMIN_PASSWORD: ${DOLIBARR_ADMIN_PASSWORD}
      DOLI_URL_ROOT: ${DOLIBARR_URL_ROOT:-http://localhost:8080}
      DOLI_NOCSRFCHECK: ${DOLIBARR_NOCSRFCHECK:-0}
      DOLI_HTTPS: ${DOLIBARR_HTTPS:-0}
      
      # PHP settings
      PHP_INI_DATE_TIMEZONE: ${TIMEZONE:-Europe/Paris}
    
    # Volume mounts
    volumes:
      - dolibarr-html:/var/www/html
      - dolibarr-documents:/var/www/documents
      - ./custom:/var/www/html/custom
      - ./logs:/var/www/html/documents/admin/temp
    
    # Service dependencies
    depends_on:
      dolibarr-db:
        condition: service_healthy
        required: false
    
    # Network configuration
    networks:
      - dolibarr-network

  # MariaDB Database Service
  dolibarr-db:
    image: mariadb:10.11
    container_name: dolibarr-db
    restart: unless-stopped
    
    # Port mapping (optional)
    ports:
      - "${DB_EXTERNAL_PORT:-3306}:3306"
    
    # Database environment
    environment:
      MYSQL_ROOT_PASSWORD: ${DB_ROOT_PASSWORD}
      MYSQL_DATABASE: ${DB_NAME:-dolibarr}
      MYSQL_USER: ${DB_USER:-dolibarr}
      MYSQL_PASSWORD: ${DB_PASSWORD}
      MYSQL_CHARSET: utf8mb4
      MYSQL_COLLATION: utf8mb4_unicode_ci
    
    # Data persistence
    volumes:
      - dolibarr-db-data:/var/lib/mysql
      - ./db-init:/docker-entrypoint-initdb.d
    
    # Health check configuration
    healthcheck:
      test: ["CMD", "healthcheck.sh", "--connect", "--innodb_initialized"]
      start_period: 10s
      interval: 10s
      timeout: 5s
      retries: 3
    
    networks:
      - dolibarr-network
    
    # Profile-based activation
    profiles:
      - internal-db

  # phpMyAdmin Service (Development)
  phpmyadmin:
    image: phpmyadmin/phpmyadmin:latest
    container_name: dolibarr-phpmyadmin
    restart: unless-stopped
    
    ports:
      - "${PHPMYADMIN_PORT:-8081}:80"
    
    environment:
      PMA_HOST: dolibarr-db
      PMA_PORT: 3306
      PMA_USER: ${DB_USER:-dolibarr}
      PMA_PASSWORD: ${DB_PASSWORD}
      MYSQL_ROOT_PASSWORD: ${DB_ROOT_PASSWORD}
    
    depends_on:
      dolibarr-db:
        condition: service_healthy
    
    networks:
      - dolibarr-network
    
    profiles:
      - internal-db-tools

# Volume definitions
volumes:
  dolibarr-html:
    driver: local
  dolibarr-documents:
    driver: local
  dolibarr-db-data:
    driver: local

# Network definitions
networks:
  dolibarr-network:
    driver: bridge
```

### Key Configuration Sections

#### Service Configuration

**Dolibarr Service Settings**:
```yaml
dolibarr:
  image: dolibarr/dolibarr:latest    # Container image
  container_name: dolibarr-app       # Fixed container name
  restart: unless-stopped            # Restart policy
```

**Database Service Settings**:
```yaml
dolibarr-db:
  image: mariadb:10.11              # MariaDB version
  restart: unless-stopped            # Restart policy
  profiles: [internal-db]            # Profile activation
```

#### Environment Variable Mapping

Variables are passed from `.env` to container environment:

```yaml
environment:
  DOLI_DB_HOST: ${DB_HOST:-dolibarr-db}     # Default fallback
  DOLI_DB_PASSWORD: ${DB_PASSWORD}          # Required variable
  DOLI_ADMIN_LOGIN: ${DOLIBARR_ADMIN_LOGIN:-admin}  # Optional with default
```

#### Volume Configuration

**Named Volumes** (managed by Docker):
```yaml
volumes:
  - dolibarr-html:/var/www/html         # Application files
  - dolibarr-documents:/var/www/documents # User documents
  - dolibarr-db-data:/var/lib/mysql     # Database files
```

**Bind Mounts** (host directories):
```yaml
volumes:
  - ./custom:/var/www/html/custom       # Custom modules
  - ./logs:/var/www/html/documents/admin/temp # Application logs
  - ./db-init:/docker-entrypoint-initdb.d # DB initialization scripts
```

---

## Environment Configuration

### Environment File: `.env`

The `.env` file contains all configurable parameters:

```env
# Database Configuration
DB_TYPE=mysqli
DB_HOST=dolibarr-db
DB_PORT=3306
DB_NAME=dolibarr
DB_USER=dolibarr
DB_PASSWORD=your-secure-database-password
DB_ROOT_PASSWORD=your-secure-root-password
DB_EXTERNAL_PORT=3306

# Dolibarr Application Configuration
DOLIBARR_PORT=8080
DOLIBARR_ADMIN_LOGIN=admin
DOLIBARR_ADMIN_PASSWORD=your-secure-admin-password
DOLIBARR_URL_ROOT=http://localhost:8080
DOLIBARR_NOCSRFCHECK=0
DOLIBARR_HTTPS=0

# PHP Configuration
TIMEZONE=Europe/Paris

# Optional Tools Configuration
PHPMYADMIN_PORT=8081
```

### Environment Template: `.env.example`

Template file with documentation and examples:

```env
# Database Configuration
# Database type: mysqli for MySQL/MariaDB, pgsql for PostgreSQL
DB_TYPE=mysqli

# Database connection settings
# For internal database, use: dolibarr-db
# For external database, use: your-db-host.com
DB_HOST=dolibarr-db
DB_PORT=3306
DB_NAME=dolibarr
DB_USER=dolibarr

# REQUIRED: Set secure passwords
DB_PASSWORD=change-this-secure-db-password
DB_ROOT_PASSWORD=change-this-secure-root-password

# External port for database access (comment out for production)
DB_EXTERNAL_PORT=3306

# Dolibarr Application Configuration
# Port for web interface
DOLIBARR_PORT=8080

# Initial admin user credentials
DOLIBARR_ADMIN_LOGIN=admin
DOLIBARR_ADMIN_PASSWORD=change-this-secure-admin-password

# Base URL for the application
DOLIBARR_URL_ROOT=http://localhost:8080

# Security settings
DOLIBARR_NOCSRFCHECK=0  # 0=enabled (recommended), 1=disabled
DOLIBARR_HTTPS=0        # 0=HTTP, 1=HTTPS (when behind SSL proxy)

# PHP Configuration
# See: https://www.php.net/manual/en/timezones.php
TIMEZONE=Europe/Paris

# Optional Tools
# Port for phpMyAdmin (comment out for production)
PHPMYADMIN_PORT=8081

# Profile-based Database Configuration
# 
# For INTERNAL database (default): docker-compose --profile internal-db up -d
# For EXTERNAL database: Configure variables below and use --profile external-db
#
# When using EXTERNAL database profile, configure these variables:
# DB_HOST=your-external-db-host
# DB_PORT=3306
# DB_NAME=dolibarr
# DB_USER=dolibarr_user
# DB_PASSWORD=your-external-db-password
# DB_ROOT_PASSWORD=  # Leave empty for external database

# Security Notes:
# - Change all default passwords before production use
# - Use strong passwords (minimum 16 characters)
# - Consider using Docker secrets for sensitive data in production
# - Restrict database external port access in production
# - When using external database, ensure network security between containers and database
```

### Environment Variable Categories

#### Database Variables
```env
DB_TYPE=mysqli                    # Database driver
DB_HOST=dolibarr-db              # Database hostname
DB_PORT=3306                     # Database port
DB_NAME=dolibarr                 # Database name
DB_USER=dolibarr                 # Application database user
DB_PASSWORD=secure-password      # Application user password
DB_ROOT_PASSWORD=root-password   # Database root password (internal DB only)
DB_EXTERNAL_PORT=3306           # Host port mapping (optional)
```

#### Application Variables
```env
DOLIBARR_PORT=8080                        # Host port for web interface
DOLIBARR_ADMIN_LOGIN=admin                # Initial admin username
DOLIBARR_ADMIN_PASSWORD=admin-password    # Initial admin password
DOLIBARR_URL_ROOT=http://localhost:8080   # Base application URL
DOLIBARR_NOCSRFCHECK=0                    # CSRF protection (0=on, 1=off)
DOLIBARR_HTTPS=0                          # HTTPS mode (0=HTTP, 1=HTTPS)
```

#### System Variables
```env
TIMEZONE=Europe/Paris            # PHP timezone
PHPMYADMIN_PORT=8081            # phpMyAdmin port (development)
```

---

## Taskfile Configuration

### Main Taskfile: `Taskfile.yml`

```yaml
version: '3'

# Include sub-taskfiles for organization
includes:
  setup:
    taskfile: .taskfile/setup.yml
  services:
    taskfile: .taskfile/services.yml
  config:
    taskfile: .taskfile/config.yml
  backup:
    taskfile: .taskfile/backup.yml
  maintenance:
    taskfile: .taskfile/maintenance.yml
  utilities:
    taskfile: .taskfile/utilities.yml

# Global variables available to all tasks
vars:
  BACKUP_DIR: ./backups
  TIMESTAMP: '{{now | date "2006-01-02_15-04-05"}}'
  COMPOSE_FILE: docker-compose.yml

# Default task
tasks:
  default:
    desc: Show available tasks
    cmds:
      - task --list
```

### Task Module Structure

Each module in `.taskfile/` contains related tasks:

**Setup Tasks** (`.taskfile/setup.yml`):
```yaml
version: '3'

tasks:
  init:
    desc: Initialize Dolibarr setup (create directories and set permissions)
    cmds:
      - mkdir -p custom logs db-init {{.BACKUP_DIR}}
      - chmod 755 custom logs db-init {{.BACKUP_DIR}}
      - echo "✅ Dolibarr directories initialized"
```

**Service Tasks** (`.taskfile/services.yml`):
```yaml
version: '3'

tasks:
  start:
    desc: Start Dolibarr with internal database
    cmds:
      - docker-compose --profile internal-db up -d
      - echo "✅ Dolibarr started with internal database"

  start-with-tools:
    desc: Start Dolibarr with internal database and phpMyAdmin
    cmds:
      - docker-compose --profile internal-db --profile internal-db-tools up -d
      - echo "✅ Dolibarr started with internal database and phpMyAdmin"

  start-external:
    desc: Start Dolibarr with external database
    cmds:
      - docker-compose --profile external-db up -d
      - echo "✅ Dolibarr started with external database"

  stop:
    desc: Stop all Dolibarr services
    cmds:
      - docker-compose down
      - echo "✅ Dolibarr services stopped"
```

### Task Configuration Patterns

#### Task with Preconditions
```yaml
task-name:
  desc: Task description
  preconditions:
    - sh: docker-compose ps dolibarr | grep -q "Up"
      msg: "Dolibarr container is not running. Start with: task services:start"
  cmds:
    - echo "Task commands here"
```

#### Task with Dependencies
```yaml
backup:
  desc: Create complete backup
  deps: [backup-db, backup-app]    # Run these tasks first
  cmds:
    - echo "✅ Complete backup created in {{.BACKUP_DIR}}/{{.TIMESTAMP}}"
```

#### Task with Variables
```yaml
backup-db:
  desc: Create database backup
  vars:
    BACKUP_FILE: "database_{{.TIMESTAMP}}.sql.gz"
  cmds:
    - mkdir -p {{.BACKUP_DIR}}/{{.TIMESTAMP}}
    - docker-compose exec -T dolibarr-db mysqldump ... | gzip > {{.BACKUP_DIR}}/{{.TIMESTAMP}}/{{.BACKUP_FILE}}
```

---

## Database Configuration

### MariaDB Configuration

The database service uses environment variables for configuration:

```yaml
environment:
  # Required settings
  MYSQL_ROOT_PASSWORD: ${DB_ROOT_PASSWORD}      # Root user password
  MYSQL_DATABASE: ${DB_NAME:-dolibarr}          # Database to create
  MYSQL_USER: ${DB_USER:-dolibarr}              # Application user
  MYSQL_PASSWORD: ${DB_PASSWORD}                # Application password
  
  # Character set settings
  MYSQL_CHARSET: utf8mb4                        # UTF-8 character set
  MYSQL_COLLATION: utf8mb4_unicode_ci          # Unicode collation
```

### Database Initialization

Scripts in `./db-init/` are executed when the database container first starts:

**Example initialization script** (`db-init/01-custom-settings.sql`):
```sql
-- Custom database settings
SET GLOBAL innodb_buffer_pool_size = 268435456;  -- 256MB
SET GLOBAL max_connections = 100;
SET GLOBAL query_cache_size = 16777216;          -- 16MB

-- Create additional users if needed
-- CREATE USER 'readonly'@'%' IDENTIFIED BY 'readonly_password';
-- GRANT SELECT ON dolibarr.* TO 'readonly'@'%';
```

**Shell script example** (`db-init/02-setup.sh`):
```bash
#!/bin/bash
echo "Running custom database setup..."

# Wait for database to be fully ready
until mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "SELECT 1"; do
  echo "Waiting for database..."
  sleep 5
done

echo "Database setup completed"
```

### Database Health Check

The health check ensures the database is ready before starting dependent services:

```yaml
healthcheck:
  test: ["CMD", "healthcheck.sh", "--connect", "--innodb_initialized"]
  start_period: 10s    # Wait 10 seconds before first check
  interval: 10s        # Check every 10 seconds
  timeout: 5s          # 5 second timeout per check
  retries: 3           # Retry 3 times before marking unhealthy
```

---

## Dolibarr Configuration

### Application Environment Variables

Variables passed to the Dolibarr container:

```yaml
environment:
  # Database connection
  DOLI_DB_TYPE: ${DB_TYPE:-mysqli}              # Database driver
  DOLI_DB_HOST: ${DB_HOST:-dolibarr-db}         # Database host
  DOLI_DB_PORT: ${DB_PORT:-3306}                # Database port
  DOLI_DB_NAME: ${DB_NAME:-dolibarr}            # Database name
  DOLI_DB_USER: ${DB_USER:-dolibarr}            # Database user
  DOLI_DB_PASSWORD: ${DB_PASSWORD}              # Database password
  DOLI_DB_ROOT_PASSWORD: ${DB_ROOT_PASSWORD:-}  # Root password (optional)
  
  # Application settings
  DOLI_ADMIN_LOGIN: ${DOLIBARR_ADMIN_LOGIN:-admin}           # Admin username
  DOLI_ADMIN_PASSWORD: ${DOLIBARR_ADMIN_PASSWORD}            # Admin password
  DOLI_URL_ROOT: ${DOLIBARR_URL_ROOT:-http://localhost:8080} # Base URL
  DOLI_NOCSRFCHECK: ${DOLIBARR_NOCSRFCHECK:-0}               # CSRF protection
  DOLI_HTTPS: ${DOLIBARR_HTTPS:-0}                           # HTTPS mode
  
  # PHP settings
  PHP_INI_DATE_TIMEZONE: ${TIMEZONE:-Europe/Paris}           # Timezone
```

### Dolibarr Configuration Files

After initialization, Dolibarr creates configuration files inside the container:

**Main configuration** (`/var/www/html/conf/conf.php`):
```php
<?php
// Database settings
$dolibarr_main_url_root='http://localhost:8080';
$dolibarr_main_document_root='/var/www/html';
$dolibarr_main_url_root_alt='/custom';
$dolibarr_main_document_root_alt='/var/www/html/custom';
$dolibarr_main_data_root='/var/www/documents';
$dolibarr_main_db_host='dolibarr-db';
$dolibarr_main_db_port='3306';
$dolibarr_main_db_name='dolibarr';
$dolibarr_main_db_prefix='llx_';
$dolibarr_main_db_user='dolibarr';
$dolibarr_main_db_pass='password_hash';
$dolibarr_main_db_type='mysqli';
$dolibarr_main_db_character_set='utf8mb4';
$dolibarr_main_db_collation='utf8mb4_unicode_ci';
?>
```

### Module Configuration

Module enablement is stored in the database (`llx_const` table):

```sql
-- Examples of module constants
INSERT INTO llx_const (name, value, type, visible, note, entity) VALUES
('MAIN_MODULE_SOCIETE', '1', 'chaine', 0, 'To enable module Third parties', 1),
('MAIN_MODULE_FACTURE', '1', 'chaine', 0, 'To enable module Invoices', 1),
('MAIN_MODULE_API', '1', 'chaine', 0, 'To enable module API', 1);
```

---

## Custom Module Configuration

### Custom Module Structure

Custom modules are placed in the `./custom/` directory:

```
custom/
├── mymodule/                    # Module directory
│   ├── core/                   # Core module files
│   ├── admin/                  # Administration pages
│   ├── class/                  # PHP classes
│   ├── lang/                   # Language files
│   ├── img/                    # Images and icons
│   ├── js/                     # JavaScript files
│   ├── css/                    # CSS stylesheets
│   ├── mymodule.php           # Main module descriptor
│   └── README.md              # Module documentation
└── README.md                   # Custom modules documentation
```

### Module Descriptor Example

**mymodule/mymodule.php**:
```php
<?php
include_once DOL_DOCUMENT_ROOT.'/core/modules/DolibarrModules.class.php';

class modMyModule extends DolibarrModules
{
    public function __construct($db)
    {
        parent::__construct($db);
        
        $this->numero = 104000;
        $this->rights_class = 'mymodule';
        $this->family = "other";
        $this->name = 'MyModule';
        $this->description = 'My Custom Module';
        $this->descriptionlong = 'Extended description of my custom module';
        $this->version = '1.0.0';
        $this->const_name = 'MAIN_MODULE_MYMODULE';
        
        // Dependencies
        $this->depends = array('modSociete');
        $this->requiredby = array();
        
        // Configuration
        $this->config_page_url = array('admin/setup.php@mymodule');
        
        // Menu entries
        $this->menu = array();
        
        // Permissions
        $this->rights = array();
        
        // Database tables
        $this->boxes = array();
    }
}
?>
```

---

## Backup Configuration

### Backup Task Configuration

Backup tasks are defined in `.taskfile/backup.yml`:

```yaml
version: '3'

tasks:
  backup:
    desc: Create complete backup (database + application data)
    deps: [backup-db, backup-app]
    cmds:
      - echo "✅ Complete backup created in {{.BACKUP_DIR}}/{{.TIMESTAMP}}"

  backup-db:
    desc: Create database backup
    preconditions:
      - sh: docker-compose ps dolibarr-db | grep -q "Up"
        msg: "Database container is not running. Start with: task services:start"
    cmds:
      - mkdir -p {{.BACKUP_DIR}}/{{.TIMESTAMP}}
      - docker-compose exec -T dolibarr-db mysqldump -u root -p$DB_ROOT_PASSWORD --single-transaction --routines --triggers dolibarr | gzip > {{.BACKUP_DIR}}/{{.TIMESTAMP}}/database_{{.TIMESTAMP}}.sql.gz
      - echo "✅ Database backup created"

  backup-app:
    desc: Create application data backup
    cmds:
      - mkdir -p {{.BACKUP_DIR}}/{{.TIMESTAMP}}
      - docker run --rm -v dolibarr_dolibarr-documents:/source/documents:ro -v dolibarr_dolibarr-html:/source/html:ro -v $(pwd)/custom:/source/custom:ro -v $(pwd)/{{.BACKUP_DIR}}/{{.TIMESTAMP}}:/backup alpine:latest sh -c 'cd /backup && tar -czf app_data_{{.TIMESTAMP}}.tar.gz -C /source documents html custom'
      - echo "✅ Application backup created"
```

### Backup Directory Structure

```
backups/
├── 2024-01-15_14-30-45/
│   ├── database_2024-01-15_14-30-45.sql.gz    # Database dump
│   └── app_data_2024-01-15_14-30-45.tar.gz    # Application files
├── 2024-01-14_10-15-22/
│   ├── database_2024-01-14_10-15-22.sql.gz
│   └── app_data_2024-01-14_10-15-22.tar.gz
└── README.md                                    # Backup documentation
```

---

## Development Overrides

### Docker Compose Override: `docker-compose.override.yml`

This file allows local customizations without modifying the main configuration:

```yaml
version: '3.8'

services:
  dolibarr:
    # Development-specific environment variables
    environment:
      # Enable debug mode
      DOLI_DEBUG: 1
      
      # Disable CSRF for easier API testing
      DOLI_NOCSRFCHECK: 1
      
      # PHP development settings
      PHP_DISPLAY_ERRORS: 1
      PHP_LOG_ERRORS: 1
      PHP_ERROR_REPORTING: E_ALL
    
    # Additional volumes for development
    volumes:
      # Mount source code for live editing
      - ./src:/var/www/html/custom/dev
      
      # Development tools
      - ./dev-tools:/var/www/html/dev-tools
    
    # Labels for development tools
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.dolibarr-dev.rule=Host(`dolibarr.localhost`)"

  dolibarr-db:
    # Development database settings
    environment:
      # Enable query logging
      MYSQL_GENERAL_LOG: 1
      MYSQL_GENERAL_LOG_FILE: /var/lib/mysql/general.log
      
      # Performance settings for development
      MYSQL_INNODB_BUFFER_POOL_SIZE: 128M
    
    # Expose additional ports for debugging
    ports:
      - "3307:3306"

  # Additional development services
  mailhog:
    image: mailhog/mailhog:latest
    container_name: dolibarr-mailhog
    ports:
      - "1025:1025"   # SMTP
      - "8025:8025"   # Web UI
    networks:
      - dolibarr-network

  redis:
    image: redis:alpine
    container_name: dolibarr-redis
    ports:
      - "6379:6379"
    networks:
      - dolibarr-network
```

### Development Environment Variables

**Development .env**:
```env
# Development-specific settings
DOLIBARR_PORT=18080
PHPMYADMIN_PORT=18081
DB_EXTERNAL_PORT=13306

# Relaxed security for development
DOLIBARR_NOCSRFCHECK=1

# Development URLs
DOLIBARR_URL_ROOT=http://localhost:18080

# Development database settings
DB_PASSWORD=dev-password
DB_ROOT_PASSWORD=dev-root-password
DOLIBARR_ADMIN_PASSWORD=dev-admin-password

# Development timezone
TIMEZONE=America/New_York
```

---

## Production Configuration

### Production Docker Compose

**docker-compose.prod.yml**:
```yaml
version: '3.8'

services:
  dolibarr:
    # Production image with specific version
    image: dolibarr/dolibarr:19.0.0
    
    # Always restart in production
    restart: always
    
    # Production environment
    environment:
      # Security settings
      DOLI_NOCSRFCHECK: 0
      DOLI_HTTPS: 1
      
      # Performance settings
      PHP_MEMORY_LIMIT: 512M
      PHP_MAX_EXECUTION_TIME: 300
      PHP_UPLOAD_MAX_FILESIZE: 100M
    
    # Production volumes (external storage)
    volumes:
      - dolibarr-html:/var/www/html
      - /mnt/shared-storage/dolibarr/documents:/var/www/documents
      - /opt/dolibarr/custom:/var/www/html/custom:ro
      - /var/log/dolibarr:/var/www/html/documents/admin/temp
    
    # Resource limits
    deploy:
      resources:
        limits:
          memory: 1G
          cpus: '1'
        reservations:
          memory: 512M
          cpus: '0.5'
    
    # Structured logging
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
    
    # Security labels
    labels:
      - "com.example.environment=production"
      - "com.example.application=dolibarr"

  # Remove database for external DB in production
  dolibarr-db:
    profiles:
      - disabled

  # Remove development tools
  phpmyadmin:
    profiles:
      - disabled

# Production volumes
volumes:
  dolibarr-html:
    driver: local
    driver_opts:
      type: nfs
      o: addr=nfs.company.com,rw
      device: ":/mnt/dolibarr/html"

# Production networks
networks:
  dolibarr-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/24
```

### Production Environment Variables

**Production .env**:
```env
# Production Database (External)
DB_TYPE=mysqli
DB_HOST=dolibarr-prod.cluster-abc123.rds.amazonaws.com
DB_PORT=3306
DB_NAME=dolibarr_production
DB_USER=dolibarr_app_user
DB_PASSWORD=${SECRET_DB_PASSWORD}
# DB_ROOT_PASSWORD not needed for external database

# Production Application
DOLIBARR_PORT=8080
DOLIBARR_ADMIN_LOGIN=admin
DOLIBARR_ADMIN_PASSWORD=${SECRET_ADMIN_PASSWORD}
DOLIBARR_URL_ROOT=https://erp.company.com
DOLIBARR_HTTPS=1
DOLIBARR_NOCSRFCHECK=0

# Production PHP Settings
TIMEZONE=UTC

# Production Security
# Don't expose database port
# DB_EXTERNAL_PORT not set

# Don't expose development tools
# PHPMYADMIN_PORT not set
```

### Production Security Configuration

**Security headers** (Nginx reverse proxy):
```nginx
server {
    listen 443 ssl http2;
    server_name erp.company.com;
    
    # SSL configuration
    ssl_certificate /etc/ssl/certs/company.crt;
    ssl_certificate_key /etc/ssl/private/company.key;
    
    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Content-Type-Options nosniff;
    add_header X-Frame-Options DENY;
    add_header X-XSS-Protection "1; mode=block";
    add_header Referrer-Policy "strict-origin-when-cross-origin";
    
    # CSP header
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'";
    
    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # File upload limits
        client_max_body_size 100M;
    }
}
```

---

## Configuration Best Practices

### Security Best Practices

1. **Strong Passwords**: Use minimum 16 characters with mixed complexity
2. **Secrets Management**: Use Docker secrets or external secret management
3. **Port Exposure**: Only expose necessary ports
4. **HTTPS**: Always use HTTPS in production
5. **Regular Updates**: Keep configurations and images updated

### Environment Management

1. **Environment Separation**: Use different configurations for different environments
2. **Configuration Validation**: Validate configurations before deployment
3. **Version Control**: Track configuration changes (excluding secrets)
4. **Documentation**: Document all custom configurations
5. **Backup**: Include configuration files in backup strategies

### Performance Configuration

1. **Resource Limits**: Set appropriate CPU and memory limits
2. **Volume Strategy**: Use appropriate volume types for data
3. **Network Optimization**: Configure networks for performance
4. **Monitoring**: Implement configuration monitoring
5. **Tuning**: Regular performance tuning based on usage patterns

Remember to always test configuration changes in a development environment before applying them to production!
