# This grants the listed permissions
# To the table `my_table` (we can use the wildcard `*` to grant access to ALL the tables)
# in the database `my_database`
# To the user `user`
# The user access MUST BE from the location `from_location`.
# This can be:
#   - 'ip.address' the IP address that is connecting FROM.
#   - '%' for Anywhere or 
#   - 'localhost' if the Db is on the Same server <--- This is VERY unlikely.

# Maximum permissions:
GRANT 
    ALTER,
    ALTER ROUTINE,
    CREATE,
    CREATE ROUTINE,
    CREATE TEMPORARY TABLES,
    CREATE VIEW,
    DELETE, 
    DROP,
    EVENT,
    EXECUTE,
    GRANT,
    INDEX, 
    INSERT,
    LOCK TABLES,
    REFERENCES,
    SELECT,
    SHOW VIEW,
    TRIGGER,
    UDATE    
ON `my_database`.`my_database`
TO 'user'@'from_location';

# Reset the privileges so that the changes are considered.
FLUSH PRIVILEGES;

# Grant READ ONLY
GRANT 
    SELECT,
    SHOW VIEW
ON `my_database`.`my_database`
TO 'user'@'from_location';

# Reset the privileges so that the changes are considered.
FLUSH PRIVILEGES;