# Dolibarr Database Analysis

Welcome to the comprehensive database analysis documentation for the Dolibarr ERP/CRM system.

## Overview

This documentation provides a detailed analysis of the Dolibarr database structure, including:

- **Entity-Relationship Diagrams** using Mermaid syntax
- **Comprehensive data model documentation**
- **Business flow diagrams** showing key processes
- **Entity descriptions** with field explanations
- **Relationship mappings** between business objects

## What is Dolibarr?

**Dolibarr** is a modern, open-source ERP (Enterprise Resource Planning) and CRM (Customer Relationship Management) software designed for small and medium-sized businesses, foundations, and freelancers.

### Key Features:
- 👥 **Customer/Supplier Management**: Complete contact and relationship management
- 💰 **Financial Management**: Invoicing, payments, accounting, and reporting
- 📦 **Inventory & Stock**: Product catalog, stock management, and warehouse operations
- 🛒 **Sales & Purchasing**: Quotes, orders, deliveries, and supplier management
- 👨‍💼 **HR & Payroll**: Employee management, leave tracking, and expense reports
- 📊 **Reporting & Analytics**: Built-in reports and business intelligence
- 🔧 **Modular Design**: Enable only the modules you need
- 🌍 **Multi-language**: Available in 50+ languages
- 📱 **Responsive**: Web-based interface that works on all devices

## Database Architecture Highlights

The Dolibarr database follows a well-structured design with several key characteristics:

### 🏗️ **Modular Architecture**
- Clean separation of concerns between business domains
- Tables can be enabled/disabled based on active modules
- Extensible design supporting custom modules

### 🌐 **Multi-Entity Support**  
- Most entities include an `entity` field for multi-company setups
- Enables SaaS-style deployment with data isolation
- Users can be restricted to specific entities

### 🔧 **Extensibility Features**
- **Extra Fields**: Most entities have corresponding `*_extrafields` tables
- **Categories**: Flexible categorization system supporting hierarchical structures
- **Multi-currency**: Native multi-currency handling with exchange rate tracking

### 📊 **Comprehensive Business Flow**
The database supports the complete business cycle:
```
Prospect → Contact → Proposal → Order → Delivery → Invoice → Payment
```

## Currently Enabled Modules

This Dolibarr instance has the following core modules **currently enabled**:

- ✅ **ADHERENT** - Member Management (subscriptions, membership types)
- ✅ **FOURNISSEUR** - Supplier Management (supplier orders, invoices)
- ✅ **SOCIETE** - Third Party Management (companies, customers, suppliers)
- ✅ **USER** - User Management (accounts, permissions, groups)

*See [Modules Status](modules-status.md) for a complete list of available modules and activation instructions.*

## Database Statistics

Based on the analysis of the running Dolibarr instance:

- **Total Tables**: 389 tables
- **✅ Enabled Modules**: 4 core modules  
- **📦 Available Modules**: 35+ module categories
- **Core Business Entities**: 15+ main entities
- **Configuration Tables**: 50+ configuration/reference tables
- **Supporting Tables**: 280+ supporting and junction tables
- **Multi-language Support**: Built-in internationalization tables

## Getting Started

1. 📖 **[Database Model](database-model.md)** - Comprehensive analysis with ERD diagrams
2. 🔧 **[Modules Status](modules-status.md)** - Current module enablement and available features
3. 🔍 **Entity Relationships** - Detailed mapping of business object relationships
4. 🏭 **Business Processes** - Flow diagrams showing key business operations
5. ⚙️ **Configuration** - Reference data and system configuration tables

## Document Structure

This documentation is organized into the following sections:

### 📊 **Visual Diagrams**
- **Main ERD**: Complete entity-relationship diagram with all core entities
- **Business Flow**: Simplified process flow showing document lifecycle
- **Modular Views**: Focused diagrams for specific business areas

### 📋 **Detailed Documentation**
- **Entity Descriptions**: Purpose, key fields, and relationships for each entity
- **Business Rules**: Key constraints and business logic explanations  
- **Configuration Guide**: Reference tables and system settings
- **Extensibility**: Custom fields, categories, and multi-currency features

## Technical Notes

- **Database Engine**: MariaDB 10.11 (MySQL compatible)
- **Character Set**: UTF8MB4 with Unicode collation
- **Naming Convention**: Tables prefixed with `llx_`
- **Foreign Keys**: Consistent `fk_` prefix for foreign key fields
- **Timestamps**: Automatic creation and modification tracking

## Links and Resources

- **Official Website**: [https://www.dolibarr.org](https://www.dolibarr.org)
- **Documentation**: [https://www.dolibarr.org/documentation](https://www.dolibarr.org/documentation)
- **Docker Hub**: [https://hub.docker.com/r/dolibarr/dolibarr](https://hub.docker.com/r/dolibarr/dolibarr)
- **Community Forums**: [https://www.dolibarr.org/forum](https://www.dolibarr.org/forum)

---

*This documentation was generated through automated analysis of a live Dolibarr database instance and provides accurate, up-to-date information about the database structure and relationships.*
