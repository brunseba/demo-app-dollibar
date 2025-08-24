# Database Initialization Scripts

This directory is mounted to `/docker-entrypoint-initdb.d` in the MariaDB container.

Place SQL scripts here that you want to run during database initialization. Files will be executed in alphabetical order.

Example files:
- `01-create-additional-databases.sql` - Create additional databases if needed
- `02-custom-tables.sql` - Create custom tables
- `03-initial-data.sql` - Insert initial data

**Note:** These scripts only run when the database is first created. If you need to run scripts on an existing database, you'll need to do so manually.

**Security:** Be careful not to include sensitive data in these scripts if you plan to commit them to version control.
