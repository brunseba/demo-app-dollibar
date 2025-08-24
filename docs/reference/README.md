# Reference Documentation

This directory contains comprehensive reference materials for the Dolibarr Docker setup. These documents serve as detailed technical references for all components and configurations.

## 📚 Reference Documents

### [Quick Reference Cheat Sheet](cheat-sheet.md) ⚡
One-page reference with essential commands, configurations, and troubleshooting.

- **Quick Start**: Setup commands for development and production
- **Essential Commands**: Most-used Task commands organized by category
- **Configuration Examples**: Development and production `.env` templates
- **Troubleshooting**: Quick diagnostic commands for common issues
- **Security Checklists**: Development and production security requirements
- **Emergency Commands**: System recovery and cleanup procedures

### [Taskfile Commands Reference](taskfile-commands.md)
Complete reference of all Task commands with descriptions, parameters, and usage examples.

- **Service Management**: Start, stop, status commands
- **Configuration**: Module enablement, company setup
- **Backup & Maintenance**: Data backup and system maintenance
- **Utilities**: Shell access, permissions, health checks
- **Common Workflows**: Step-by-step procedures

### [Environment Variables Reference](environment-variables.md)
Comprehensive guide to all environment variables used in the Docker setup.

- **Database Configuration**: Connection settings and credentials
- **Application Settings**: Dolibarr-specific configurations
- **Network & Ports**: Port mappings and network settings
- **Security Variables**: Authentication and security settings
- **Examples by Use Case**: Development, production, cloud deployments

### [Docker Services Reference](docker-services.md)
Technical documentation of all Docker services, containers, and infrastructure.

- **Service Specifications**: Detailed service configurations
- **Volume Management**: Storage and data persistence
- **Network Architecture**: Inter-service communication
- **Health Checks**: Service monitoring and dependencies
- **Scaling & Performance**: Resource management and optimization

### [Troubleshooting Reference](troubleshooting.md)
Comprehensive troubleshooting guide for common issues and their solutions.

- **Quick Diagnostics**: Immediate health check commands
- **Service Issues**: Container and startup problems
- **Database Problems**: Connection and performance issues
- **Application Errors**: Dolibarr-specific problems
- **Network & Connectivity**: Access and API issues
- **Error Message Reference**: Common errors and solutions

### [API Reference](api-reference.md)
Complete reference for the Dolibarr REST API with examples in multiple languages.

- **Authentication**: API key generation and security
- **Core Endpoints**: Users, companies, products, invoices
- **Request/Response Formats**: JSON structures and patterns
- **Error Handling**: HTTP status codes and error responses
- **Code Examples**: JavaScript, Python, PHP, Bash implementations

### [Configuration Reference](configuration-reference.md)
Detailed reference for all configuration files and their structure.

- **Docker Compose**: Service definitions and overrides
- **Environment Files**: Variable organization and examples
- **Taskfile Structure**: Task organization and patterns
- **Database Configuration**: MariaDB settings and initialization
- **Custom Modules**: Module structure and development
- **Production Settings**: Security and performance configurations

### [URI Reference](uri.md)
Comprehensive list of all tools, technologies, and resources used in this repository.

- **Core Technologies**: Dolibarr, Docker, MariaDB, Task Runner
- **Development Tools**: phpMyAdmin, programming languages, frameworks
- **Third-party Services**: Cloud platforms, monitoring tools
- **License Information**: Open source and commercial license details
- **Support Resources**: Communities, documentation, security tools

## 🎯 Quick Reference Guide

### Essential Commands
```bash
# System health and status
task utilities:health
task services:status

# Service management
task services:start-with-tools    # Development
task services:start               # Production
task services:stop

# Configuration
task config:setup-dev-environment
task config:show-config

# Backup and maintenance
task backup:backup
task maintenance:update
```

### Key Files
```
.env                    # Environment configuration
docker-compose.yml      # Service definitions
Taskfile.yml           # Task automation
custom/                # Custom modules
logs/                  # Application logs
backups/               # Data backups
```

### Important URLs
```
Dolibarr:      http://localhost:8080
phpMyAdmin:    http://localhost:8081
API Explorer:  http://localhost:8080/api/index.php/explorer
```

## 🔍 How to Use This Reference

### For Developers
1. Start with [Taskfile Commands Reference](taskfile-commands.md) for daily workflows
2. Use [Environment Variables Reference](environment-variables.md) for configuration
3. Consult [API Reference](api-reference.md) for integration work
4. Refer to [Troubleshooting Reference](troubleshooting.md) when issues arise

### For System Administrators
1. Begin with [Docker Services Reference](docker-services.md) for infrastructure understanding
2. Review [Configuration Reference](configuration-reference.md) for deployment setup
3. Use [Troubleshooting Reference](troubleshooting.md) for operational issues
4. Follow [Environment Variables Reference](environment-variables.md) for production configs

### For DevOps Engineers
1. Study [Configuration Reference](configuration-reference.md) for CI/CD pipelines
2. Use [Docker Services Reference](docker-services.md) for orchestration
3. Implement monitoring based on [Troubleshooting Reference](troubleshooting.md)
4. Automate tasks using [Taskfile Commands Reference](taskfile-commands.md)

## 📖 Document Conventions

### Symbols and Indicators
- ✅ **Required** - Must be configured or installed
- ⚠️ **Important** - Critical information to note
- ❌ **Optional** - Can be skipped or customized
- 🟢 **Low Complexity** - Suitable for beginners
- 🟡 **Medium Complexity** - Requires some experience
- 🔴 **High Complexity** - Advanced configuration

### Code Block Formats
- `bash` - Shell commands and scripts
- `yaml` - Docker Compose and configuration files
- `env` - Environment variable files
- `json` - API requests and responses
- `php` - Dolibarr custom code
- `sql` - Database queries and schemas

### Command Examples
All command examples use the Task runner format:
```bash
task namespace:command-name
```

Direct Docker Compose commands are provided as alternatives:
```bash
docker-compose --profile internal-db up -d
```

## 🤝 Contributing to Reference Documentation

### Guidelines for Updates
1. **Accuracy**: Ensure all commands and configurations are tested
2. **Completeness**: Include all necessary parameters and options
3. **Examples**: Provide practical, working examples
4. **Cross-references**: Link to related sections and documents
5. **Version Compatibility**: Note version-specific features or changes

### Documentation Standards
- Use clear, descriptive headings
- Include table of contents for long documents
- Provide both simple and complex examples
- Explain the "why" not just the "how"
- Keep examples current with the latest versions

### Testing Documentation
Before submitting updates:
1. Test all command examples in a clean environment
2. Verify all configuration examples work as described
3. Check that all links and cross-references are valid
4. Ensure code examples follow project conventions

## 📞 Support and Further Reading

### Getting Help
1. **Check Troubleshooting**: Start with [Troubleshooting Reference](troubleshooting.md)
2. **Search Documentation**: Use Ctrl+F to find specific topics
3. **Review Examples**: Look at complete examples in each reference
4. **Validate Configuration**: Use diagnostic commands to verify setup

### External Resources
- [Dolibarr Official Documentation](https://wiki.dolibarr.org/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Task Runner Documentation](https://taskfile.dev/)
- [MariaDB Documentation](https://mariadb.org/documentation/)

### Project Resources
- **Main Documentation**: `../README.md`
- **Deployment Scenarios**: `../deployment-scenarios.md`
- **Quick Start Guide**: Project root README
- **Issue Tracking**: Project repository issues

---

*This reference documentation is maintained alongside the Dolibarr Docker project. For the latest updates and additional resources, please refer to the project repository.*
