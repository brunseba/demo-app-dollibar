# Troubleshooting Reference

This document provides comprehensive troubleshooting guidance for common issues encountered with the Dolibarr Docker setup.

## Table of Contents

- [Quick Diagnostics](#quick-diagnostics)
- [Service Issues](#service-issues)
- [Database Issues](#database-issues)
- [Application Issues](#application-issues)
- [Network and Connectivity Issues](#network-and-connectivity-issues)
- [Performance Issues](#performance-issues)
- [Configuration Issues](#configuration-issues)
- [File and Permission Issues](#file-and-permission-issues)
- [Backup and Recovery Issues](#backup-and-recovery-issues)
- [Development and Custom Module Issues](#development-and-custom-module-issues)
- [Error Message Reference](#error-message-reference)
- [Log Analysis](#log-analysis)

---

## Quick Diagnostics

When encountering any issue, start with these quick diagnostic commands:

### System Health Check
```bash
# Overall health check
task utilities:health

# Service status
task services:status

# Check logs for errors
task services:logs | tail -50
```

### Environment Validation
```bash
# Check required environment variables
echo "DB_PASSWORD: ${DB_PASSWORD:+SET}"
echo "DOLIBARR_ADMIN_PASSWORD: ${DOLIBARR_ADMIN_PASSWORD:+SET}"

# Verify .env file exists and is readable
ls -la .env
cat .env | grep -v PASSWORD
```

### Container Status
```bash
# Check container states
docker-compose ps

# Check resource usage
docker stats --no-stream

# Check Docker daemon
docker version
docker info
```

---

## Service Issues

### Services Won't Start

**Symptoms**:
- `docker-compose up` fails
- Services exit immediately
- "Service is unhealthy" messages

**Diagnostic Commands**:
```bash
# Check detailed service logs
task services:logs

# Check specific service
docker-compose logs dolibarr
docker-compose logs dolibarr-db

# Check container exit codes
docker-compose ps -a
```

**Common Causes and Solutions**:

#### 1. Port Conflicts
**Error**: `Port already in use` or `bind: address already in use`

**Solution**:
```bash
# Check what's using the port
lsof -i :8080
netstat -tlnp | grep :8080

# Change ports in .env
DOLIBARR_PORT=18080
PHPMYADMIN_PORT=18081
DB_EXTERNAL_PORT=13306
```

#### 2. Missing Environment Variables
**Error**: `Error: DOLIBARR_ADMIN_PASSWORD is not set`

**Solution**:
```bash
# Check .env file
cat .env

# Copy from example if missing
cp .env.example .env
# Edit .env with your values
```

#### 3. Invalid Docker Compose Profile
**Error**: No services start despite running `docker-compose up`

**Solution**:
```bash
# Use correct profile
task services:start                # Internal DB
task services:start-with-tools     # Internal DB + tools
task services:start-external       # External DB
```

#### 4. Docker Daemon Issues
**Error**: `Cannot connect to Docker daemon`

**Solution**:
```bash
# Check Docker service
sudo systemctl status docker

# Start Docker service
sudo systemctl start docker

# Check user permissions (Linux)
sudo usermod -aG docker $USER
# Logout and login again
```

---

### Service Keeps Restarting

**Symptoms**:
- Service status shows "Restarting"
- Container exits with non-zero code
- Service becomes unhealthy

**Diagnostic Commands**:
```bash
# Check restart count
docker-compose ps

# Check service logs
docker-compose logs --tail=100 dolibarr

# Check container resource limits
docker stats dolibarr-app
```

**Common Causes and Solutions**:

#### 1. Database Connection Issues
**Solution**: See [Database Issues](#database-issues) section

#### 2. Insufficient Resources
**Error**: `OOMKilled` or high memory usage

**Solution**:
```bash
# Check available resources
free -h
df -h

# Add resource limits
# docker-compose.override.yml
services:
  dolibarr:
    deploy:
      resources:
        limits:
          memory: 1G
```

#### 3. Configuration Errors
**Solution**:
```bash
# Check configuration syntax
docker-compose config

# Validate environment variables
task config:show-config
```

---

## Database Issues

### Database Won't Start

**Symptoms**:
- Database container exits immediately
- Health check fails
- Connection refused errors

**Diagnostic Commands**:
```bash
# Check database logs
task services:logs-db

# Check database health
docker-compose exec dolibarr-db mysqladmin ping

# Check data directory
docker volume inspect dolibarr_dolibarr-db-data
```

**Common Causes and Solutions**:

#### 1. Corrupted Database Volume
**Error**: `InnoDB: Database page corruption` or similar

**Solution**:
```bash
# Stop services
task services:stop

# Remove corrupted volume (DANGEROUS - data loss)
docker volume rm dolibarr_dolibarr-db-data

# Restore from backup
task backup:list-backups
# Restore specific backup
```

#### 2. Incorrect Root Password
**Error**: `Access denied for user 'root'@'localhost'`

**Solution**:
```bash
# Check DB_ROOT_PASSWORD in .env
grep DB_ROOT_PASSWORD .env

# Reset database (DANGEROUS - data loss)
task maintenance:reset-data
task services:start
```

#### 3. Port Conflicts
**Error**: `bind: address already in use`

**Solution**:
```bash
# Change database port
DB_EXTERNAL_PORT=13306

# Or don't expose database port
# Comment out DB_EXTERNAL_PORT in .env
```

---

### Database Connection Errors

**Symptoms**:
- "Connection refused" errors
- Dolibarr shows database error pages
- Application can't connect to database

**Diagnostic Commands**:
```bash
# Test database connectivity from application
docker-compose exec dolibarr nc -zv dolibarr-db 3306

# Test from host (if port is exposed)
nc -zv localhost ${DB_EXTERNAL_PORT:-3306}

# Check database process
docker-compose exec dolibarr-db ps aux | grep mysql
```

**Solutions**:

#### 1. Database Not Ready
**Solution**:
```bash
# Wait for database health check
docker-compose logs dolibarr-db | grep "ready for connections"

# Restart application after database is ready
docker-compose restart dolibarr
```

#### 2. Network Issues
**Solution**:
```bash
# Check network connectivity
docker network ls | grep dolibarr
docker-compose exec dolibarr ping dolibarr-db

# Recreate network
task services:stop
docker-compose up -d
```

#### 3. External Database Issues
**Solution**:
```bash
# Check external database configuration
grep DB_HOST .env
grep DB_PORT .env

# Test external database connection
mysql -h ${DB_HOST} -P ${DB_PORT} -u ${DB_USER} -p${DB_PASSWORD} ${DB_NAME}
```

---

### Database Performance Issues

**Symptoms**:
- Slow queries
- High CPU/memory usage on database
- Application timeouts

**Diagnostic Commands**:
```bash
# Check database performance
docker stats dolibarr-db

# Check slow queries
docker-compose exec dolibarr-db mysql -u root -p${DB_ROOT_PASSWORD} -e "SHOW PROCESSLIST;"

# Check database size
task utilities:shell-db
> SELECT table_schema, sum((data_length+index_length)/1024/1024) AS MB FROM information_schema.TABLES GROUP BY table_schema;
```

**Solutions**:

#### 1. Optimize Database
```bash
# Run database optimization
task utilities:shell-db
> OPTIMIZE TABLE llx_actioncomm;
> OPTIMIZE TABLE llx_societe;
> ANALYZE TABLE llx_facture;
```

#### 2. Add Resource Limits
```yaml
# docker-compose.override.yml
services:
  dolibarr-db:
    deploy:
      resources:
        limits:
          memory: 2G
          cpus: '1'
```

#### 3. Database Maintenance
```bash
# Regular backups
task backup:backup

# Clean old data (be careful)
task utilities:shell-db
> DELETE FROM llx_actioncomm WHERE datep < DATE_SUB(NOW(), INTERVAL 1 YEAR);
```

---

## Application Issues

### Dolibarr Won't Load

**Symptoms**:
- Web page won't load
- HTTP 500 errors
- Blank pages

**Diagnostic Commands**:
```bash
# Check web server status
curl -I http://localhost:${DOLIBARR_PORT:-8080}

# Check application logs
task services:logs-app

# Check web server process
docker-compose exec dolibarr ps aux | grep apache
```

**Solutions**:

#### 1. Web Server Not Running
**Solution**:
```bash
# Restart application
docker-compose restart dolibarr

# Check container health
docker-compose exec dolibarr service apache2 status
```

#### 2. PHP Errors
**Error**: `Fatal error` or `Parse error` in logs

**Solution**:
```bash
# Check PHP configuration
docker-compose exec dolibarr php -v
docker-compose exec dolibarr php -m

# Check file permissions
task utilities:permissions

# Check custom modules
ls -la custom/
```

#### 3. Configuration Issues
**Solution**:
```bash
# Check Dolibarr configuration
task config:show-config

# Reset configuration
task config:configure-company
task config:enable-modules
```

---

### Login Issues

**Symptoms**:
- Can't log in with admin credentials
- "Invalid login" errors
- Locked out of admin account

**Diagnostic Commands**:
```bash
# Check admin user in database
task utilities:shell-db
> SELECT login, pass_crypted FROM llx_user WHERE admin = 1;

# Check configuration
task config:show-config
```

**Solutions**:

#### 1. Wrong Admin Credentials
**Solution**:
```bash
# Check DOLIBARR_ADMIN_PASSWORD in .env
grep DOLIBARR_ADMIN_PASSWORD .env

# Reset admin password via database
task utilities:shell-db
> UPDATE llx_user SET pass_crypted = MD5('newpassword') WHERE login = 'admin';
```

#### 2. Account Locked
**Solution**:
```bash
# Unlock admin account
task utilities:shell-db
> UPDATE llx_user SET statut = 1 WHERE login = 'admin';
```

#### 3. Database Issues
**Solution**: See [Database Issues](#database-issues) section

---

### Module Issues

**Symptoms**:
- Modules not working
- Features missing
- Module activation errors

**Diagnostic Commands**:
```bash
# List enabled modules
task config:list-modules

# Check module files
ls -la /var/www/html/htdocs/

# Check custom modules
ls -la custom/
```

**Solutions**:

#### 1. Modules Not Enabled
**Solution**:
```bash
# Enable essential modules
task config:enable-modules

# Enable API
task config:enable-api
```

#### 2. Custom Module Issues
**Solution**:
```bash
# Check custom module permissions
task utilities:permissions

# Check custom module structure
docker-compose exec dolibarr find /var/www/html/custom -type f -name "*.php"
```

#### 3. Module Configuration
**Solution**:
```bash
# Reset module configuration
task utilities:shell-db
> DELETE FROM llx_const WHERE name LIKE 'MAIN_MODULE_%';

# Re-enable modules
task config:enable-modules
```

---

## Network and Connectivity Issues

### Can't Access Web Interface

**Symptoms**:
- Browser shows "Connection refused"
- Timeout errors
- Page not found

**Diagnostic Commands**:
```bash
# Check if service is listening
netstat -tlnp | grep ${DOLIBARR_PORT:-8080}

# Test local connection
curl http://localhost:${DOLIBARR_PORT:-8080}

# Check firewall
sudo ufw status
```

**Solutions**:

#### 1. Port Not Accessible
**Solution**:
```bash
# Check Docker port mapping
docker-compose ps

# Check firewall rules
sudo ufw allow ${DOLIBARR_PORT:-8080}

# Check if binding to localhost only
# Change in docker-compose.yml: "0.0.0.0:8080:80"
```

#### 2. Wrong URL
**Solution**:
```bash
# Check correct URL
echo "Dolibarr URL: http://localhost:${DOLIBARR_PORT:-8080}"

# Update DOLIBARR_URL_ROOT if needed
DOLIBARR_URL_ROOT=http://your-domain.com:${DOLIBARR_PORT}
```

#### 3. Reverse Proxy Issues
**Solution**:
```bash
# Check reverse proxy configuration
# Nginx example:
proxy_pass http://localhost:8080;
proxy_set_header Host $host;
proxy_set_header X-Real-IP $remote_addr;
```

---

### API Connection Issues

**Symptoms**:
- API calls fail
- "API not enabled" errors
- Authentication failures

**Diagnostic Commands**:
```bash
# Check API module
task config:list-modules | grep API

# Test API endpoint
curl http://localhost:${DOLIBARR_PORT:-8080}/api/index.php/explorer

# Check API configuration
task utilities:shell-db
> SELECT name, value FROM llx_const WHERE name LIKE '%API%';
```

**Solutions**:

#### 1. API Not Enabled
**Solution**:
```bash
# Enable API module
task config:enable-api

# Verify API is enabled
curl http://localhost:${DOLIBARR_PORT:-8080}/api/index.php/explorer
```

#### 2. API Key Issues
**Solution**:
```bash
# Generate API key via web interface:
# Users & Groups > Users > Edit User > API Keys

# Or via database (not recommended):
task utilities:shell-db
> INSERT INTO llx_user_api_keys (fk_user, api_key, datec) VALUES (1, 'your-api-key', NOW());
```

---

## Performance Issues

### Slow Performance

**Symptoms**:
- Pages load slowly
- Database queries timeout
- High resource usage

**Diagnostic Commands**:
```bash
# Check resource usage
docker stats

# Check system resources
top
htop
free -h
df -h
```

**Solutions**:

#### 1. Resource Limits
**Solution**:
```bash
# Add resource limits
# docker-compose.override.yml
services:
  dolibarr:
    deploy:
      resources:
        limits:
          memory: 1G
          cpus: '1'
```

#### 2. Database Optimization
**Solution**: See [Database Performance Issues](#database-performance-issues) section

#### 3. PHP Configuration
**Solution**:
```yaml
# docker-compose.override.yml
services:
  dolibarr:
    environment:
      - PHP_MEMORY_LIMIT=512M
      - PHP_MAX_EXECUTION_TIME=300
```

---

### Memory Issues

**Symptoms**:
- "Out of memory" errors
- Container killed (OOMKilled)
- System becomes unresponsive

**Diagnostic Commands**:
```bash
# Check memory usage
free -h
docker stats --no-stream

# Check container memory limits
docker inspect dolibarr-app | grep -i memory
```

**Solutions**:

#### 1. Increase Memory Limits
**Solution**:
```yaml
# docker-compose.override.yml
services:
  dolibarr:
    deploy:
      resources:
        limits:
          memory: 2G
        reservations:
          memory: 512M
```

#### 2. Optimize PHP Memory
**Solution**:
```yaml
services:
  dolibarr:
    environment:
      - PHP_MEMORY_LIMIT=1024M
```

---

## Configuration Issues

### Environment Variable Issues

**Symptoms**:
- Configuration not taking effect
- Default values being used
- Service configuration errors

**Diagnostic Commands**:
```bash
# Check environment variables
docker-compose exec dolibarr env | grep DOLI

# Check .env file
cat .env | grep -v PASSWORD

# Validate configuration
docker-compose config
```

**Solutions**:

#### 1. Missing .env File
**Solution**:
```bash
# Copy example file
cp .env.example .env

# Edit with your values
nano .env
```

#### 2. Invalid Variable Format
**Solution**:
```bash
# Check for spaces around = sign (invalid)
DB_PASSWORD = mypassword  # Wrong

# Correct format
DB_PASSWORD=mypassword    # Correct

# Check for special characters
DB_PASSWORD="pass with spaces"  # Use quotes if needed
```

#### 3. Profile-Specific Variables
**Solution**:
```bash
# Check which profile you're using
docker-compose --profile internal-db config

# Ensure variables match profile
# Internal DB: need DB_ROOT_PASSWORD
# External DB: need DB_HOST
```

---

### Docker Compose Issues

**Symptoms**:
- `docker-compose` command not found
- Version compatibility errors
- YAML syntax errors

**Diagnostic Commands**:
```bash
# Check Docker Compose version
docker-compose version

# Validate YAML syntax
docker-compose config

# Check file permissions
ls -la docker-compose.yml
```

**Solutions**:

#### 1. Docker Compose Not Installed
**Solution**:
```bash
# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Or use Docker Compose V2
docker compose version
```

#### 2. YAML Syntax Errors
**Solution**:
```bash
# Validate YAML
docker-compose config

# Check indentation (use spaces, not tabs)
# Check for trailing spaces
```

---

## File and Permission Issues

### Permission Denied Errors

**Symptoms**:
- "Permission denied" errors
- Cannot write files
- Upload failures

**Diagnostic Commands**:
```bash
# Check file permissions
docker-compose exec dolibarr ls -la /var/www/html
docker-compose exec dolibarr ls -la /var/www/documents

# Check process user
docker-compose exec dolibarr whoami
docker-compose exec dolibarr id
```

**Solutions**:

#### 1. Fix Application Permissions
**Solution**:
```bash
# Fix permissions using task
task utilities:permissions

# Or manually
docker-compose exec dolibarr chown -R www-data:www-data /var/www/html
docker-compose exec dolibarr chown -R www-data:www-data /var/www/documents
```

#### 2. Host Directory Permissions
**Solution**:
```bash
# Fix host directory permissions
sudo chown -R $(id -u):$(id -g) custom/
sudo chown -R $(id -u):$(id -g) logs/

# Or set proper permissions
chmod -R 755 custom/
chmod -R 755 logs/
```

---

### File Upload Issues

**Symptoms**:
- Files won't upload
- Upload size limits exceeded
- Temporary directory errors

**Diagnostic Commands**:
```bash
# Check PHP upload settings
docker-compose exec dolibarr php -i | grep upload

# Check disk space
df -h
docker system df -v
```

**Solutions**:

#### 1. PHP Upload Limits
**Solution**:
```yaml
# docker-compose.override.yml
services:
  dolibarr:
    environment:
      - PHP_UPLOAD_MAX_FILESIZE=100M
      - PHP_POST_MAX_SIZE=100M
      - PHP_MAX_FILE_UPLOADS=20
```

#### 2. Disk Space Issues
**Solution**:
```bash
# Check available space
df -h

# Clean up Docker resources
task maintenance:cleanup
docker system prune -a
```

---

## Backup and Recovery Issues

### Backup Failures

**Symptoms**:
- Backup command fails
- Empty backup files
- Permission errors during backup

**Diagnostic Commands**:
```bash
# Check backup directory
ls -la backups/

# Check backup process
task backup:backup

# Check disk space
df -h
```

**Solutions**:

#### 1. Permission Issues
**Solution**:
```bash
# Fix backup directory permissions
chmod -R 755 backups/

# Check if backup directory exists
mkdir -p backups/
```

#### 2. Database Backup Issues
**Solution**:
```bash
# Test database connectivity
task utilities:shell-db

# Check database size
task utilities:shell-db
> SELECT SUM(data_length + index_length) / 1024 / 1024 AS 'DB Size in MB' FROM information_schema.tables WHERE table_schema = 'dolibarr';
```

---

### Recovery Issues

**Symptoms**:
- Cannot restore from backup
- Restore process hangs
- Data corruption after restore

**Solutions**:

#### 1. Verify Backup Integrity
**Solution**:
```bash
# Check backup file
file backups/*/database_*.sql.gz
gunzip -t backups/*/database_*.sql.gz

# Check backup content
gunzip -c backups/*/database_*.sql.gz | head -20
```

#### 2. Complete Recovery Process
**Solution**:
```bash
# Stop services
task services:stop

# Reset data (CAREFUL!)
task maintenance:reset-data

# Start fresh
task services:start

# Restore from backup
# (Implement restore task if needed)
```

---

## Development and Custom Module Issues

### Custom Module Problems

**Symptoms**:
- Custom modules not loading
- Module activation errors
- PHP errors in custom code

**Diagnostic Commands**:
```bash
# Check custom directory structure
ls -la custom/
find custom/ -name "*.php" | head -10

# Check PHP syntax
docker-compose exec dolibarr php -l /var/www/html/custom/mymodule/mymodule.php
```

**Solutions**:

#### 1. Module Structure Issues
**Solution**:
```bash
# Verify correct module structure
custom/mymodule/
├── core/
├── admin/
├── class/
├── mymodule.php
└── README.md

# Check file permissions
task utilities:permissions
```

#### 2. PHP Syntax Errors
**Solution**:
```bash
# Check all PHP files
find custom/ -name "*.php" -exec docker-compose exec -T dolibarr php -l {} \;

# Fix syntax errors in custom code
```

---

### Development Environment Issues

**Symptoms**:
- phpMyAdmin not accessible
- Development tools not working
- Debug mode not enabled

**Solutions**:

#### 1. phpMyAdmin Issues
**Solution**:
```bash
# Ensure tools profile is active
task services:start-with-tools

# Check phpMyAdmin URL
echo "phpMyAdmin: http://localhost:${PHPMYADMIN_PORT:-8081}"

# Check phpMyAdmin logs
docker-compose logs phpmyadmin
```

#### 2. Debug Mode
**Solution**:
```bash
# Enable debug mode
task utilities:shell-app
# Edit configuration to enable debug
```

---

## Error Message Reference

### Common Error Messages and Solutions

#### Database Errors

**Error**: `Connection refused`
**Cause**: Database not running or network issues
**Solution**: 
```bash
task services:start
docker-compose logs dolibarr-db
```

**Error**: `Access denied for user`
**Cause**: Wrong database credentials
**Solution**: Check `DB_PASSWORD` and `DB_ROOT_PASSWORD` in `.env`

**Error**: `Table 'dolibarr.llx_const' doesn't exist`
**Cause**: Database not initialized
**Solution**: 
```bash
task maintenance:reset-data
task services:start
task config:setup-dev-environment
```

#### Application Errors

**Error**: `Fatal error: Maximum execution time exceeded`
**Cause**: PHP timeout
**Solution**: Increase `PHP_MAX_EXECUTION_TIME`

**Error**: `Call to undefined function`
**Cause**: Missing PHP extension
**Solution**: Check container image or custom Dockerfile

#### Docker Errors

**Error**: `port is already allocated`
**Cause**: Port conflict
**Solution**: Change port in `.env` file

**Error**: `no such file or directory`
**Cause**: Missing file or incorrect path
**Solution**: Check file paths and permissions

---

## Log Analysis

### Log Locations and Commands

#### Application Logs
```bash
# Real-time application logs
task services:logs-app

# Search for specific errors
task services:logs-app | grep ERROR

# Check log files on host
ls -la logs/
tail -f logs/dolibarr.log
```

#### Database Logs
```bash
# Database logs
task services:logs-db

# Query logs (if enabled)
docker-compose exec dolibarr-db tail -f /var/lib/mysql/general.log
```

#### System Logs
```bash
# Docker daemon logs
sudo journalctl -u docker.service

# Container logs
docker logs dolibarr-app
docker logs dolibarr-db
```

### Log Analysis Techniques

#### Finding Errors
```bash
# Search for error patterns
grep -i "error\|exception\|fatal\|warning" logs/*

# Check for specific time period
grep "2024-01-15" logs/dolibarr.log | grep ERROR
```

#### Performance Analysis
```bash
# Find slow queries
grep "slow query" logs/*

# Check memory usage patterns
grep "memory" logs/* | head -20
```

---

## Getting Additional Help

### Diagnostic Information Collection

When reporting issues, collect this diagnostic information:

```bash
# System information
uname -a
docker version
docker-compose version

# Service status
task services:status
task utilities:health

# Configuration (without passwords)
cat .env | grep -v PASSWORD
docker-compose config

# Recent logs
task services:logs | tail -100

# Resource usage
docker stats --no-stream
free -h
df -h
```

### Support Resources

1. **Dolibarr Documentation**: [Official Dolibarr Wiki](https://wiki.dolibarr.org)
2. **Docker Documentation**: [Docker Compose Guide](https://docs.docker.com/compose/)
3. **Community Forums**: [Dolibarr Forum](https://www.dolibarr.org/forum)
4. **GitHub Issues**: Project repository issues section

### Before Reporting Issues

1. ✅ Check this troubleshooting guide
2. ✅ Search existing issues in the repository
3. ✅ Collect diagnostic information
4. ✅ Try basic troubleshooting steps
5. ✅ Document steps to reproduce the issue

Remember to never include passwords or sensitive information when reporting issues!
