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
cat > ./output/${table_prefix}${xxx}.sql <<-EOM
# Replace
#   - \`data_1_xxx\` with the name of your table. The name should start with \`data_1_\` and end with an \`s\` (ex: \`data_1_merchants\`)
#   - \`yyy\` with name you have chosen for the designation field of your table (ex: \`merchant\`).

# What this script will do:
#
# - Create a table \`${table_prefix}${xxx}\` to list the possible statutes for a record.
# - Grant access to the table \`${table_prefix}${xxx}\` to the following users:
#   - 'view.data'@'%': Read only
# - Create a trigger \`uuid_${table_prefix}${xxx}\` to automatically generate the UUID for a new record.
# - Create a table \`logs_${table_prefix}${xxx}\` to log all the changes in the table.
# - Grant access to the table \`logs_${table_prefix}${xxx}\` to the following users:
#   - 'view.data'@'%': Read only
# - Create a trigger \`logs_${table_prefix}${xxx}_insert\` to automatically log INSERT operations on the table \`${table_prefix}${xxx}\`.
# - Create a trigger \`logs_${table_prefix}${xxx}_update\` to automatically log UPDATE operations on the table \`${table_prefix}${xxx}\`.
# - Create a trigger \`logs_${table_prefix}${xxx}_delete\` to automatically log DELETE operations on the table \`${table_prefix}${xxx}\`.
# - Insert some sample data in the table \`${table_prefix}${xxx}\`.
#
# Constaints:
# - The designation must be unique.
# - The Interface to create the record MUST exist in the table \`db_interfaces\`
# - The Interface to update the record MUST exist in the table \`db_interfaces\`
# - The \`${yyy}_status\` record MUST exist in the the table \`statuses_${yyy}\`.
#
# Automations and Triggers:
# - The UUID for a new record is automatically generated.
# - Logs of each changes in this table are recorded in the table \`logs_${table_prefix}${xxx}\`
#
# Sample data are inserted in the table:
# - Record that must exist in the table \`db_interfaces\`
#   - field \`interface_designation\`, value 'sql_seed_script'.
# - Record that must exist in the table \`${yyy}_status\`
#   - field \`${yyy}_status\`, value 'Unknown'.
#   - field \`${yyy}_status\`, value 'LIVE'.
#
#
# Create the table \`${table_prefix}${xxx}\`
CREATE TABLE \`${table_prefix}${xxx}\` (
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
  \`order\` int(10) NOT NULL DEFAULT '0' COMMENT 'Order in the list',

  -- start core data
EOM

while IFS='=' read -r k v1 v2 v3 v4
do

    if [[ "$k" == "core_data" || "$k" == "foreign_key_data" ]];
    then
cat >> ./output/${table_prefix}${xxx}.sql <<-EOM
  \`${v1}\` ${v2:1:-1},
EOM
    fi
done <$1


cat >> ./output/${table_prefix}${xxx}.sql <<-EOM
  \`${yyy}\` varchar(255) COLLATE utf8mb4_unicode_520_ci  NOT NULL COMMENT 'Designation',
  \`${yyy}_status_id\` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'What is the status for this?',
  \`${yyy}_description\` text COLLATE utf8mb4_unicode_520_ci COMMENT 'Description/help text',
  -- end core data

  PRIMARY KEY (\`uuid\`),
  UNIQUE KEY \`unique_${yyy}_designation\` (\`${yyy}\`) COMMENT 'The designation must be unique',
  KEY \`${yyy}_created_interface\` (\`created_interface\`),
  KEY \`${yyy}_idemp_key\` (\`idemp_key\`),
  KEY \`${yyy}_updated_interface\` (\`updated_interface\`),
  KEY \`${yyy}_${yyy}_status_id\` (\`${yyy}_status_id\`),

  -- start foreign key data
EOM

while IFS='=' read -r k v1 v2 v3 v4
do

    if [[ "$k" == "foreign_key_data" ]];
    then
cat >> ./output/${table_prefix}${xxx}.sql <<-EOM
  CONSTRAINT \`${yyy}_${v1}\` FOREIGN KEY (\`${v1}\`) REFERENCES \`${v3}\` (\`${v4}\`) ON DELETE CASCADE ON UPDATE CASCADE,
EOM
    fi
done <$1

cat >> ./output/${table_prefix}${xxx}.sql <<-EOM
  -- end foreign key data

  CONSTRAINT \`${yyy}_created_interface\` FOREIGN KEY (\`created_interface\`) REFERENCES \`db_interfaces\` (\`interface\`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT \`${yyy}_updated_interface\` FOREIGN KEY (\`updated_interface\`) REFERENCES \`db_interfaces\` (\`interface\`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT \`${yyy}_${yyy}_status_id\` FOREIGN KEY (\`${yyy}_status_id\`) REFERENCES \`statuses_${yyy}\` (\`uuid\`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC
;

# - Grant access to the table \`${table_prefix}${xxx}\` to the following users:
#   - 'view.data'@'%': Read only
GRANT
    SELECT,
    SHOW VIEW
ON \`${table_prefix}${xxx}\`
TO 'view.data'@'%';

# Make sure that a UUID is generated each time a new record is created in the table \`${table_prefix}${xxx}\`.
CREATE TRIGGER \`uuid_${table_prefix}${xxx}\`
  BEFORE INSERT ON \`${table_prefix}${xxx}\`
  FOR EACH ROW
  SET new.uuid = uuid()
;

# Create the table \`logs_${table_prefix}${xxx}\` to store the changes in the data
CREATE TABLE \`logs_${table_prefix}${xxx}\` (
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
  \`order\` int(10) NOT NULL DEFAULT '0' COMMENT 'Order in the list',

  -- start core data
EOM

while IFS='=' read -r k v1 v2 v3 v4
do

    if [[ "$k" == "core_data" || "$k" == "foreign_key_data" ]];
    then
cat >> ./output/${table_prefix}${xxx}.sql <<-EOM
  \`${v1}\` ${v2:1:-1},
EOM
    fi
done <$1


cat >> ./output/${table_prefix}${xxx}.sql <<-EOM
  \`${yyy}\` varchar(255) COLLATE utf8mb4_unicode_520_ci  NOT NULL COMMENT 'Designation',
  \`${yyy}_status_id\` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'What is the status for this?',
  \`${yyy}_description\` text COLLATE utf8mb4_unicode_520_ci COMMENT 'Description/help text',
  -- end core data

  KEY \`${table_prefix}${xxx}_uuid\` (\`uuid\`) COMMENT 'Index the UUID for improved performances'
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC
;

# - Grant access to the table \`logs_${table_prefix}${xxx}\` to the following users:
#   - 'view.data'@'%': Read only
GRANT
    SELECT,
    SHOW VIEW
ON \`logs_${table_prefix}${xxx}\`
TO 'view.data'@'%';

# After a successful INSERT in the table \`${table_prefix}${xxx}\`
# Record all the data Inserted in the table \`${table_prefix}${xxx}\`
# The information will be stored in the table \`logs_${table_prefix}${xxx}\`

DELIMITER \$\$

CREATE TRIGGER \`logs_${table_prefix}${xxx}_insert\` AFTER INSERT ON \`${table_prefix}${xxx}\`
FOR EACH ROW
BEGIN
  INSERT INTO \`logs_${table_prefix}${xxx}\` (
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
    \`order\`,

  -- start core data
EOM

while IFS='=' read -r k v1 v2 v3 v4
do

    if [[ "$k" == "core_data" || "$k" == "foreign_key_data" ]];
    then
cat >> ./output/${table_prefix}${xxx}.sql <<-EOM
    \`${v1}\`,
EOM
    fi
done <$1


cat >> ./output/${table_prefix}${xxx}.sql <<-EOM
    \`${yyy}\`,
    \`${yyy}_status_id\`,
    \`${yyy}_description\`
  -- end core data

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
      NEW.\`order\`,

  -- start core data
EOM

while IFS='=' read -r k v1 v2 v3 v4
do

    if [[ "$k" == "core_data" || "$k" == "foreign_key_data" ]];
    then
cat >> ./output/${table_prefix}${xxx}.sql <<-EOM
      NEW.\`${v1}\`,
EOM
    fi
done <$1


cat >> ./output/${table_prefix}${xxx}.sql <<-EOM
      NEW.\`${yyy}\`,
      NEW.\`${yyy}_status_id\`,
      NEW.\`${yyy}_description\`
  -- end core data

    )
  ;
END
\$\$

DELIMITER ;

# After a successful UPDATE in the table \`${table_prefix}${xxx}\`
# Record all the values for the old record
# Record all the values for the new record
# data Inserted in the table \`${table_prefix}${xxx}\`
# The information will be stored in the table \`logs_${table_prefix}${xxx}\`

DELIMITER \$\$

CREATE TRIGGER \`logs_${table_prefix}${xxx}_update\` AFTER UPDATE ON \`${table_prefix}${xxx}\`
FOR EACH ROW
BEGIN
  INSERT INTO \`logs_${table_prefix}${xxx}\` (
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
    \`order\`,

  -- start core data
EOM

while IFS='=' read -r k v1 v2 v3 v4
do

    if [[ "$k" == "core_data" || "$k" == "foreign_key_data" ]];
    then
cat >> ./output/${table_prefix}${xxx}.sql <<-EOM
    \`${v1}\`,
EOM
    fi
done <$1


cat >> ./output/${table_prefix}${xxx}.sql <<-EOM
    \`${yyy}\`,
    \`${yyy}_status_id\`,
    \`${yyy}_description\`
  -- end core data

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
        OLD.\`order\`,

  -- start core data
EOM

while IFS='=' read -r k v1 v2 v3 v4
do

    if [[ "$k" == "core_data" || "$k" == "foreign_key_data" ]];
    then
cat >> ./output/${table_prefix}${xxx}.sql <<-EOM
        OLD.\`${v1}\`,
EOM
    fi
done <$1


cat >> ./output/${table_prefix}${xxx}.sql <<-EOM
        OLD.\`${yyy}\`,
        OLD.\`${yyy}_status_id\`,
        OLD.\`${yyy}_description\`
  -- end core data

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
        NEW.\`order\`,

  -- start core data
EOM

while IFS='=' read -r k v1 v2 v3 v4
do

    if [[ "$k" == "core_data" || "$k" == "foreign_key_data" ]];
    then
cat >> ./output/${table_prefix}${xxx}.sql <<-EOM
        NEW.\`${v1}\`,
EOM
    fi
done <$1


cat >> ./output/${table_prefix}${xxx}.sql <<-EOM
        NEW.\`${yyy}\`,
        NEW.\`${yyy}_status_id\`,
        NEW.\`${yyy}_description\`
  -- end core data

      )
  ;
END
\$\$

DELIMITER ;

# After a successful DELETE in the table \`${table_prefix}${xxx}\`
# Record all the values for the old record
# The information will be stored in the table \`logs_${table_prefix}${xxx}\`

DELIMITER \$\$

CREATE TRIGGER \`logs_${table_prefix}${xxx}_delete\` AFTER DELETE ON \`${table_prefix}${xxx}\`
FOR EACH ROW
BEGIN
  INSERT INTO \`logs_${table_prefix}${xxx}\` (
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
    \`order\`,

  -- start core data
EOM

while IFS='=' read -r k v1 v2 v3 v4
do

    if [[ "$k" == "core_data" || "$k" == "foreign_key_data" ]];
    then
cat >> ./output/${table_prefix}${xxx}.sql <<-EOM
    \`${v1}\`,
EOM
    fi
done <$1


cat >> ./output/${table_prefix}${xxx}.sql <<-EOM
    \`${yyy}\`,
    \`${yyy}_status_id\`,
    \`${yyy}_description\`
  -- end core data

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
        OLD.\`order\`,

  -- start core data
EOM

while IFS='=' read -r k v1 v2 v3 v4
do

    if [[ "$k" == "core_data" || "$k" == "foreign_key_data" ]];
    then
cat >> ./output/${table_prefix}${xxx}.sql <<-EOM
        OLD.\`${v1}\`,
EOM
    fi
done <$1


cat >> ./output/${table_prefix}${xxx}.sql <<-EOM
        OLD.\`${yyy}\`,
        OLD.\`${yyy}_status_id\`,
        OLD.\`${yyy}_description\`
  -- end core data

      )
  ;
END
\$\$

DELIMITER ;

# Create the View for all the values in the list
DROP VIEW IF EXISTS \`view_${table_prefix}${xxx}_all\`;

CREATE VIEW \`view_${table_prefix}${xxx}_all\`
    AS
SELECT
    \`uuid\`,
    \`created_interface\`,
    \`updated_interface\`,
    \`order\`,

  -- start core data
EOM

while IFS='=' read -r k v1 v2 v3 v4
do

    if [[ "$k" == "core_data" || "$k" == "foreign_key_data" ]];
    then
cat >> ./output/${table_prefix}${xxx}.sql <<-EOM
    \`${v1}\`,
EOM
    fi
done <$1


cat >> ./output/${table_prefix}${xxx}.sql <<-EOM
    \`${yyy}\`,
    \`${yyy}_status_id\`,
    \`${yyy}_description\`
  -- end core data

FROM
    \`${table_prefix}${xxx}\`
ORDER BY
	\`order\` ASC
	, \`${yyy}\` ASC
;


####################################################################
# Seed Data Section
# Stub for inserting sample values in the table, if needed
####################################################################
# We prepare the value we need for the \`db_interfaces\` information
# We put this into the variable [@sql_seed_script]
SELECT "sql_seed_script"
    INTO @sql_seed_script
;

# We need to get the uuid for the value 'LIVE' in the table \`statuses_${yyy}\`
# We put this into the variable [@UUID_LIVE_${yyy}_status]
SELECT \`uuid\`
    INTO @UUID_LIVE_${yyy}_status
FROM \`statuses_${yyy}\`
    WHERE \`${yyy}_status\` = 'LIVE'
;

# We use default values for creation of the seed data
SELECT 'db.user.running.sql.seed.script' INTO @created_by_id;
SELECT '---' INTO @created_by_ref_table;
SELECT '---' INTO @created_by_username_field;

# Insert sample values in the table, if needed
EOM
