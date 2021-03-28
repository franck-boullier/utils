# What this script will do:
#
# - Create a table `data_sales_rep` to list the possible statutes for a record.
# - Create a trigger `uuid_data_sales_rep` to automatically generate the UUID for a new record.
# - Create a table `logs_data_sales_rep` to log all the changes in the table.
# - Create a trigger `logs_data_sales_rep_insert` to automatically log INSERT operations on the table `data_sales_rep`.
# - Create a trigger `logs_data_sales_rep_update` to automatically log UPDATE operations on the table `data_sales_rep`.
# - Create a trigger `logs_data_sales_rep_delete` to automatically log DELETE operations on the table `data_sales_rep`.
# - Insert some sample data in the table `data_sales_rep`.
# 
# Constaints:
# - The designation must be unique.
# - The Interface to create the record MUST exist in the table `db_interfaces`
# - The Interface to update the record MUST exist in the table `db_interfaces`
# - The `sales_rep_status` record MUST exist in the the table `statuses_sales_rep`.
#
# Automations and Triggers:
# - The UUID for a new record is automatically generated.
# - Logs of each changes in this table are recorded in the table `logs_data_sales_rep`
#
# Sample data are inserted in the table:
# - Record that must exist in the table `db_interfaces`
#   - field `interface_designation`, value 'sql_seed_script'.
# - Record that must exist in the table `statuses_sales_rep`
#   - field `sales_rep_status`, value 'Unknown'.
#   - field `sales_rep_status`, value 'ACTIVE'.
#

# Create the table `data_sales_rep`
CREATE TABLE `data_sales_rep` (
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
  `sales_rep` varchar(50) COLLATE utf8mb4_unicode_520_ci  NOT NULL COMMENT 'Designation',
  `sales_rep_status_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'What is the status for this?',
  `sales_rep_external_uuid` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'a unique ID for the Sales Rep',
  `sales_rep_id_record_system` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The system of record where we can get more information on the Sales Rep',
  `sales_rep_description` text COLLATE utf8mb4_unicode_520_ci COMMENT 'Description/help text',
  PRIMARY KEY (`uuid`),
  UNIQUE KEY `unique_sales_rep_designation` (`sales_rep`) COMMENT 'The designation must be unique',
  UNIQUE KEY `unique_sales_rep_sales_rep_external_uuid` (`sales_rep_external_uuid`) COMMENT 'Add index for uniqueness and performance',
  KEY `sales_rep_created_interface_id` (`created_interface_id`),
  KEY `sales_rep_updated_interface_id` (`updated_interface_id`),
  KEY `sales_rep_sales_rep_status_id` (`sales_rep_status_id`),  
  CONSTRAINT `sales_rep_created_interface_id` FOREIGN KEY (`created_interface_id`) REFERENCES `db_interfaces` (`uuid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sales_rep_updated_interface_id` FOREIGN KEY (`updated_interface_id`) REFERENCES `db_interfaces` (`uuid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sales_rep_sales_rep_status_id` FOREIGN KEY (`sales_rep_status_id`) REFERENCES `statuses_sales_rep` (`uuid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC
;

# Make sure that a UUID is generated each time a new record is created in the table `data_sales_rep`.
CREATE TRIGGER `uuid_data_sales_rep`
  BEFORE INSERT ON `data_sales_rep`
  FOR EACH ROW
  SET new.uuid = uuid()
;

# Create the table `logs_data_sales_rep` to store the changes in the data
# We first drop the table in case is exists

CREATE TABLE `logs_data_sales_rep` (
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
  `sales_rep` varchar(50) COLLATE utf8mb4_unicode_520_ci  NOT NULL COMMENT 'Designation',
  `sales_rep_status_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'What is the status for this?',
  `sales_rep_external_uuid` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'a unique ID for the Sales Rep',
  `sales_rep_id_record_system` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The system of record where we can get more information on the Sales Rep',
  `sales_rep_description` text COLLATE utf8mb4_unicode_520_ci COMMENT 'Description/help text',
  KEY `data_sales_rep_uuid` (`uuid`) COMMENT 'Index the UUID for improved performances'
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC
;

# After a successful INSERT in the table `data_sales_rep`
# Record all the data Inserted in the table `data_sales_rep`
# The information will be stored in the table `logs_data_sales_rep`

DELIMITER $$

CREATE TRIGGER `logs_data_sales_rep_insert` AFTER INSERT ON `data_sales_rep`
FOR EACH ROW
BEGIN
  INSERT INTO `logs_data_sales_rep` (
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
    `sales_rep`,
    `sales_rep_status_id`,
    `sales_rep_external_uuid`,
    `sales_rep_id_record_system`,
    `sales_rep_description`
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
      NEW.`sales_rep`, 
      NEW.`sales_rep_status_id`, 
      NEW.`sales_rep_external_uuid`,
      NEW.`sales_rep_id_record_system`, 
      NEW.`sales_rep_description`
    )
  ;
END
$$

DELIMITER ;

# After a successful UPDATE in the table `data_sales_rep`
# Record all the values for the old record
# Record all the values for the new record
# data Inserted in the table `data_sales_rep`
# The information will be stored in the table `logs_data_sales_rep`

DELIMITER $$

CREATE TRIGGER `logs_data_sales_rep_update` AFTER UPDATE ON `data_sales_rep`
FOR EACH ROW
BEGIN
  INSERT INTO `logs_data_sales_rep` (
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
    `sales_rep`,
    `sales_rep_status_id`,
    `sales_rep_external_uuid`,
    `sales_rep_id_record_system`,
    `sales_rep_description`
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
        OLD.`sales_rep`,  
        OLD.`sales_rep_status_id`,
        OLD.`sales_rep_external_uuid`,
        OLD.`sales_rep_id_record_system`, 
        OLD.`sales_rep_description`
      ),
      ('UPDATE-NEW_VALUES', 
        NOW(), 
        NEW.`uuid`, 
        NEW.`created_by_id`,
        NEW.`created_by_ref_table`,
        NEW.`created_by_username_field`,
        NEW.`updated_interface_id`, 
        NEW.`updated_by_id`,
        NEW.`updated_by_ref_table`,
        NEW.`updated_by_username_field`, 
        NEW.`order`, 
        NEW.`sales_rep`, 
        NEW.`sales_rep_status_id`,
        NEW.`sales_rep_external_uuid`,
        NEW.`sales_rep_id_record_system`, 
        NEW.`sales_rep_description`
      )
  ;
END
$$

DELIMITER ;

# After a successful DELETE in the table `data_sales_rep`
# Record all the values for the old record
# The information will be stored in the table `logs_data_sales_rep`

DELIMITER $$

CREATE TRIGGER `logs_data_sales_rep_delete` AFTER DELETE ON `data_sales_rep`
FOR EACH ROW
BEGIN
  INSERT INTO `logs_data_sales_rep` (
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
    `sales_rep`,
    `sales_rep_status_id`,
    `sales_rep_external_uuid`,
    `sales_rep_id_record_system`, 
    `sales_rep_description`
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
        OLD.`sales_rep`,  
        OLD.`sales_rep_status_id`,
        OLD.`sales_rep_external_uuid`,
        OLD.`sales_rep_id_record_system`, 
        OLD.`sales_rep_description`
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

# We need to get the uuid for the value 'UNKNOWN' in the table `statuses_sales_rep`
# We put this into the variable [@UUID_UNKNOWN_sales_rep_status]
SELECT `uuid`
    INTO @UUID_UNKNOWN_sales_rep_status
FROM `statuses_sales_rep`
    WHERE `sales_rep_status` = 'UNKNOWN'
;

# We need to get the uuid for the value 'ACTIVE' in the table `statuses_sales_rep`
# We put this into the variable [@UUID_ACTIVE_sales_rep_status]
SELECT `uuid`
    INTO @UUID_ACTIVE_sales_rep_status
FROM `statuses_sales_rep`
    WHERE `sales_rep_status` = 'ACTIVE'
;

# We use default values for creation of the seed data
SELECT 'db.user.running.sql.seed.script' INTO @created_by_id;
SELECT '---' INTO @created_by_ref_table;
SELECT '---' INTO @created_by_username_field;

# Insert sample values in the table
INSERT  INTO `data_sales_rep`(
    `created_interface_id`,
    `created_by_id`,
    `created_by_ref_table`,
    `created_by_username_field`,
    `order`,
    `sales_rep`,
    `sales_rep_status_id`
    ) 
    VALUES 
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 0, 'Unknown', @UUID_ACTIVE_sales_rep_status),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'Sales Rep 1', @UUID_ACTIVE_sales_rep_status),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 20, 'Sales Rep 3', @UUID_ACTIVE_sales_rep_status),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 30, 'Sales Rep 4', @UUID_ACTIVE_sales_rep_status)
;