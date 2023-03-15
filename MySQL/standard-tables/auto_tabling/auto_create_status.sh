#!/bin/bash

# read config file
# read from template file
# generate script
#


source $1


# add all core data
while IFS='=' read -r k v1 v2 v3 v4
do

    if [[ "$k" == "core_data" ]];
    then
        echo "---core data--- $v2"

    elif [[ "$k" == "foreign_key_data" ]];
    then
        echo "---foreign key data--- $v2 -----> $v3.$v4"
    fi

done <$1


# start new output
# WARNING: must have 2 spaces before EOM!!!!!
cat > ./output/statuses_${xxx}.sql <<-EOM
# Replace
#   - \`statuses_xxx\` with the name of your status table the name should start with \`statuses_\` (ex: \`statuses_merchant\`)
#   - \`yyy\` with name you have chosen for the designation field of your status table (ex: \`merchant_status\`).

# What this script will do:
#
# - Create a table \`statuses_${xxx}\` to list the possible statutes for a record.
# - Grant access to the table \`statuses_${xxx}\` to the following users:
#   - 'view.lists'@'%': Read only
#   - 'view.data'@'%': Read only
# - Create a trigger \`uuid_statuses_${xxx}\` to automatically generate the UUID for a new record.
# - Create a table \`logs_statuses_${xxx}\` to log all the changes in the table.
# - Grant access to the table \`logs_statuses_${xxx}\` to the following users:
#   - 'view.lists'@'%': Read only
#   - 'view.data'@'%': Read only
# - Create a trigger \`logs_statuses_${xxx}_insert\` to automatically log INSERT operations on the table \`statuses_${xxx}\`.
# - Create a trigger \`logs_statuses_${xxx}_update\` to automatically log UPDATE operations on the table \`statuses_${xxx}\`.
# - Create a trigger \`logs_statuses_${xxx}_delete\` to automatically log DELETE operations on the table \`statuses_${xxx}\`.
# - Create a view \`view_statuses_${xxx}_all\` to list ALL the statuses.
# - Grant access to the view \`view_statuses_${xxx}_all\` to the following users:
#   - 'view.lists'@'%': Read only
#   - 'view.data'@'%': Read only
# - Create a view \`view_statuses_${xxx}_not_obsolete\` to list the statuses that are NOT obsolete.
# - Grant access to the view \`view_statuses_${xxx}_not_obsolete\` to the following users:
#   - 'view.lists'@'%': Read only
#   - 'view.data'@'%': Read only
# - Create a view \`view_statuses_${xxx}_active\` to list the statuses that are Active.
# - Grant access to the view \`view_statuses_${xxx}_active\` to the following users:
#   - 'view.lists'@'%': Read only
#   - 'view.data'@'%': Read only
# - Create a view \`view_statuses_${xxx}_inactive\` to list the statuses that are Inctive.
# - Grant access to the view \`view_statuses_${xxx}_inactive\` to the following users:
#   - 'view.lists'@'%': Read only
#   - 'view.data'@'%': Read only
# - Insert some sample data in the table \`statuses_${xxx}\`.
#
# Constaints:
# - The status name must be unique.
# - The Interface to create the record MUST exist in the table \`db_interfaces\`
# - The Interface to update the record MUST exist in the table \`db_interfaces\`
#
# Automations and Triggers:
# - The UUID for a new record is automatically generated.
# - Logs of each changes in this table are recorded in the table \`logs_statuses_${xxx}\`
#
# Sample data are inserted in the table:
# - Record that must exist in the table \`db_interfaces\`
#   - field \`interface\`, value 'sql_seed_script'.
#


# Create the table \`statuses_${xxx}\`
CREATE TABLE \`statuses_${xxx}\` (
  \`uuid\` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The globally unique UUID for this record',
  \`idemp_key\` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'Idempotency key. This is to make sure that a record is not created twice when an API call is made',
  \`created_interface\` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the interface sytem that was used to CREATE the record?',
  \`created_by_id\` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the user who created the record?',
  \`created_by_ref_table\` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the name of the table where we store user information?',
  \`created_by_username_field\` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the name of the field that stores the username associated to the userid?',
  \`updated_interface\` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the interface sytem that was used to UPDATE the record?',
  \`updated_by_id\` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the user who updated the record?',
  \`updated_by_ref_table\` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the name of the table where we store user information?',
  \`updated_by_username_field\` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the name of the field that stores the username associated to the userid?',
  \`is_obsolete\` tinyint(1) DEFAULT '0' COMMENT 'is this obsolete?',
  \`order\` int(10) NOT NULL DEFAULT '0' COMMENT 'Order in the list',
  \`is_active\` tinyint(1) DEFAULT '0' COMMENT 'This status is considered as ACTIVE',
  \`${yyy}\` varchar(255) COLLATE utf8mb4_unicode_520_ci  NOT NULL COMMENT 'Status',
  \`${yyy}_description\` text COLLATE utf8mb4_unicode_520_ci COMMENT 'Description/help text',
  PRIMARY KEY (\`uuid\`),
  UNIQUE KEY \`unique_${yyy}_status\` (\`${yyy}\`) COMMENT 'The status must be unique',
  KEY \`status_${yyy}_idemp_key\` (\`idemp_key\`),
  KEY \`status_${yyy}_created_interface\` (\`created_interface\`),
  KEY \`status_${yyy}_updated_interface\` (\`updated_interface\`),
  CONSTRAINT \`status_${yyy}_created_interface\` FOREIGN KEY (\`created_interface\`) REFERENCES \`db_interfaces\` (\`interface\`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT \`status_${yyy}_updated_interface\` FOREIGN KEY (\`updated_interface\`) REFERENCES \`db_interfaces\` (\`interface\`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC
;

# - Grant access to the table \`statuses_${xxx}\` to the following users:
#   - 'view.statuses'@'%': Read only
GRANT
    SELECT,
    SHOW VIEW
ON \`statuses_${xxx}\`
TO 'view.statuses'@'%';

# - Grant access to the table \`statuses_${xxx}\` to the following users:
#   - 'view.data'@'%': Read only
GRANT
    SELECT,
    SHOW VIEW
ON \`statuses_${xxx}\`
TO 'view.data'@'%';

# Make sure that a UUID is generated each time a new record is created in the table \`statuses_${xxx}\`.
CREATE TRIGGER \`uuid_statuses_${xxx}\`
  BEFORE INSERT ON \`statuses_${xxx}\`
  FOR EACH ROW
  SET new.uuid = uuid()
;

# Create the table \`logs_statuses_${xxx}\` to store the changes in the data
CREATE TABLE \`logs_statuses_${xxx}\` (
  \`action\` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The action that was performed on the table',
  \`action_datetime\` TIMESTAMP NULL DEFAULT NULL COMMENT 'Timestamp - when was the operation done',
  \`uuid\` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The globally unique UUID for this record',
  \`idemp_key\` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'Idempotency key. This is to make sure that a record is not created twice when an API call is made',
  \`created_interface\` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the interface sytem that was used to CREATE the record?',
  \`created_by_id\` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the user who created the record?',
  \`created_by_ref_table\` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the name of the table where we store user information?',
  \`created_by_username_field\` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the name of the field that stores the username associated to the userid?',
  \`updated_interface\` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the interface sytem that was used to UPDATE the record?',
  \`updated_by_id\` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the user who updated the record?',
  \`updated_by_ref_table\` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the name of the table where we store user information?',
  \`updated_by_username_field\` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the name of the field that stores the username associated to the userid?',
  \`is_obsolete\` tinyint(1) DEFAULT '0' COMMENT 'is this obsolete?',
  \`order\` int(10) NOT NULL DEFAULT '0' COMMENT 'Order in the list',
  \`is_active\` tinyint(1) DEFAULT '0' COMMENT 'This status is considered as ACTIVE',
  \`${yyy}\` varchar(255) COLLATE utf8mb4_unicode_520_ci  NOT NULL COMMENT 'Status',
  \`${yyy}_description\` text COLLATE utf8mb4_unicode_520_ci COMMENT 'Description/help text',
  KEY \`statuses_${xxx}_uuid\` (\`uuid\`) COMMENT 'Index the UUID for improved performances'
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC
;

# - Grant access to the table \`logs_statuses_${xxx}\` to the following users:
#   - 'view.statuses'@'%': Read only
GRANT
    SELECT,
    SHOW VIEW
ON \`logs_statuses_${xxx}\`
TO 'view.statuses'@'%';

# - Grant access to the table \`logs_statuses_${xxx}\` to the following users:
#   - 'view.data'@'%': Read only
GRANT
    SELECT,
    SHOW VIEW
ON \`logs_statuses_${xxx}\`
TO 'view.data'@'%';

# After a successful INSERT in the table \`statuses_${xxx}\`
# Record all the data Inserted in the table \`statuses_${xxx}\`
# The information will be stored in the table \`logs_statuses_${xxx}\`

DELIMITER \$\$

CREATE TRIGGER \`logs_statuses_${xxx}_insert\` AFTER INSERT ON \`statuses_${xxx}\`
FOR EACH ROW
BEGIN
  INSERT INTO \`logs_statuses_${xxx}\` (
    \`action\`,
    \`action_datetime\`,
    \`uuid\`,
    \`idemp_key\`,
    \`created_interface\`,
    \`created_by_id\`,
    \`created_by_ref_table\`,
    \`created_by_username_field\`,
    \`updated_interface\`,
    \`updated_by_id\`,
    \`updated_by_ref_table\`,
    \`updated_by_username_field\`,
    \`is_obsolete\`,
    \`order\`,
    \`is_active\`,
    \`${yyy}\`,
    \`${yyy}_description\`
    )
  VALUES
    ('INSERT',
      NOW(),
      NEW.\`uuid\`,
      NEW.\`idemp_key\`,
      NEW.\`created_interface\`,
      NEW.\`created_by_id\`,
      NEW.\`created_by_ref_table\`,
      NEW.\`created_by_username_field\`,
      NEW.\`updated_interface\`,
      NEW.\`updated_by_id\`,
      NEW.\`updated_by_ref_table\`,
      NEW.\`updated_by_username_field\`,
      NEW.\`is_obsolete\`,
      NEW.\`order\`,
      NEW.\`is_active\`,
      NEW.\`${yyy}\`,
      NEW.\`${yyy}_description\`
    )
  ;
END
\$\$

DELIMITER ;

# After a successful UPDATE in the table \`statuses_${xxx}\`
# Record all the values for the old record
# Record all the values for the new record
# data Inserted in the table \`statuses_${xxx}\`
# The information will be stored in the table \`logs_statuses_${xxx}\`

DELIMITER \$\$

CREATE TRIGGER \`logs_statuses_${xxx}_update\` AFTER UPDATE ON \`statuses_${xxx}\`
FOR EACH ROW
BEGIN
  INSERT INTO \`logs_statuses_${xxx}\` (
    \`action\`,
    \`action_datetime\`,
    \`uuid\`,
    \`idemp_key\`,
    \`created_interface\`,
    \`created_by_id\`,
    \`created_by_ref_table\`,
    \`created_by_username_field\`,
    \`updated_interface\`,
    \`updated_by_id\`,
    \`updated_by_ref_table\`,
    \`updated_by_username_field\`,
    \`is_obsolete\`,
    \`order\`,
    \`is_active\`,
    \`${yyy}\`,
    \`${yyy}_description\`
    )
    VALUES
      ('UPDATE-OLD_VALUES',
        NOW(),
        OLD.\`uuid\`,
        OLD.\`idemp_key\`,
        OLD.\`created_interface\`,
        OLD.\`created_by_id\`,
        OLD.\`created_by_ref_table\`,
        OLD.\`created_by_username_field\`,
        OLD.\`updated_interface\`,
        OLD.\`updated_by_id\`,
        OLD.\`updated_by_ref_table\`,
        OLD.\`updated_by_username_field\`,
        OLD.\`is_obsolete\`,
        OLD.\`order\`,
        OLD.\`is_active\`,
        OLD.\`${yyy}\`,
        OLD.\`${yyy}_description\`
      ),
      ('UPDATE-NEW_VALUES',
        NOW(),
        NEW.\`uuid\`,
        NEW.\`idemp_key\`,
        NEW.\`created_interface\`,
        NEW.\`created_by_id\`,
        NEW.\`created_by_ref_table\`,
        NEW.\`created_by_username_field\`,
        NEW.\`updated_interface\`,
        NEW.\`updated_by_id\`,
        NEW.\`updated_by_ref_table\`,
        NEW.\`updated_by_username_field\`,
        NEW.\`is_obsolete\`,
        NEW.\`order\`,
        NEW.\`is_active\`,
        NEW.\`${yyy}\`,
        NEW.\`${yyy}_description\`
      )
  ;
END
\$\$

DELIMITER ;

# After a successful DELETE in the table \`statuses_${xxx}\`
# Record all the values for the old record
# The information will be stored in the table \`logs_statuses_${xxx}\`

DELIMITER \$\$

CREATE TRIGGER \`logs_statuses_${xxx}_delete\` AFTER DELETE ON \`statuses_${xxx}\`
FOR EACH ROW
BEGIN
  INSERT INTO \`logs_statuses_${xxx}\` (
    \`action\`,
    \`action_datetime\`,
    \`uuid\`,
    \`idemp_key\`,
    \`created_interface\`,
    \`created_by_id\`,
    \`created_by_ref_table\`,
    \`created_by_username_field\`,
    \`updated_interface\`,
    \`updated_by_id\`,
    \`updated_by_ref_table\`,
    \`updated_by_username_field\`,
    \`is_obsolete\`,
    \`order\`,
    \`is_active\`,
    \`${yyy}\`,
    \`${yyy}_description\`
    )
    VALUES
      ('DELETE',
        NOW(),
        OLD.\`uuid\`,
        OLD.\`idemp_key\`,
        OLD.\`created_interface\`,
        OLD.\`created_by_id\`,
        OLD.\`created_by_ref_table\`,
        OLD.\`created_by_username_field\`,
        OLD.\`updated_interface\`,
        OLD.\`updated_by_id\`,
        OLD.\`updated_by_ref_table\`,
        OLD.\`updated_by_username_field\`,
        OLD.\`is_obsolete\`,
        OLD.\`order\`,
        OLD.\`is_active\`,
        OLD.\`${yyy}\`,
        OLD.\`${yyy}_description\`
        )
  ;
END
\$\$

DELIMITER ;

# Create the View for all the statuses
DROP VIEW IF EXISTS \`view_statuses_${xxx}_all\`;
CREATE
    VIEW \`view_statuses_${xxx}_all\`
    AS
SELECT
    \`uuid\`,
    \`${yyy}\` AS \`status\`,
    \`is_active\`,
    \`is_obsolete\`,
    \`order\`,
    \`${yyy}_description\` AS \`status_description\`
FROM
    \`statuses_${xxx}\`
ORDER BY
	\`order\` ASC
	, \`status\` ASC
;

# - Grant access to the view \`view_statuses_${xxx}_all\` to the following users:
#   - 'view.statuses'@'%': Read only
GRANT
    SELECT,
    SHOW VIEW
ON \`view_statuses_${xxx}_all\`
TO 'view.statuses'@'%';

# - Grant access to the view \`view_statuses_${xxx}_all\` to the following users:
#   - 'view.data'@'%': Read only
GRANT
    SELECT,
    SHOW VIEW
ON \`view_statuses_${xxx}_all\`
TO 'view.data'@'%';

# Create the View for the statuses that are NOT obsolete
DROP VIEW IF EXISTS \`view_statuses_${xxx}_not_obsolete\`;
CREATE
    VIEW \`view_statuses_${xxx}_not_obsolete\`
    AS
SELECT
    \`uuid\`,
    \`${yyy}\` AS \`status\`,
    \`is_active\`,
    \`is_obsolete\`,
    \`order\`,
    \`${yyy}_description\` AS \`status_description\`
FROM
    \`statuses_${xxx}\`
WHERE (\`is_obsolete\` = 0)
ORDER BY
	\`order\` ASC
	, \`status\` ASC
;

# - Grant access to the view \`view_statuses_${xxx}_not_obsolete\` to the following users:
#   - 'view.statuses'@'%': Read only
GRANT
    SELECT,
    SHOW VIEW
ON \`view_statuses_${xxx}_not_obsolete\`
TO 'view.statuses'@'%';

# - Grant access to the view \`view_statuses_${xxx}_not_obsolete\` to the following users:
#   - 'view.data'@'%': Read only
GRANT
    SELECT,
    SHOW VIEW
ON \`view_statuses_${xxx}_not_obsolete\`
TO 'view.data'@'%';

# Create the View for the statuses that are Active
DROP VIEW IF EXISTS \`view_statuses_${xxx}_active\`;

CREATE
    VIEW \`view_statuses_${xxx}_active\`
    AS
SELECT
    \`uuid\`,
    \`${yyy}\` AS \`status\`,
    \`is_active\`,
    \`is_obsolete\`,
    \`order\`,
    \`${yyy}_description\` AS \`status_description\`
FROM
    \`statuses_${xxx}\`
WHERE (\`is_active\` = 1)
ORDER BY
	\`order\` ASC
	, \`status\` ASC
;

# - Grant access to the view \`view_statuses_${xxx}_active\` to the following users:
#   - 'view.statuses'@'%': Read only
GRANT
    SELECT,
    SHOW VIEW
ON \`view_statuses_${xxx}_active\`
TO 'view.statuses'@'%';

# - Grant access to the view \`view_statuses_${xxx}_active\` to the following users:
#   - 'view.data'@'%': Read only
GRANT
    SELECT,
    SHOW VIEW
ON \`view_statuses_${xxx}_active\`
TO 'view.data'@'%';

# Create the View for the statuses that are Inactive
DROP VIEW IF EXISTS \`view_statuses_${xxx}_inactive\`;

CREATE VIEW \`view_statuses_${xxx}_inactive\`
    AS
SELECT
    \`uuid\`,
    \`${yyy}\` AS \`status\`,
    \`is_active\`,
    \`is_obsolete\`,
    \`order\`,
    \`${yyy}_description\` AS \`status_description\`
FROM
    \`statuses_${xxx}\`
WHERE (\`is_active\` = 0)
ORDER BY
	\`order\` ASC
	, \`status\` ASC
;

# - Grant access to the view \`view_statuses_${xxx}_inactive\` to the following users:
#   - 'view.statuses'@'%': Read only
GRANT
    SELECT,
    SHOW VIEW
ON \`view_statuses_${xxx}_inactive\`
TO 'view.statuses'@'%';

# - Grant access to the view \`view_statuses_${xxx}_inactive\` to the following users:
#   - 'view.data'@'%': Read only
GRANT
    SELECT,
    SHOW VIEW
ON \`view_statuses_${xxx}_inactive\`
TO 'view.data'@'%';

# We prepare the value we need for the \`db_interfaces\` information
# We put this into the variable [@sql_seed_script]
SELECT "sql_seed_script"
    INTO @sql_seed_script
;

# We use default values for creation of the seed data
SELECT 'db.user.running.sql.seed.script' INTO @created_by_id;
SELECT '---' INTO @created_by_ref_table;
SELECT '---' INTO @created_by_username_field;

# Insert sample values in the table
INSERT  INTO \`statuses_${xxx}\`(
    \`created_interface\`,
    \`created_by_id\`,
    \`created_by_ref_table\`,
    \`created_by_username_field\`,
    \`order\`,
    \`is_active\`,
    \`${yyy}\`,
    \`${yyy}_description\`
    )
    VALUES
        (@sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 0, 0, 'UNKNOWN','We have no information about the status. This is an INACTIVE Status'),
        (@sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 40, 1, 'LIVE','The record is life. This is an ACTIVE Status'),
        (@sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 50, 1, 'SUNSET','The record is life but we should NOT create new such records. This is an ACTIVE Status'),
        (@sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 60, 0, 'TERMINATED','The record has been terminated. This is an INACTIVE Status'),
        (@sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 70, 0, 'DUPLICATE','This is a duplicate of an existing record. This is an INACTIVE Status')
;

EOM
