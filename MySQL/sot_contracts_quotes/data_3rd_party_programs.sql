# What this script will do:
#
# - Create a table `data_3rd_party_programs` to list the possible statutes for a record.
# - Create a trigger `uuid_data_3rd_party_programs` to automatically generate the UUID for a new record.
# - Create a table `logs_data_3rd_party_programs` to log all the changes in the table.
# - Create a trigger `logs_data_3rd_party_programs_insert` to automatically log INSERT operations on the table `data_3rd_party_programs`.
# - Create a trigger `logs_data_3rd_party_programs_update` to automatically log UPDATE operations on the table `data_3rd_party_programs`.
# - Create a trigger `logs_data_3rd_party_programs_delete` to automatically log DELETE operations on the table `data_3rd_party_programs`.
# - Insert some sample data in the table `data_3rd_party_programs`.
# 
# Constaints:
# - The designation must be unique.
# - The Interface to create the record MUST exist in the table `db_interfaces`
# - The Interface to update the record MUST exist in the table `db_interfaces`
# - The `3rd_party_program_status` record MUST exist in the the table `statuses_3rd_party_program`.
#
# Automations and Triggers:
# - The UUID for a new record is automatically generated.
# - Logs of each changes in this table are recorded in the table `logs_data_3rd_party_programs`
#
# Sample data are inserted in the table:
# - Record that must exist in the table `db_interfaces`
#   - field `interface_designation`, value 'sql_seed_script'.
# - Record that must exist in the table `statuses_3rd_party_program`
#   - field `3rd_party_program_status_id`, value 'Unknown'.
#   - field `3rd_party_program_status_id`, value 'LIVE'.
#

# Create the table `data_3rd_party_programs`
CREATE TABLE `data_3rd_party_programs` (
  `uuid` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The globally unique UUID for this record',
  `created_interface_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the interface sytem that was used to CREATE the record?',
  `created_by_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the user who created the record?',
  `created_by_ref_table` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the name of the table where we store user information?',
  `created_by_username_field` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the name of the field that stores the username associated to the userid?',
  `updated_interface_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the interface sytem that was used to UPDATE the record?',
  `updated_by_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the user who updated the record?',
  `updated_by_ref_table` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the name of the table where we store user information?',
  `updated_by_username_field` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the name of the field that stores the username associated to the userid?',
  `order` int(10) NOT NULL DEFAULT '0' COMMENT 'Order in the list',
  `3rd_party_program` varchar(50) COLLATE utf8mb4_unicode_520_ci  NOT NULL COMMENT 'Designation',
  `3rd_party_program_status_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'What is the status for this?',
  `3rd_party_program_description` text COLLATE utf8mb4_unicode_520_ci COMMENT 'Description/help text',
  PRIMARY KEY (`uuid`),
  UNIQUE KEY `unique_3rd_party_program_designation` (`3rd_party_program`) COMMENT 'The designation must be unique',
  KEY `3rd_party_program_created_interface_id` (`created_interface_id`),
  KEY `3rd_party_program_updated_interface_id` (`updated_interface_id`),
  KEY `3rd_party_program_3rd_party_program_status_id` (`3rd_party_program_status_id`),  
  CONSTRAINT `3rd_party_program_created_interface_id` FOREIGN KEY (`created_interface_id`) REFERENCES `db_interfaces` (`uuid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `3rd_party_program_updated_interface_id` FOREIGN KEY (`updated_interface_id`) REFERENCES `db_interfaces` (`uuid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `3rd_party_program_3rd_party_program_status_id` FOREIGN KEY (`3rd_party_program_status_id`) REFERENCES `statuses_3rd_party_program` (`uuid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC
;

# Make sure that a UUID is generated each time a new record is created in the table `data_3rd_party_programs`.
CREATE TRIGGER `uuid_data_3rd_party_programs`
  BEFORE INSERT ON `data_3rd_party_programs`
  FOR EACH ROW
  SET new.uuid = uuid()
;

# Create the table `logs_data_3rd_party_programs` to store the changes in the data
CREATE TABLE `logs_data_3rd_party_programs` (
  `action` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The action that was performed on the table',
  `action_datetime` TIMESTAMP NULL DEFAULT NULL COMMENT 'Timestamp - when was the operation done',
  `uuid` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The globally unique UUID for this record',
  `created_interface_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the interface sytem that was used to CREATE the record?',
  `created_by_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the user who created the record?',
  `created_by_ref_table` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the name of the table where we store user information?',
  `created_by_username_field` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the name of the field that stores the username associated to the userid?',
  `updated_interface_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the interface sytem that was used to UPDATE the record?',
  `updated_by_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the user who updated the record?',
  `updated_by_ref_table` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the name of the table where we store user information?',
  `updated_by_username_field` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the name of the field that stores the username associated to the userid?',
  `order` int(10) NOT NULL DEFAULT '0' COMMENT 'Order in the list',
  `3rd_party_program` varchar(50) COLLATE utf8mb4_unicode_520_ci  NOT NULL COMMENT 'Designation',
  `3rd_party_program_status_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the product Type for this Voucher Template?',
  `3rd_party_program_description` text COLLATE utf8mb4_unicode_520_ci COMMENT 'Description/help text',
  KEY `data_3rd_party_programs_uuid` (`uuid`) COMMENT 'Index the UUID for improved performances'
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC
;

# After a successful INSERT in the table `data_3rd_party_programs`
# Record all the data Inserted in the table `data_3rd_party_programs`
# The information will be stored in the table `logs_data_3rd_party_programs`

DELIMITER $$

CREATE TRIGGER `logs_data_3rd_party_programs_insert` AFTER INSERT ON `data_3rd_party_programs`
FOR EACH ROW
BEGIN
  INSERT INTO `logs_data_3rd_party_programs` (
    `action`, 
    `action_datetime`, 
    `uuid`, 
    `created_interface_id`,
    `created_by_id`,
    `created_by_ref_table`,
    `created_by_username_field`,
    `updated_interface_id`, 
    `updated_by_id`,
    `updated_by_ref_table`,
    `updated_by_username_field`,
    `order`, 
    `3rd_party_program`,
    `3rd_party_program_status_id`,
    `3rd_party_program_description`
    )
  VALUES
    ('INSERT', 
      NOW(), 
      NEW.`uuid`, 
      NEW.`created_interface_id`,
      NEW.`created_by_id`,
      NEW.`created_by_ref_table`,
      NEW.`created_by_username_field`,
      NEW.`updated_interface_id`, 
      NEW.`updated_by_id`,
      NEW.`updated_by_ref_table`,
      NEW.`updated_by_username_field`, 
      NEW.`order`, 
      NEW.`3rd_party_program`, 
      NEW.`3rd_party_program_status_id`, 
      NEW.`3rd_party_program_description`
    )
  ;
END
$$

DELIMITER ;

# After a successful UPDATE in the table `data_3rd_party_programs`
# Record all the values for the old record
# Record all the values for the new record
# data Inserted in the table `data_3rd_party_programs`
# The information will be stored in the table `logs_data_3rd_party_programs`

DELIMITER $$

CREATE TRIGGER `logs_data_3rd_party_programs_update` AFTER UPDATE ON `data_3rd_party_programs`
FOR EACH ROW
BEGIN
  INSERT INTO `logs_data_3rd_party_programs` (
    `action`, 
    `action_datetime`, 
    `uuid`,  
    `created_interface_id`,
    `created_by_id`,
    `created_by_ref_table`,
    `created_by_username_field`,
    `updated_interface_id`, 
    `updated_by_id`,
    `updated_by_ref_table`,
    `updated_by_username_field`,
    `order`, 
    `3rd_party_program`,
    `3rd_party_program_status_id`, 
    `3rd_party_program_description`
    )
    VALUES
      ('UPDATE-OLD_VALUES', 
        NOW(), 
        OLD.`uuid`, 
        OLD.`created_interface_id`,
        OLD.`created_by_id`,
        OLD.`created_by_ref_table`,
        OLD.`created_by_username_field`,
        OLD.`updated_interface_id`, 
        OLD.`updated_by_id`,
        OLD.`updated_by_ref_table`,
        OLD.`updated_by_username_field`, 
        OLD.`order`, 
        OLD.`3rd_party_program`, 
        OLD.`3rd_party_program_status_id`, 
        OLD.`3rd_party_program_description`
      ),  
      ('UPDATE-NEW_VALUES', 
        NOW(), 
        NEW.`uuid`, 
        NEW.`created_interface_id`,
        NEW.`created_by_id`,
        NEW.`created_by_ref_table`,
        NEW.`created_by_username_field`,
        NEW.`updated_interface_id`, 
        NEW.`updated_by_id`,
        NEW.`updated_by_ref_table`,
        NEW.`updated_by_username_field`, 
        NEW.`order`, 
        NEW.`3rd_party_program`, 
        NEW.`3rd_party_program_status_id`, 
        NEW.`3rd_party_program_description`
      )
  ;
END
$$

DELIMITER ;

# After a successful DELETE in the table `data_3rd_party_programs`
# Record all the values for the old record
# The information will be stored in the table `logs_data_3rd_party_programs`

DELIMITER $$

CREATE TRIGGER `logs_data_3rd_party_programs_delete` AFTER DELETE ON `data_3rd_party_programs`
FOR EACH ROW
BEGIN
  INSERT INTO `logs_data_3rd_party_programs` (
    `action`, 
    `action_datetime`, 
    `uuid`, 
    `created_interface_id`,
    `created_by_id`,
    `created_by_ref_table`,
    `created_by_username_field`,
    `updated_interface_id`, 
    `updated_by_id`,
    `updated_by_ref_table`,
    `updated_by_username_field`,
    `order`, 
    `3rd_party_program`,
    `3rd_party_program_status_id`, 
    `3rd_party_program_description`
    )
    VALUES
      ('DELETE', 
        NOW(), 
        OLD.`uuid`, 
        OLD.`created_interface_id`,
        OLD.`created_by_id`,
        OLD.`created_by_ref_table`,
        OLD.`created_by_username_field`,
        OLD.`updated_interface_id`, 
        OLD.`updated_by_id`,
        OLD.`updated_by_ref_table`,
        OLD.`updated_by_username_field`, 
        OLD.`order`, 
        OLD.`3rd_party_program`, 
        OLD.`3rd_party_program_status_id`, 
        OLD.`3rd_party_program_description`
      )
  ;
END
$$

DELIMITER ;

# We need to get the uuid for the value `sql_seed_script` in the table `db_interfaces`
# We put this into the variable [@UUID_sql_seed_script]
SELECT `uuid`
    INTO @UUID_sql_seed_script
FROM `db_interfaces`
    WHERE `interface` = 'sql_seed_script'
;

# We need to get the uuid for the value 'UNKNOWN' in the table `statuses_3rd_party_program`
# We put this into the variable [@UUID_UNKNOWN_3rd_party_program_status]
SELECT `uuid`
    INTO @UUID_UNKNOWN_3rd_party_program_status
FROM `statuses_3rd_party_program`
    WHERE `3rd_party_program_status` = 'UNKNOWN'
;

# We need to get the uuid for the value 'LIVE' in the table `statuses_3rd_party_program`
# We put this into the variable [@UUID_LIVE_3rd_party_program_status]
SELECT `uuid`
    INTO @UUID_LIVE_3rd_party_program_status
FROM `statuses_3rd_party_program`
    WHERE `3rd_party_program_status` = 'LIVE'
;

# We use default values for creation of the seed data
SELECT 'db.user.running.sql.seed.script' INTO @created_by_id;
SELECT '---' INTO @created_by_ref_table;
SELECT '---' INTO @created_by_username_field;

# Insert sample values in the table
INSERT  INTO `data_3rd_party_programs`(
    `created_interface_id`,
    `created_by_id`,
    `created_by_ref_table`,
    `created_by_username_field`,
    `order`, 
    `3rd_party_program`,
    `3rd_party_program_status_id`, 
    `3rd_party_program_description`
    ) 
    VALUES 
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 0, 'Unknown', @UUID_UNKNOWN_3rd_party_program_status, 'We have no information'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'Dairy Farm Group', @UUID_LIVE_3rd_party_program_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 20, 'FairPrice Online', @UUID_LIVE_3rd_party_program_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 30, 'UNIQGIFT Voucher', @UUID_LIVE_3rd_party_program_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 40, 'Polar Puffs & Cakes', @UUID_LIVE_3rd_party_program_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 50, 'Lazada', @UUID_LIVE_3rd_party_program_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 60, 'Golden Village', @UUID_LIVE_3rd_party_program_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 70, 'Deliveroo', @UUID_LIVE_3rd_party_program_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 80, 'Honestbee', @UUID_LIVE_3rd_party_program_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 90, 'Redmart', @UUID_LIVE_3rd_party_program_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 100, 'Agoda', @UUID_LIVE_3rd_party_program_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 110, 'MHR', @UUID_LIVE_3rd_party_program_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 120, 'New Moon', @UUID_LIVE_3rd_party_program_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 130, 'Sephora', @UUID_LIVE_3rd_party_program_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 140, 'Ad-hoc', @UUID_LIVE_3rd_party_program_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 150, 'Apple', @UUID_LIVE_3rd_party_program_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 160, 'Klook', @UUID_LIVE_3rd_party_program_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 170, 'Gojek', @UUID_LIVE_3rd_party_program_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 180, 'n/a', @UUID_LIVE_3rd_party_program_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 1000, 'Other - UNKNOWN', @UUID_UNKNOWN_3rd_party_program_status, 'This is none of the above.'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 1010, 'Other - LIVE', @UUID_LIVE_3rd_party_program_status, 'This is none of the above.')
;