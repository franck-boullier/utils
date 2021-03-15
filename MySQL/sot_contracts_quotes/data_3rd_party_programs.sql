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
# - The status name must be unique.
# - The Interface to create the record MUST exist in the table `db_interfaces`
# - The Interface to update the record MUST exist in the table `db_interfaces`
# - The `3rd_party_program_status` record MUST exist in the the table `list_3rd_party_program_statuses`.
#
# Automations and Triggers:
# - The UUID for a new record is automatically generated.
# - Logs of each changes in this table are recorded in the table `logs_data_3rd_party_programs`
#
# Sample data are inserted in the table:
#   - The table `db_interfaces` must exist in your database.
#   - A record with a value 'sql_seed_script' for the field `interface_designation` must exist in the  table `db_interfaces`.
#

# Create the table `data_3rd_party_programs`
CREATE TABLE `data_3rd_party_programs` (
  `uuid` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The globally unique UUID for this record',
  `interface_id_creation` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the interface sytem that was used to CREATE the record?',
  `interface_id_update` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the interface sytem that was used to UPDATE the record?',
  `order` int(10) NOT NULL DEFAULT '0' COMMENT 'Order in the list',
  `3rd_party_program` varchar(50) COLLATE utf8mb4_unicode_520_ci  NOT NULL COMMENT 'Designation',
  `3rd_party_program_status_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'What is the status for this?',
  `3rd_party_program_description` text COLLATE utf8mb4_unicode_520_ci COMMENT 'Description/help text',
  PRIMARY KEY (`uuid`,`3rd_party_program`),
  KEY `3rd_party_program_interface_id_creation` (`interface_id_creation`),
  KEY `3rd_party_program_interface_id_update` (`interface_id_update`),
  KEY `3rd_party_program_3rd_party_program_status_id` (`3rd_party_program_status_id`),  
  CONSTRAINT `3rd_party_program_interface_id_creation` FOREIGN KEY (`interface_id_creation`) REFERENCES `db_interfaces` (`uuid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `3rd_party_program_interface_id_update` FOREIGN KEY (`interface_id_update`) REFERENCES `db_interfaces` (`uuid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `3rd_party_program_3rd_party_program_status_id` FOREIGN KEY (`3rd_party_program_status_id`) REFERENCES `list_3rd_party_program_statuses` (`uuid`) ON DELETE CASCADE ON UPDATE CASCADE
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
  `interface_id_creation` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the interface sytem that was used to CREATE the record?',
  `interface_id_update` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the interface sytem that was used to UPDATE the record?',
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
    `interface_id_creation`, 
    `interface_id_update`, 
    `order`, 
    `3rd_party_program`,
    `3rd_party_program_status_id`,
    `3rd_party_program_description`
    )
  VALUES('INSERT', NOW(), NEW.`uuid`, NEW.`interface_id_creation`, NEW.`interface_id_update`, NEW.`order`, NEW.`3rd_party_program`, NEW.`3rd_party_program_status_id`, NEW.`3rd_party_program_description`)
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
    `interface_id_creation`, 
    `interface_id_update`, 
    `order`, 
    `3rd_party_program`,
    `3rd_party_program_status_id`, 
    `3rd_party_program_description`
    )
    VALUES
    ('UPDATE-OLD_VALUES', NOW(), OLD.`uuid`, OLD.`interface_id_creation`, OLD.`interface_id_update`, OLD.`order`, OLD.`3rd_party_program`, OLD.`3rd_party_program_status_id`, OLD.`3rd_party_program_description`),
    ('UPDATE-NEW_VALUES', NOW(), NEW.`uuid`, NEW.`interface_id_creation`, NEW.`interface_id_update`, NEW.`order`, NEW.`3rd_party_program`, NEW.`3rd_party_program_status_id`, NEW.`3rd_party_program_description`)
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
    `interface_id_creation`, 
    `interface_id_update`, 
    `order`, 
    `3rd_party_program`,
    `3rd_party_program_status_id`, 
    `3rd_party_program_description`
    )
    VALUES
    ('DELETE', NOW(), OLD.`uuid`, OLD.`interface_id_creation`, OLD.`interface_id_update`, OLD.`order`, OLD.`3rd_party_program`, OLD.`3rd_party_program_status_id`, OLD.`3rd_party_program_description`)
  ;
END
$$

DELIMITER ;

# We need to get the uuid for the value `sql_seed_script` in the table `db_interfaces`
# We put this into the variable [@UUID_sql_seed_script]
SELECT `uuid`
    INTO @UUID_sql_seed_script
FROM `db_interfaces`
    WHERE `interface_designation` = 'sql_seed_script'
;

# We need to get the uuid for the value 'UNKNOWN' in the table `list_3rd_party_program_statuses`
# We put this into the variable [@UUID_UNKNOWN_3rd_party_program_status]
SELECT `uuid`
    INTO @UUID_UNKNOWN_3rd_party_program_status
FROM `list_3rd_party_program_statuses`
    WHERE `3rd_party_program_status` = 'UNKNOWN'
;

# We need to get the uuid for the value 'ACTIVE' in the table `list_3rd_party_program_statuss`
# We put this into the variable [@UUID_ACTIVE_3rd_party_program_status]
SELECT `uuid`
    INTO @UUID_ACTIVE_3rd_party_program_status
FROM `list_3rd_party_program_statuses`
    WHERE `3rd_party_program_status` = 'ACTIVE'
;

# Insert sample values in the table
INSERT  INTO `data_3rd_party_programs`(
    `interface_id_creation`, 
    `order`, 
    `3rd_party_program`,
    `3rd_party_program_status_id`, 
    `3rd_party_program_description`
    ) 
    VALUES 
        (@UUID_sql_seed_script, 0, 'Unknown', @UUID_UNKNOWN_3rd_party_program_status, 'We have no information'),
        (@UUID_sql_seed_script, 10, 'Dairy Farm Group', @UUID_ACTIVE_3rd_party_program_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, 20, 'FairPrice Online', @UUID_ACTIVE_3rd_party_program_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, 30, 'UNIQGIFT Voucher', @UUID_ACTIVE_3rd_party_program_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, 40, 'Polar Puffs & Cakes', @UUID_ACTIVE_3rd_party_program_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, 50, 'Lazada', @UUID_ACTIVE_3rd_party_program_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, 60, 'Golden Village', @UUID_ACTIVE_3rd_party_program_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, 70, 'Deliveroo', @UUID_ACTIVE_3rd_party_program_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, 80, 'Honestbee', @UUID_ACTIVE_3rd_party_program_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, 90, 'Redmart', @UUID_ACTIVE_3rd_party_program_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, 100, 'Agoda', @UUID_ACTIVE_3rd_party_program_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, 110, 'MHR', @UUID_ACTIVE_3rd_party_program_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, 120, 'New Moon', @UUID_ACTIVE_3rd_party_program_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, 130, 'Sephora', @UUID_ACTIVE_3rd_party_program_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, 140, 'Ad-hoc', @UUID_ACTIVE_3rd_party_program_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, 150, 'Apple', @UUID_ACTIVE_3rd_party_program_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, 160, 'Klook', @UUID_ACTIVE_3rd_party_program_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, 170, 'Gojek', @UUID_ACTIVE_3rd_party_program_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, 180, 'n/a', @UUID_ACTIVE_3rd_party_program_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, 1000, 'Other - UNKNOWN', @UUID_UNKNOWN_3rd_party_program_status, 'This is none of the above.'),
        (@UUID_sql_seed_script, 1010, 'Other - ACTIVE', @UUID_ACTIVE_3rd_party_program_status, 'This is none of the above.')
;