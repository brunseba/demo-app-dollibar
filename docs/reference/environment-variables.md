# Environment Variables Reference

This document provides a comprehensive reference of all environment variables used in the Dolibarr Docker setup.

## Table of Contents

- [Database Configuration](#database-configuration)
- [Dolibarr Application Configuration](#dolibarr-application-configuration)
- [Network and Port Configuration](#network-and-port-configuration)
- [PHP Configuration](#php-configuration)
- [Optional Tools Configuration](#optional-tools-configuration)
- [Profile-Based Variables](#profile-based-variables)
- [Security Configuration](#security-configuration)
- [Examples by Use Case](#examples-by-use-case)

---

## Database Configuration

### `DB_TYPE`

**Purpose**: Database type for Dolibarr
**Required**: No
**Default**: `mysqli`
**Valid values**: `mysqli`, `pgsql`

**Description**: Specifies the database driver to use. Currently supports MySQL/MariaDB (`mysqli`) and PostgreSQL (`pgsql`).

**Example**:
```env
DB_TYPE=mysqli
```

---

### `DB_HOST`

**Purpose**: Database server hostname or IP address
**Required**: Yes (for external database)
**Default**: `dolibarr-db`

**Description**: The hostname or IP address of the database server. For internal database setups, this should be `dolibarr-db` (the Docker service name). For external databases, use the actual hostname or IP.

**Examples**:
```env
# Internal database
DB_HOST=dolibarr-db

# External database
DB_HOST=mysql.example.com
DB_HOST=192.168.1.100

# Cloud database
DB_HOST=mysql-cluster-abc123.us-west-2.rds.amazonaws.com
```

---

### `DB_PORT`

**Purpose**: Database server port
**Required**: No
**Default**: `3306`

**Description**: The port number on which the database server is listening.

**Examples**:
```env
# Standard MySQL/MariaDB port
DB_PORT=3306

# Custom port
DB_PORT=3307

# PostgreSQL
DB_PORT=5432
```

---

### `DB_NAME`

**Purpose**: Database name for Dolibarr
**Required**: No
**Default**: `dolibarr`

**Description**: The name of the database that Dolibarr will use to store its data.

**Examples**:
```env
# Default database name
DB_NAME=dolibarr

# Custom database name
DB_NAME=my_company_erp

# Environment-specific naming
DB_NAME=dolibarr_production
DB_NAME=dolibarr_staging
```

---

### `DB_USER`

**Purpose**: Database username for Dolibarr
**Required**: No
**Default**: `dolibarr`

**Description**: The username that Dolibarr will use to connect to the database. This user should have full privileges on the specified database.

**Examples**:
```env
# Default username
DB_USER=dolibarr

# Custom username
DB_USER=dolibarr_app

# Environment-specific username
DB_USER=dolibarr_prod_user
```

---

### `DB_PASSWORD`

**Purpose**: Database password for Dolibarr user
**Required**: Yes
**Default**: None

**Description**: The password for the database user. This should be a strong password for security.

**Security Notes**:
- Use a strong password (minimum 16 characters)
- Include uppercase, lowercase, numbers, and special characters
- Never commit real passwords to version control
- Consider using Docker secrets in production

**Examples**:
```env
# Strong password example
DB_PASSWORD=MySecureP@ssw0rd2024!

# For development (still use strong passwords)
DB_PASSWORD=dev-secure-password-123
```

---

### `DB_ROOT_PASSWORD`

**Purpose**: Root password for internal database
**Required**: Yes (for internal database)
**Default**: None

**Description**: The root password for the internal MariaDB database. Only required when using the internal database profile. Leave empty or undefined for external databases.

**Usage**:
- **Internal Database**: Required for database initialization and administration
- **External Database**: Should be empty or undefined

**Examples**:
```env
# Internal database
DB_ROOT_PASSWORD=MySecureRootP@ssw0rd2024!

# External database (leave empty)
DB_ROOT_PASSWORD=
```

---

### `DB_EXTERNAL_PORT`

**Purpose**: External port for database access
**Required**: No
**Default**: `3306`

**Description**: The port on the host machine that will be mapped to the database container. Only applies to internal database setups.

**Examples**:
```env
# Standard port
DB_EXTERNAL_PORT=3306

# Alternative port to avoid conflicts
DB_EXTERNAL_PORT=13306

# Development environment
DB_EXTERNAL_PORT=3307
```

---

## Dolibarr Application Configuration

### `DOLIBARR_ADMIN_LOGIN`

**Purpose**: Initial admin username for Dolibarr
**Required**: No
**Default**: `admin`

**Description**: The username for the initial administrator account that will be created during Dolibarr setup.

**Examples**:
```env
# Default admin username
DOLIBARR_ADMIN_LOGIN=admin

# Custom admin username
DOLIBARR_ADMIN_LOGIN=administrator

# Company-specific admin
DOLIBARR_ADMIN_LOGIN=company_admin
```

---

### `DOLIBARR_ADMIN_PASSWORD`

**Purpose**: Password for the initial admin account
**Required**: Yes
**Default**: None

**Description**: The password for the initial administrator account. This should be changed after first login.

**Security Notes**:
- Use a strong password
- Change the password after first login
- Consider enabling two-factor authentication
- Never use default passwords in production

**Examples**:
```env
# Strong password example
DOLIBARR_ADMIN_PASSWORD=AdminSecureP@ss2024!

# Development password (still secure)
DOLIBARR_ADMIN_PASSWORD=dev-admin-password-123
```

---

### `DOLIBARR_URL_ROOT`

**Purpose**: Base URL for Dolibarr application
**Required**: No
**Default**: `http://localhost:8080`

**Description**: The base URL where Dolibarr will be accessible. This is used for generating links and should match your actual access URL.

**Examples**:
```env
# Local development
DOLIBARR_URL_ROOT=http://localhost:8080

# Custom port
DOLIBARR_URL_ROOT=http://localhost:18080

# Domain-based
DOLIBARR_URL_ROOT=https://dolibarr.example.com

# Subdirectory
DOLIBARR_URL_ROOT=https://example.com/dolibarr
```

---

### `DOLIBARR_NOCSRFCHECK`

**Purpose**: Disable CSRF protection (not recommended)
**Required**: No
**Default**: `0`
**Valid values**: `0` (enabled), `1` (disabled)

**Description**: Controls CSRF (Cross-Site Request Forgery) protection. Should only be disabled for development or testing purposes.

**Security Warning**: Never disable CSRF protection in production environments.

**Examples**:
```env
# Production - CSRF protection enabled (recommended)
DOLIBARR_NOCSRFCHECK=0

# Development - CSRF protection disabled (only for testing)
DOLIBARR_NOCSRFCHECK=1
```

---

### `DOLIBARR_HTTPS`

**Purpose**: Enable HTTPS mode
**Required**: No
**Default**: `0`
**Valid values**: `0` (HTTP), `1` (HTTPS)

**Description**: Indicates whether Dolibarr is running behind HTTPS. Set to 1 when using a reverse proxy with SSL termination.

**Examples**:
```env
# HTTP mode
DOLIBARR_HTTPS=0

# HTTPS mode (with reverse proxy)
DOLIBARR_HTTPS=1
```

---

## Network and Port Configuration

### `DOLIBARR_PORT`

**Purpose**: Host port for Dolibarr web interface
**Required**: No
**Default**: `8080`

**Description**: The port on the host machine where Dolibarr will be accessible.

**Examples**:
```env
# Standard port
DOLIBARR_PORT=8080

# Alternative port
DOLIBARR_PORT=18080

# Production port (with reverse proxy)
DOLIBARR_PORT=80
```

---

## PHP Configuration

### `TIMEZONE`

**Purpose**: PHP timezone setting
**Required**: No
**Default**: `Europe/Paris`

**Description**: Sets the PHP timezone for the Dolibarr application. This affects date/time display and calculations.

**Valid values**: Any valid PHP timezone identifier (see [PHP Timezones](https://www.php.net/manual/en/timezones.php))

**Examples**:
```env
# European timezones
TIMEZONE=Europe/Paris
TIMEZONE=Europe/London
TIMEZONE=Europe/Berlin

# American timezones
TIMEZONE=America/New_York
TIMEZONE=America/Chicago
TIMEZONE=America/Los_Angeles

# Asian timezones
TIMEZONE=Asia/Tokyo
TIMEZONE=Asia/Shanghai
TIMEZONE=Asia/Dubai

# UTC
TIMEZONE=UTC
```

---

## Optional Tools Configuration

### `PHPMYADMIN_PORT`

**Purpose**: Host port for phpMyAdmin interface
**Required**: No (only when using internal-db-tools profile)
**Default**: `8081`

**Description**: The port on the host machine where phpMyAdmin will be accessible. Only used when the `internal-db-tools` profile is active.

**Examples**:
```env
# Standard port
PHPMYADMIN_PORT=8081

# Alternative port
PHPMYADMIN_PORT=18081

# Custom port to avoid conflicts
PHPMYADMIN_PORT=9081
```

---

## Profile-Based Variables

The following variables change behavior based on the Docker Compose profile used:

### Internal Database Profile (`internal-db`)

Required variables:
- `DB_PASSWORD` - Database user password
- `DB_ROOT_PASSWORD` - Database root password
- `DOLIBARR_ADMIN_PASSWORD` - Admin password

Optional variables:
- `DB_NAME` - Database name (default: dolibarr)
- `DB_USER` - Database username (default: dolibarr)
- `DB_EXTERNAL_PORT` - External database port (default: 3306)

**Example configuration**:
```env
# Internal database profile
DB_PASSWORD=secure-db-password-123
DB_ROOT_PASSWORD=secure-root-password-456
DOLIBARR_ADMIN_PASSWORD=secure-admin-password-789
DOLIBARR_PORT=8080
PHPMYADMIN_PORT=8081
```

---

### External Database Profile (`external-db`)

Required variables:
- `DB_HOST` - External database host
- `DB_PASSWORD` - Database user password
- `DOLIBARR_ADMIN_PASSWORD` - Admin password

Optional variables:
- `DB_PORT` - Database port (default: 3306)
- `DB_NAME` - Database name (default: dolibarr)
- `DB_USER` - Database username (default: dolibarr)

**Important**: `DB_ROOT_PASSWORD` should be empty or undefined for external databases.

**Example configuration**:
```env
# External database profile
DB_HOST=mysql.example.com
DB_PORT=3306
DB_NAME=dolibarr
DB_USER=dolibarr_user
DB_PASSWORD=secure-db-password-123
DOLIBARR_ADMIN_PASSWORD=secure-admin-password-789
DOLIBARR_PORT=8080
# DB_ROOT_PASSWORD should be empty for external database
```

---

## Security Configuration

### Production Security Variables

For production environments, ensure these security-focused variables are properly configured:

```env
# Strong passwords (minimum 16 characters)
DB_PASSWORD=ComplexP@ssw0rd!2024SecureDB
DB_ROOT_PASSWORD=RootP@ssw0rd!2024VerySecure
DOLIBARR_ADMIN_PASSWORD=AdminP@ssw0rd!2024SuperSecure

# HTTPS configuration
DOLIBARR_HTTPS=1
DOLIBARR_URL_ROOT=https://dolibarr.yourcompany.com

# CSRF protection enabled
DOLIBARR_NOCSRFCHECK=0

# Restrict database external access
# Don't expose DB_EXTERNAL_PORT in production
# DB_EXTERNAL_PORT=3306  # Comment out for production

# Don't expose phpMyAdmin in production
# PHPMYADMIN_PORT=8081   # Comment out for production
```

### Development Security Variables

For development environments, you can use simpler passwords but should still maintain good security practices:

```env
# Development passwords (still secure)
DB_PASSWORD=dev-secure-db-password
DB_ROOT_PASSWORD=dev-secure-root-password
DOLIBARR_ADMIN_PASSWORD=dev-secure-admin-password

# Development URL
DOLIBARR_URL_ROOT=http://localhost:18080

# Development ports
DOLIBARR_PORT=18080
PHPMYADMIN_PORT=18081
DB_EXTERNAL_PORT=13306

# CSRF can be disabled for testing (if needed)
DOLIBARR_NOCSRFCHECK=0  # Keep enabled even in development
```

---

## Examples by Use Case

### 1. Local Development Setup

Perfect for developers working on Dolibarr customizations or learning the system.

```env
# Database Configuration
DB_TYPE=mysqli
DB_HOST=dolibarr-db
DB_PORT=3306
DB_NAME=dolibarr
DB_USER=dolibarr
DB_PASSWORD=dev-secure-password-123
DB_ROOT_PASSWORD=dev-secure-root-password-456
DB_EXTERNAL_PORT=13306

# Dolibarr Configuration
DOLIBARR_PORT=18080
DOLIBARR_ADMIN_LOGIN=admin
DOLIBARR_ADMIN_PASSWORD=dev-admin-password-789
DOLIBARR_URL_ROOT=http://localhost:18080
DOLIBARR_NOCSRFCHECK=0
DOLIBARR_HTTPS=0

# PHP Configuration
TIMEZONE=America/New_York

# Optional Tools
PHPMYADMIN_PORT=18081
```

**Usage**: 
```bash
task services:start-with-tools
```

---

### 2. Small Business Production

Simple production setup with internal database for small companies.

```env
# Database Configuration
DB_TYPE=mysqli
DB_HOST=dolibarr-db
DB_PORT=3306
DB_NAME=dolibarr
DB_USER=dolibarr
DB_PASSWORD=MyCompanySecureDBPassword2024!
DB_ROOT_PASSWORD=MyCompanySecureRootPassword2024!
# DB_EXTERNAL_PORT not set for security

# Dolibarr Configuration
DOLIBARR_PORT=8080
DOLIBARR_ADMIN_LOGIN=admin
DOLIBARR_ADMIN_PASSWORD=MyCompanyAdminPassword2024!
DOLIBARR_URL_ROOT=https://erp.mycompany.com
DOLIBARR_NOCSRFCHECK=0
DOLIBARR_HTTPS=1

# PHP Configuration
TIMEZONE=Europe/Paris

# Optional Tools - Disabled for production
# PHPMYADMIN_PORT not set for security
```

**Usage**: 
```bash
task services:start
```

---

### 3. Enterprise Production with External Database

High-availability setup using external managed database.

```env
# External Database Configuration
DB_TYPE=mysqli
DB_HOST=dolibarr-prod.cluster-abc123.us-west-2.rds.amazonaws.com
DB_PORT=3306
DB_NAME=dolibarr_production
DB_USER=dolibarr_app_user
DB_PASSWORD=${SECRET_DB_PASSWORD}  # From secrets management
# DB_ROOT_PASSWORD empty for external database

# Dolibarr Configuration
DOLIBARR_PORT=8080
DOLIBARR_ADMIN_LOGIN=sysadmin
DOLIBARR_ADMIN_PASSWORD=${SECRET_ADMIN_PASSWORD}  # From secrets management
DOLIBARR_URL_ROOT=https://erp.enterprise.com
DOLIBARR_NOCSRFCHECK=0
DOLIBARR_HTTPS=1

# PHP Configuration
TIMEZONE=UTC

# Optional Tools - Not used in production
```

**Usage**: 
```bash
task services:start-external
```

---

### 4. Multi-Environment Setup

Development environment configuration for multi-stage deployments.

#### Development Environment:
```env
# Development Database
DB_HOST=dolibarr-db
DB_PASSWORD=dev-secure-password
DB_ROOT_PASSWORD=dev-secure-root-password
DOLIBARR_ADMIN_PASSWORD=dev-admin-password

# Development Ports
DOLIBARR_PORT=18080
PHPMYADMIN_PORT=18081
DB_EXTERNAL_PORT=13306

# Development Settings
DOLIBARR_URL_ROOT=http://localhost:18080
TIMEZONE=America/New_York
```

#### Staging Environment:
```env
# Staging Database (External)
DB_HOST=dolibarr-staging.company.internal
DB_PASSWORD=${STAGING_DB_PASSWORD}
DOLIBARR_ADMIN_PASSWORD=${STAGING_ADMIN_PASSWORD}

# Staging Ports
DOLIBARR_PORT=28080

# Staging Settings
DOLIBARR_URL_ROOT=https://dolibarr-staging.company.internal
DOLIBARR_HTTPS=1
TIMEZONE=UTC
```

#### Production Environment:
```env
# Production Database (External)
DB_HOST=dolibarr-prod.company.internal
DB_PASSWORD=${PROD_DB_PASSWORD}
DOLIBARR_ADMIN_PASSWORD=${PROD_ADMIN_PASSWORD}

# Production Ports
DOLIBARR_PORT=8080

# Production Settings
DOLIBARR_URL_ROOT=https://erp.company.com
DOLIBARR_HTTPS=1
TIMEZONE=UTC
```

---

### 5. Cloud Deployment (AWS)

Configuration for cloud deployment with managed database services.

```env
# AWS RDS Database
DB_TYPE=mysqli
DB_HOST=dolibarr-db.cluster-xyz.us-west-2.rds.amazonaws.com
DB_PORT=3306
DB_NAME=dolibarr
DB_USER=dolibarr_app
# DB_PASSWORD loaded from AWS Secrets Manager
# DB_ROOT_PASSWORD not needed for managed database

# Application Configuration
DOLIBARR_PORT=8080
DOLIBARR_ADMIN_LOGIN=admin
# DOLIBARR_ADMIN_PASSWORD loaded from AWS Secrets Manager
DOLIBARR_URL_ROOT=https://dolibarr.mycompany.com
DOLIBARR_HTTPS=1
DOLIBARR_NOCSRFCHECK=0

# Regional Configuration
TIMEZONE=America/Los_Angeles
```

---

## Variable Validation

### Required Variables Check

Before starting Dolibarr, ensure these variables are set:

**Always Required**:
- `DOLIBARR_ADMIN_PASSWORD`

**Internal Database Profile**:
- `DB_PASSWORD`
- `DB_ROOT_PASSWORD`

**External Database Profile**:
- `DB_HOST`
- `DB_PASSWORD`

### Validation Commands

You can validate your environment variables using these commands:

```bash
# Check if required variables are set
echo "DB_PASSWORD: ${DB_PASSWORD:+SET}"
echo "DOLIBARR_ADMIN_PASSWORD: ${DOLIBARR_ADMIN_PASSWORD:+SET}"

# Display current configuration (without passwords)
echo "DB_HOST: ${DB_HOST}"
echo "DB_PORT: ${DB_PORT}"
echo "DB_NAME: ${DB_NAME}"
echo "DOLIBARR_PORT: ${DOLIBARR_PORT}"
echo "TIMEZONE: ${TIMEZONE}"

# Check password strength (length only)
echo "DB_PASSWORD length: ${#DB_PASSWORD}"
echo "DOLIBARR_ADMIN_PASSWORD length: ${#DOLIBARR_ADMIN_PASSWORD}"
```

---

## Best Practices

### Security Best Practices

1. **Strong Passwords**: Use minimum 16 characters with mixed case, numbers, and symbols
2. **Secrets Management**: Use Docker secrets or external secret management in production
3. **Environment Separation**: Use different passwords for different environments
4. **Port Security**: Don't expose database ports in production
5. **HTTPS**: Always use HTTPS in production environments

### Configuration Best Practices

1. **Environment Files**: Use `.env` files for environment-specific configurations
2. **Version Control**: Never commit `.env` files with real passwords
3. **Documentation**: Document any custom variables or configurations
4. **Validation**: Validate configuration before deployment
5. **Backup**: Include environment configuration in backup procedures

### Development Best Practices

1. **Consistent Ports**: Use consistent port schemes across environments
2. **Clear Naming**: Use descriptive names for custom databases/users
3. **Tool Access**: Enable development tools only in development environments
4. **Logging**: Use appropriate timezone settings for log analysis
5. **Testing**: Test configuration changes in development first
