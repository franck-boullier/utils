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
cat > ./output/list_${xxx}.sql <<-EOM
# Replace 
#   - \`list_xxx\` with the name of your list table the name should start with \`list_\` and end with an \`s\` (ex: \`list_user_roles\`)
#   - \`yyy\` with name you have chosen for the designation field of your list table (ex: \`user_role\`).


# What this script will do:
#
# - Create a table \`list_${xxx}\` to list the possible statutes for a record.
# - Grant access to the table \`list_${xxx}\` to the following users:
#   - 'view.lists'@'%': Read only
#   - 'view.data'@'%': Read only
# - Create a trigger \`uuid_list_${xxx}\` to automatically generate the UUID for a new record.
# - Create a table \`logs_list_${xxx}\` to log all the changes in the table.
# - Grant access to the table \`logs_list_${xxx}\` to the following users:
#   - 'view.lists'@'%': Read only
#   - 'view.data'@'%': Read only
# - Create a trigger \`logs_list_${xxx}_insert\` to automatically log INSERT operations on the table \`list_${xxx}\`.
# - Create a trigger \`logs_list_${xxx}_update\` to automatically log UPDATE operations on the table \`list_${xxx}\`.
# - Create a trigger \`logs_list_${xxx}_delete\` to automatically log DELETE operations on the table \`list_${xxx}\`.
# - Create a view \`view_list_${xxx}_all\` to display all the records in the list.
# - Grant access to the view \`view_list_${xxx}_all\` to the following users:
#   - 'view.lists'@'%': Read only
#   - 'view.data'@'%': Read only
# - Create a view \`view_list_${xxx}_not_obsolete\` to display all the records that are NOT obsolete in the list.
# - Grant access to the view \`view_list_${xxx}_not_obsolete\` to the following users:
#   - 'view.lists'@'%': Read only
#   - 'view.data'@'%': Read only
# - Insert some sample data in the table \`list_${xxx}\`.
# 
# Constaints:
# - The status name must be unique.
# - The Interface to create the record MUST exist in the table \`db_interfaces\`
# - The Interface to update the record MUST exist in the table \`db_interfaces\`
#
# Automations and Triggers:
# - The UUID for a new record is automatically generated.
# - Logs of each changes in this table are recorded in the table \`logs_list_${xxx}\`
#
# Sample data are inserted in the table:
# - Record that must exist in the table \`db_interfaces\`
#   - field \`interface\`, value 'sql_seed_script'.
#

# Create the table \`list_${xxx}\`
CREATE TABLE \`list_${xxx}\` (
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

  -- start core data
EOM

while IFS='=' read -r k v1 v2 v3 v4
do

    if [[ "$k" == "core_data" || "$k" == "foreign_key_data" ]];
    then
cat >> ./output/list_${xxx}.sql <<-EOM
  \`${v1}\` ${v2:1:-1},
EOM
    fi
done <$1


cat >> ./output/list_${xxx}.sql <<-EOM
  \`${yyy}\` varchar(255) COLLATE utf8mb4_unicode_520_ci  NOT NULL COMMENT 'Designation',
  \`${yyy}_description\` text COLLATE utf8mb4_unicode_520_ci COMMENT 'Description/help text',
  -- end core data

  PRIMARY KEY (\`uuid\`),
  UNIQUE KEY \`unique_${yyy}_designation\` (\`${yyy}\`) COMMENT 'The designation must be unique',
  KEY \`${yyy}_idemp_key\` (\`idemp_key\`),
  KEY \`${yyy}_created_interface\` (\`created_interface\`),
  KEY \`${yyy}_updated_interface\` (\`updated_interface\`),
  CONSTRAINT \`${yyy}_created_interface\` FOREIGN KEY (\`created_interface\`) REFERENCES \`db_interfaces\` (\`interface\`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT \`${yyy}_updated_interface\` FOREIGN KEY (\`updated_interface\`) REFERENCES \`db_interfaces\` (\`interface\`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC
;

# - Grant access to the table \`list_${xxx}\` to the following users:
#   - 'view.lists'@'%': Read only
GRANT 
    SELECT,
    SHOW VIEW
ON \`list_${xxx}\`
TO 'view.lists'@'%';

# - Grant access to the table \`list_${xxx}\` to the following users:
#   - 'view.data'@'%': Read only
GRANT 
    SELECT,
    SHOW VIEW
ON \`list_${xxx}\`
TO 'view.data'@'%';

# Make sure that a UUID is generated each time a new record is created in the table \`list_${xxx}\`.
CREATE TRIGGER \`uuid_list_${xxx}\`
  BEFORE INSERT ON \`list_${xxx}\`
  FOR EACH ROW
  SET new.uuid = uuid()
;

# Create the table \`logs_list_${xxx}\` to store the changes in the data
CREATE TABLE \`logs_list_${xxx}\` (
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

  -- start core data
EOM

while IFS='=' read -r k v1 v2 v3 v4
do

    if [[ "$k" == "core_data" || "$k" == "foreign_key_data" ]];
    then
cat >> ./output/list_${xxx}.sql <<-EOM
  \`${v1}\` ${v2:1:-1},
EOM
    fi
done <$1


cat >> ./output/list_${xxx}.sql <<-EOM
  \`${yyy}\` varchar(255) COLLATE utf8mb4_unicode_520_ci  NOT NULL COMMENT 'Designation',
  \`${yyy}_description\` text COLLATE utf8mb4_unicode_520_ci COMMENT 'Description/help text',
  -- end core data

  KEY \`list_${xxx}_uuid\` (\`uuid\`) COMMENT 'Index the UUID for improved performances'
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC
;

# - Grant access to the table \`logs_list_${xxx}\` to the following users:
#   - 'view.lists'@'%': Read only
GRANT 
    SELECT,
    SHOW VIEW
ON \`logs_list_${xxx}\`
TO 'view.lists'@'%';

# - Grant access to the table \`logs_list_${xxx}\` to the following users:
#   - 'view.data'@'%': Read only
GRANT 
    SELECT,
    SHOW VIEW
ON \`logs_list_${xxx}\`
TO 'view.data'@'%';

# After a successful INSERT in the table \`list_${xxx}\`
# Record all the data Inserted in the table \`list_${xxx}\`
# The information will be stored in the table \`logs_list_${xxx}\`

DELIMITER \$\$

CREATE TRIGGER \`logs_list_${xxx}_insert\` AFTER INSERT ON \`list_${xxx}\`
FOR EACH ROW
BEGIN
  INSERT INTO \`logs_list_${xxx}\` (
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

  -- start core data
EOM

while IFS='=' read -r k v1 v2 v3 v4
do

    if [[ "$k" == "core_data" || "$k" == "foreign_key_data" ]];
    then
cat >> ./output/list_${xxx}.sql <<-EOM
    \`${v1}\`,
EOM
    fi
done <$1


cat >> ./output/list_${xxx}.sql <<-EOM
    \`${yyy}\`,
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
      NEW.\`is_obsolete\`, 
      NEW.\`order\`, 

  -- start core data
EOM

while IFS='=' read -r k v1 v2 v3 v4
do

    if [[ "$k" == "core_data" || "$k" == "foreign_key_data" ]];
    then
cat >> ./output/list_${xxx}.sql <<-EOM
    \`${v1}\`,
EOM
    fi
done <$1


cat >> ./output/list_${xxx}.sql <<-EOM
      NEW.\`${yyy}\`, 
      NEW.\`${yyy}_description\`
  -- end core data

    )
  ;
END
\$\$

DELIMITER ;

# After a successful UPDATE in the table \`list_${xxx}\`
# Record all the values for the old record
# Record all the values for the new record
# data Inserted in the table \`list_${xxx}\`
# The information will be stored in the table \`logs_list_${xxx}\`

DELIMITER \$\$

CREATE TRIGGER \`logs_list_${xxx}_update\` AFTER UPDATE ON \`list_${xxx}\`
FOR EACH ROW
BEGIN
  INSERT INTO \`logs_list_${xxx}\` (
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

  -- start core data
EOM

while IFS='=' read -r k v1 v2 v3 v4
do

    if [[ "$k" == "core_data" || "$k" == "foreign_key_data" ]];
    then
cat >> ./output/list_${xxx}.sql <<-EOM
    \`${v1}\`,
EOM
    fi
done <$1


cat >> ./output/list_${xxx}.sql <<-EOM
    \`${yyy}\`, 
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
        OLD.\`is_obsolete\`, 
        OLD.\`order\`, 

  -- start core data
EOM

while IFS='=' read -r k v1 v2 v3 v4
do

    if [[ "$k" == "core_data" || "$k" == "foreign_key_data" ]];
    then
cat >> ./output/list_${xxx}.sql <<-EOM
    \`${v1}\`,
EOM
    fi
done <$1


cat >> ./output/list_${xxx}.sql <<-EOM
        OLD.\`${yyy}\`, 
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
        NEW.\`is_obsolete\`, 
        NEW.\`order\`, 

  -- start core data
EOM

while IFS='=' read -r k v1 v2 v3 v4
do

    if [[ "$k" == "core_data" || "$k" == "foreign_key_data" ]];
    then
cat >> ./output/list_${xxx}.sql <<-EOM
    \`${v1}\`,
EOM
    fi
done <$1


cat >> ./output/list_${xxx}.sql <<-EOM
        NEW.\`${yyy}\`, 
        NEW.\`${yyy}_description\`
  -- end core data

      )
  ;
END
\$\$

DELIMITER ;

# After a successful DELETE in the table \`list_${xxx}\`
# Record all the values for the old record
# The information will be stored in the table \`logs_list_${xxx}\`

DELIMITER \$\$

CREATE TRIGGER \`logs_list_${xxx}_delete\` AFTER DELETE ON \`list_${xxx}\`
FOR EACH ROW
BEGIN
  INSERT INTO \`logs_list_${xxx}\` (
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

  -- start core data
EOM

while IFS='=' read -r k v1 v2 v3 v4
do

    if [[ "$k" == "core_data" || "$k" == "foreign_key_data" ]];
    then
cat >> ./output/list_${xxx}.sql <<-EOM
    \`${v1}\`,
EOM
    fi
done <$1


cat >> ./output/list_${xxx}.sql <<-EOM
    \`${yyy}\`, 
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
        OLD.\`is_obsolete\`, 
        OLD.\`order\`, 

  -- start core data
EOM

while IFS='=' read -r k v1 v2 v3 v4
do

    if [[ "$k" == "core_data" || "$k" == "foreign_key_data" ]];
    then
cat >> ./output/list_${xxx}.sql <<-EOM
    \`${v1}\`,
EOM
    fi
done <$1


cat >> ./output/list_${xxx}.sql <<-EOM
        OLD.\`${yyy}\`, 
        OLD.\`${yyy}_description\`
  -- end core data

      )
  ;
END
\$\$

DELIMITER ;

# Create the View for all the values in the list
DROP VIEW IF EXISTS \`view_list_${xxx}_all\`;

CREATE
    VIEW \`view_list_${xxx}_all\` 
    AS
SELECT
    \`uuid\`, 
    \`is_obsolete\`, 
    \`order\`, 

  -- start core data
EOM

while IFS='=' read -r k v1 v2 v3 v4
do

    if [[ "$k" == "core_data" || "$k" == "foreign_key_data" ]];
    then
cat >> ./output/list_${xxx}.sql <<-EOM
    \`${v1}\`,
EOM
    fi
done <$1


cat >> ./output/list_${xxx}.sql <<-EOM
    \`${yyy}\`, 
    \`${yyy}_description\`
  -- end core data

FROM
    \`list_${xxx}\`
ORDER BY 
	\`order\` ASC
	, \`${yyy}\` ASC
;

# - Grant access to the view \`view_list_${xxx}_all\` to the following users:
#   - 'view.lists'@'%': Read only
GRANT 
    SELECT,
    SHOW VIEW
ON \`view_list_${xxx}_all\`
TO 'view.lists'@'%';

# - Grant access to the table \`view_list_${xxx}_all\` to the following users:
#   - 'view.data'@'%': Read only
GRANT 
    SELECT,
    SHOW VIEW
ON \`view_list_${xxx}_all\`
TO 'view.data'@'%';

# Create the View for the the values in the list that are NOT obsolete
DROP VIEW IF EXISTS \`view_list_${xxx}_not_obsolete\`;

CREATE
    VIEW \`view_list_${xxx}_not_obsolete\` 
    AS
SELECT
    \`uuid\`, 
    \`is_obsolete\`, 
    \`order\`, 

  -- start core data
EOM

while IFS='=' read -r k v1 v2 v3 v4
do

    if [[ "$k" == "core_data" || "$k" == "foreign_key_data" ]];
    then
cat >> ./output/list_${xxx}.sql <<-EOM
    \`${v1}\`,
EOM
    fi
done <$1


cat >> ./output/list_${xxx}.sql <<-EOM
    \`${yyy}\`, 
    \`${yyy}_description\`
  -- end core data

FROM
    \`list_${xxx}\`
WHERE (\`is_obsolete\` = 0)
ORDER BY 
	\`order\` ASC
	, \`${yyy}\` ASC
;

# - Grant access to the view \`view_list_${xxx}_not_obsolete\` to the following users:
#   - 'view.lists'@'%': Read only
GRANT 
    SELECT,
    SHOW VIEW
ON \`view_list_${xxx}_not_obsolete\`
TO 'view.lists'@'%';

# - Grant access to the table \`view_list_${xxx}_not_obsolete\` to the following users:
#   - 'view.data'@'%': Read only
GRANT 
    SELECT,
    SHOW VIEW
ON \`view_list_${xxx}_not_obsolete\`
TO 'view.data'@'%';

EOM
