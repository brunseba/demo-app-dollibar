# Dolibarr Docker - Quick Reference Cheat Sheet

One-page reference for essential commands, configurations, and troubleshooting.

## 🚀 Quick Start Commands

```bash
# Initial Setup
git clone <repository> dolibarr-project && cd dolibarr-project
cp .env.example .env    # Edit with your settings
task setup:init         # Create directories

# Development Environment
task services:start-with-tools     # Start with phpMyAdmin
task config:setup-dev-environment  # Configure for development
task utilities:health              # Check system health

# Production Environment  
task services:start                 # Start production services
task config:configure-company      # Setup company info
task config:enable-modules         # Enable essential modules
```

## ⚙️ Essential Environment Variables

| Variable | Default | Description | Example |
|----------|---------|-------------|---------|
| `DOLIBARR_PORT` | `8080` | Web interface port | `18080` |
| `DB_PASSWORD` | - | Database password (required) | `secure-db-pass` |
| `DB_ROOT_PASSWORD` | - | Root password (required) | `secure-root-pass` |
| `DOLIBARR_ADMIN_PASSWORD` | - | Admin password (required) | `admin-secure-pass` |
| `TIMEZONE` | `Europe/Paris` | PHP timezone | `America/New_York` |
| `PHPMYADMIN_PORT` | `8081` | phpMyAdmin port | `18081` |

## 🐳 Docker Profiles

| Profile | Command | Services | Use Case |
|---------|---------|----------|----------|
| Internal DB | `task services:start` | Dolibarr + MariaDB | Production |
| Internal DB + Tools | `task services:start-with-tools` | + phpMyAdmin | Development |
| External DB | `task services:start-external` | Dolibarr only | Enterprise |

## 📋 Essential Task Commands

### Service Management
```bash
task services:start                 # Start with internal database
task services:start-with-tools      # Start with development tools  
task services:start-external        # Start with external database
task services:stop                  # Stop all services
task services:status                # Show service status
task services:logs                  # View all logs
task services:logs-app              # View application logs only
```

### Configuration
```bash
task config:setup-dev-environment   # Complete dev setup
task config:enable-modules          # Enable essential modules
task config:enable-api              # Enable REST API
task config:configure-company       # Setup company information
task config:show-config             # Display current config
task config:list-modules            # List enabled modules
```

### Backup & Maintenance
```bash
task backup:backup                  # Complete backup (DB + files)
task backup:backup-db               # Database backup only
task backup:list-backups            # List available backups
task maintenance:update             # Update containers
task maintenance:cleanup            # Clean Docker resources
```

### Utilities
```bash
task utilities:health               # System health check
task utilities:shell-app            # Shell into application
task utilities:shell-db             # MySQL shell
task utilities:permissions          # Fix file permissions
```

## 🌐 Access URLs

| Service | URL | Purpose |
|---------|-----|---------|
| **Dolibarr** | `http://localhost:8080` | Main application |
| **phpMyAdmin** | `http://localhost:8081` | Database management |
| **API Explorer** | `http://localhost:8080/api/index.php/explorer` | API testing |

*Adjust ports based on your `.env` configuration*

## 🔧 Common Configurations

### Development .env
```env
DOLIBARR_PORT=18080
PHPMYADMIN_PORT=18081
DB_EXTERNAL_PORT=13306
DB_PASSWORD=dev-secure-password
DB_ROOT_PASSWORD=dev-secure-root-password
DOLIBARR_ADMIN_PASSWORD=dev-admin-password
TIMEZONE=America/New_York
```

### Production .env
```env
DOLIBARR_PORT=8080
DB_PASSWORD=your-very-secure-password
DB_ROOT_PASSWORD=your-very-secure-root-password
DOLIBARR_ADMIN_PASSWORD=your-admin-password
DOLIBARR_URL_ROOT=https://erp.yourcompany.com
DOLIBARR_HTTPS=1
TIMEZONE=UTC
# Don't expose these in production:
# PHPMYADMIN_PORT=8081
# DB_EXTERNAL_PORT=3306
```

## 🚨 Quick Troubleshooting

### Service Won't Start
```bash
# Check what's using the port
lsof -i :8080

# Check Docker status
docker version && docker-compose version

# View detailed logs
task services:logs

# Reset everything (DANGEROUS - loses data)
task maintenance:reset-data
```

### Database Issues
```bash
# Check database health
docker-compose exec dolibarr-db mysqladmin ping

# Test database connection
docker-compose exec dolibarr nc -zv dolibarr-db 3306

# View database logs
task services:logs-db
```

### Application Issues
```bash
# Check web server status
curl -I http://localhost:8080

# Fix file permissions
task utilities:permissions

# Check configuration
task config:show-config
```

### API Issues
```bash
# Enable API module
task config:enable-api

# Test API connectivity
curl http://localhost:8080/api/index.php/explorer

# Check API configuration
task config:list-modules | grep API
```

## 🔐 Security Checklist

### Development
- [ ] Use secure passwords (min 16 chars)
- [ ] Don't commit `.env` files
- [ ] Use development ports (18xxx)
- [ ] Keep CSRF protection enabled

### Production
- [ ] Change all default passwords
- [ ] Use HTTPS (set `DOLIBARR_HTTPS=1`)
- [ ] Don't expose phpMyAdmin
- [ ] Don't expose database port
- [ ] Use external database for HA
- [ ] Enable regular backups
- [ ] Setup reverse proxy with SSL

## 📊 Health Check Commands

```bash
# Quick system check
task utilities:health

# Service status
task services:status

# Resource usage
docker stats --no-stream

# Disk usage
df -h && docker system df

# Network connectivity
curl -f http://localhost:8080/index.php
```

## 🔄 Common Workflows

### First Time Setup
```bash
task setup:init
task services:start-with-tools
task config:setup-dev-environment
task utilities:health
```

### Daily Development
```bash
task services:start-with-tools
# Work on your project
task services:logs-app           # Check logs
task config:show-config         # Verify config
task services:stop              # Stop when done
```

### Production Deployment
```bash
# Setup production environment
task services:start
task config:configure-company
task config:enable-modules
task backup:backup
task utilities:health
```

### Backup & Update
```bash
task backup:backup              # Create backup first
task maintenance:update         # Update containers
task utilities:health           # Verify health
```

## 📁 Directory Structure

```
dolibarr-project/
├── .env                        # Environment configuration
├── .env.example               # Environment template
├── docker-compose.yml         # Service definitions
├── Taskfile.yml              # Task automation
├── custom/                    # Custom modules
├── logs/                      # Application logs
├── backups/                   # Data backups
├── db-init/                   # Database init scripts
└── docs/                      # Documentation
    ├── reference/             # Technical references
    ├── deployment-scenarios.md
    └── README.md
```

## 🆘 Emergency Commands

```bash
# System completely broken?
task maintenance:reset-data     # DANGER: Deletes all data!
task setup:init
task services:start-with-tools

# Database corrupted?
task services:stop
docker volume rm dolibarr_dolibarr-db-data
task services:start

# Out of disk space?
task maintenance:cleanup
docker system prune -a

# Container won't stop?
docker-compose kill
docker-compose down --remove-orphans
```

## 📞 Getting Help

### Documentation
- **Reference Docs**: `docs/reference/README.md`
- **Troubleshooting**: `docs/reference/troubleshooting.md`
- **API Guide**: `docs/reference/api-reference.md`

### Online Resources
- **Dolibarr Forum**: https://www.dolibarr.org/forum
- **Docker Docs**: https://docs.docker.com/
- **Task Docs**: https://taskfile.dev/

### Stack Overflow
- Tag: `dolibarr` `docker` `docker-compose` `mariadb`

---

**💡 Pro Tip**: Bookmark this page and keep your `.env` file secure! 

**🔗 Quick Links**: [Full Reference](README.md) | [Troubleshooting](troubleshooting.md) | [API Guide](api-reference.md)
