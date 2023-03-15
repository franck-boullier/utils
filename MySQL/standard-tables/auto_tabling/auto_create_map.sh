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
cat > ./output/map_${xxx}_${yyy}.sql <<-EOM
# Replace
#   - \`map_table_xxx_table_yyy\` with a unique name of your mapping table.
#   - \`table_xxx\` with the name of the first table that you need as a map source.
#   - \`table_yyy\` with the name of the second table that you need as a map source.
#   - \`table_xxx_record\` with the name of field in the mapping Table to identify records in \`table_xxx\`.
#   - \`table_xxx_uuid\` with the name of the UUID field in \`table_xxx\`.  <--- THIS IS USUALY \`uuid\`
#   - \`table_yyy_record\` with the name of field in the mapping Table to identify records in \`table_yyy\`.
#   - \`table_yyy_uuid\` with the name of the UUID field in \`table_yyy\` <--- THIS IS USUALLY \`uuid\`

# What this script will do:
#
# - Create a table \`map_${xxx}_${yyy}\` to list the possible relations between
#   - records in a table \`${table_xxx}\` and
#   - records in a table \`${table_yyy}\`.
# - Grant access to the table \`map_${xxx}_${yyy}\` to the following users:
#   - 'view.data'@'%': Read only
# - Create a trigger \`uuid_map_${xxx}_${yyy}\` to automatically generate the UUID for a new record.
# - Create a table \`logs_map_${xxx}_${yyy}\` to log all the changes in the table.
# - Grant access to the table \`logs_map_${xxx}_${yyy}\` to the following users:
#   - 'view.data'@'%': Read only
# - Create a trigger \`logs_map_${xxx}_${yyy}_insert\` to automatically log INSERT operations on the table \`map_${xxx}_${yyy}\`.
# - Create a trigger \`logs_map_${xxx}_${yyy}_update\` to automatically log UPDATE operations on the table \`map_${xxx}_${yyy}\`.
# - Create a trigger \`logs_map_${xxx}_${yyy}_delete\` to automatically log DELETE operations on the table \`map_${xxx}_${yyy}\`.
#
# Constaints:
# - The Interface to create the record MUST exist in the table \`db_interfaces\`
# - The Interface to update the record MUST exist in the table \`db_interfaces\`
#
# Automations and Triggers:
# - The UUID for a new record is automatically generated.
# - Logs of each changes in this table are recorded in the table \`logs_map_table_xxx_table_yyy\`
#


# Create the table \`map_${xxx}_${yyy}\`
CREATE TABLE \`map_${xxx}_${yyy}\` (
  \`uuid\` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The globally unique UUID for this record',
  \`created_interface\` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the interface sytem that was used to CREATE the record?',
  \`idemp_key\` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'Idempotency key. This is to make sure that a record is not created twice when an API call is made',
  \`created_by_id\` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the user who created the record?',
  \`created_by_ref_table\` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the name of the table where we store user information?',
  \`created_by_username_field\` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the name of the field that stores the username associated to the userid?',
  \`updated_interface\` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the interface sytem that was used to UPDATE the record?',
  \`updated_by_id\` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the user who updated the record?',
  \`updated_by_ref_table\` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the name of the table where we store user information?',
  \`updated_by_username_field\` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the name of the field that stores the username associated to the userid?',
  \`is_obsolete\` tinyint(1) DEFAULT '0' COMMENT 'is this obsolete?',
  \`${xxx}_uuid\` varchar(255) COLLATE utf8mb4_unicode_520_ci  NOT NULL COMMENT 'The UUID of the record in the table \`${table_xxx}\`',
  \`${yyy}_uuid\` varchar(255) COLLATE utf8mb4_unicode_520_ci  NOT NULL COMMENT 'The UUID of the record in the table \`${table_yyy}\`',

  -- start core data
EOM

while IFS='=' read -r k v1 v2 v3 v4
do

    if [[ "$k" == "core_data" || "$k" == "foreign_key_data" ]];
    then
cat >> ./output/map_${xxx}_${yyy}.sql <<-EOM
  \`${v1}\` ${v2:1:-1},
EOM
    fi
done <$1


cat >> ./output/map_${xxx}_${yyy}.sql <<-EOM
  -- end core data

  \`comment\` TEXT COLLATE utf8mb4_unicode_520_ci  DEFAULT NULL COMMENT 'A comment',
  PRIMARY KEY \`unique_${xxx}_${yyy}_uuid\` (\`uuid\`),
  UNIQUE KEY (
    \`${xxx}_uuid\`,

    -- start core data
EOM

while IFS='=' read -r k v1 v2 v3 v4
do

    if [[ "$k" == "core_data" || "$k" == "foreign_key_data" ]];
    then
cat >> ./output/map_${xxx}_${yyy}.sql <<-EOM
    \`${v1}\`,
EOM
    fi
done <$1


cat >> ./output/map_${xxx}_${yyy}.sql <<-EOM
    -- end core data

    \`${yyy}_uuid\`) COMMENT 'The combinations must be unique.',
  KEY \`map_${xxx}_${yyy}_idemp_key\` (\`idemp_key\`),
  KEY \`map_${xxx}_${yyy}_created_interface\` (\`created_interface\`),
  KEY \`map_${xxx}_${yyy}_updated_interface\` (\`updated_interface\`),
  KEY \`map_${xxx}_${yyy}_${xxx}_uuid\` (\`${xxx}_uuid\`),
  KEY \`map_${xxx}_${yyy}_${yyy}_uuid\` (\`${yyy}_uuid\`),

  -- start foreign key data
EOM

while IFS='=' read -r k v1 v2 v3 v4
do

    if [[ "$k" == "foreign_key_data" ]];
    then
cat >> ./output/map_${xxx}_${yyy}.sql <<-EOM
  CONSTRAINT \`${yyy}_${v1}\` FOREIGN KEY (\`${v1}\`) REFERENCES \`${v3}\` (\`${v4}\`) ON DELETE CASCADE ON UPDATE CASCADE,
EOM
    fi
done <$1

cat >> ./output/map_${xxx}_${yyy}.sql <<-EOM
  -- end foreign key data

  CONSTRAINT \`map_${xxx}_${yyy}_created_interface\` FOREIGN KEY (\`created_interface\`) REFERENCES \`db_interfaces\` (\`interface\`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT \`map_${xxx}_${yyy}_updated_interface\` FOREIGN KEY (\`updated_interface\`) REFERENCES \`db_interfaces\` (\`interface\`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT \`map_${xxx}_${yyy}_${xxx}_uuid\` FOREIGN KEY (\`${xxx}_uuid\`) REFERENCES \`${table_xxx}\` (\`uuid\`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT \`map_${xxx}_${yyy}_${yyy}_uuid\` FOREIGN KEY (\`${yyy}_uuid\`) REFERENCES \`${table_yyy}\` (\`uuid\`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC
;


# - Grant access to the table \`map_${xxx}_${yyy}\`to the following users:
#   - 'view.data'@'%': Read only
GRANT
    SELECT,
    SHOW VIEW
ON \`map_${xxx}_${yyy}\`
TO 'view.data'@'%';

# Make sure that a UUID is generated each time a new record is created in the table \`map_${xxx}_${yyy}\`.
CREATE TRIGGER \`uuid_map_${xxx}_${yyy}\`
  BEFORE INSERT ON \`map_${xxx}_${yyy}\`
  FOR EACH ROW
  SET new.uuid = uuid()
;

# Create the table \`logs_map_${xxx}_${yyy}\` to store the changes in the data
CREATE TABLE \`logs_map_${xxx}_${yyy}\` (
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
  \`${xxx}_uuid\` varchar(255) COLLATE utf8mb4_unicode_520_ci  NOT NULL COMMENT 'The UUID of the record in the table \`${table_xxx}\`',
  \`${yyy}_uuid\` varchar(255) COLLATE utf8mb4_unicode_520_ci  NOT NULL COMMENT 'The UUID of the record in the table \`${table_yyy}\`',

  -- start core data
EOM

while IFS='=' read -r k v1 v2 v3 v4
do

    if [[ "$k" == "core_data" || "$k" == "foreign_key_data" ]];
    then
cat >> ./output/map_${xxx}_${yyy}.sql <<-EOM
  \`${v1}\` ${v2:1:-1},
EOM
    fi
done <$1


cat >> ./output/map_${xxx}_${yyy}.sql <<-EOM
  -- end core data

  \`comment\` TEXT COLLATE utf8mb4_unicode_520_ci  DEFAULT NULL COMMENT 'A comment',
  KEY \`logs_map_${xxx}_${yyy}_uuid\` (\`uuid\`) COMMENT 'Index the UUID for improved performances',
  KEY \`logs_map_${xxx}_${yyy}_${xxx}_uuid\` (\`${xxx}_uuid\`) COMMENT 'Index the ${table_xxx} record UUID for improved performances',
  KEY \`logs_map_${xxx}_${yyy}_${yyy}_uuid\` (\`${yyy}_uuid\`) COMMENT 'Index the ${table_yyy} record UUID for improved performances'
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC
;

# - Grant access to the table \`logs_map_${xxx}_${yyy}\` to the following users:
#   - 'view.data'@'%': Read only
GRANT
    SELECT,
    SHOW VIEW
ON \`logs_map_${xxx}_${yyy}\`
TO 'view.data'@'%';

# After a successful INSERT in the table \`map_${xxx}_${yyy}\`
# Record all the data Inserted in the table \`map_${xxx}_${yyy}\`
# The information will be stored in the table \`logs_map_${xxx}_${yyy}\`

DELIMITER \$\$

CREATE TRIGGER \`logs_map_${xxx}_${yyy}_insert\` AFTER INSERT ON \`map_${xxx}_${yyy}\`
FOR EACH ROW
BEGIN
  INSERT INTO \`logs_map_${xxx}_${yyy}\` (
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
    \`${xxx}_uuid\`,
    \`${yyy}_uuid\`,

  -- start core data
EOM

while IFS='=' read -r k v1 v2 v3 v4
do

    if [[ "$k" == "core_data" || "$k" == "foreign_key_data" ]];
    then
cat >> ./output/map_${xxx}_${yyy}.sql <<-EOM
    \`${v1}\`,
EOM
    fi
done <$1


cat >> ./output/map_${xxx}_${yyy}.sql <<-EOM
  -- end core data

    \`comment\`
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
      NEW.\`${xxx}_uuid\`,
      NEW.\`${yyy}_uuid\`,

  -- start core data
EOM

while IFS='=' read -r k v1 v2 v3 v4
do

    if [[ "$k" == "core_data" || "$k" == "foreign_key_data" ]];
    then
cat >> ./output/map_${xxx}_${yyy}.sql <<-EOM
       NEW.\`${v1}\`,
EOM
    fi
done <$1


cat >> ./output/map_${xxx}_${yyy}.sql <<-EOM
  -- end core data

      NEW.\`comment\`
      )
  ;
END
\$\$

DELIMITER ;

# After a successful UPDATE in the table \`map_${xxx}_${yyy}\`
# Record all the values for the old record
# Record all the values for the new record
# data Inserted in the table \`map_${xxx}_${yyy}\`
# The information will be stored in the table \`logs_map_${xxx}_${yyy}\`

DELIMITER \$\$

CREATE TRIGGER \`logs_map_${xxx}_${yyy}_update\` AFTER UPDATE ON \`map_${xxx}_${yyy}\`
FOR EACH ROW
BEGIN
  INSERT INTO \`logs_map_${xxx}_${yyy}\` (
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
    \`${xxx}_uuid\`,
    \`${yyy}_uuid\`,

  -- start core data
EOM

while IFS='=' read -r k v1 v2 v3 v4
do

    if [[ "$k" == "core_data" || "$k" == "foreign_key_data" ]];
    then
cat >> ./output/map_${xxx}_${yyy}.sql <<-EOM
    \`${v1}\`,
EOM
    fi
done <$1


cat >> ./output/map_${xxx}_${yyy}.sql <<-EOM
  -- end core data

    \`comment\`
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
        OLD.\`${xxx}_uuid\`,
        OLD.\`${yyy}_uuid\`,

  -- start core data
EOM

while IFS='=' read -r k v1 v2 v3 v4
do

    if [[ "$k" == "core_data" || "$k" == "foreign_key_data" ]];
    then
cat >> ./output/map_${xxx}_${yyy}.sql <<-EOM
       OLD.\`${v1}\`,
EOM
    fi
done <$1


cat >> ./output/map_${xxx}_${yyy}.sql <<-EOM
  -- end core data

        OLD.\`comment\`
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
        NEW.\`${xxx}_uuid\`,
        NEW.\`${yyy}_uuid\`,

  -- start core data
EOM

while IFS='=' read -r k v1 v2 v3 v4
do

    if [[ "$k" == "core_data" || "$k" == "foreign_key_data" ]];
    then
cat >> ./output/map_${xxx}_${yyy}.sql <<-EOM
       NEW.\`${v1}\`,
EOM
    fi
done <$1


cat >> ./output/map_${xxx}_${yyy}.sql <<-EOM
  -- end core data

        NEW.\`comment\`
      )
  ;
END
\$\$

DELIMITER ;

# After a successful DELETE in the table \`map_${xxx}_${yyy}\`
# Record all the values for the old record
# The information will be stored in the table \`logs_map_${xxx}_${yyy}\`

DELIMITER \$\$

CREATE TRIGGER \`logs_map_${xxx}_${yyy}_delete\` AFTER DELETE ON \`map_${xxx}_${yyy}\`
FOR EACH ROW
BEGIN
  INSERT INTO \`logs_map_${xxx}_${yyy}\` (
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
    \`${xxx}_uuid\`,
    \`${yyy}_uuid\`,

  -- start core data
EOM

while IFS='=' read -r k v1 v2 v3 v4
do

    if [[ "$k" == "core_data" || "$k" == "foreign_key_data" ]];
    then
cat >> ./output/map_${xxx}_${yyy}.sql <<-EOM
    \`${v1}\`,
EOM
    fi
done <$1


cat >> ./output/map_${xxx}_${yyy}.sql <<-EOM
  -- end core data

    \`comment\`
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
        OLD.\`${xxx}_uuid\`,
        OLD.\`${yyy}_uuid\`,

  -- start core data
EOM

while IFS='=' read -r k v1 v2 v3 v4
do

    if [[ "$k" == "core_data" || "$k" == "foreign_key_data" ]];
    then
cat >> ./output/map_${xxx}_${yyy}.sql <<-EOM
       OLD.\`${v1}\`,
EOM
    fi
done <$1


cat >> ./output/map_${xxx}_${yyy}.sql <<-EOM
  -- end core data

        OLD.\`comment\`
      )
  ;
END
\$\$

DELIMITER ;

EOM
