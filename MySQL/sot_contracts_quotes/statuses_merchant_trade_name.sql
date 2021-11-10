# What this script will do:
#
# - Create a table `statuses_merchant_trade_name` to list the possible statutes for a record.
# - Create a trigger `uuid_statuses_merchant_trade_name` to automatically generate the UUID for a new record.
# - Create a table `logs_statuses_merchant_trade_name` to log all the changes in the table.
# - Create a trigger `logs_statuses_merchant_trade_name_insert` to automatically log INSERT operations on the table `statuses_merchant_trade_name`.
# - Create a trigger `logs_statuses_merchant_trade_name_update` to automatically log UPDATE operations on the table `statuses_merchant_trade_name`.
# - Create a trigger `logs_statuses_merchant_trade_name_delete` to automatically log DELETE operations on the table `statuses_merchant_trade_name`.
# - Insert some sample data in the table `statuses_merchant_trade_name`.
# 
# Constaints:
# - The status name must be unique.
# - The Interface to create the record MUST exist in the table `db_interfaces`
# - The Interface to update the record MUST exist in the table `db_interfaces`
#
# Automations and Triggers:
# - The UUID for a new record is automatically generated.
# - Logs of each changes in this table are recorded in the table `logs_statuses_merchant_trade_name`
#
# Sample data are inserted in the table:
# - Record that must exist in the table `db_interfaces`
#   - field `interface`, value 'sql_seed_script'.
#

# Create the table `statuses_merchant_trade_name`
CREATE TABLE `statuses_merchant_trade_name` (
  `uuid` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The globally unique UUID for this record',
  `interface_id_creation` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the interface sytem that was used to CREATE the record?',
  `interface_id_update` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the interface sytem that was used to UPDATE the record?',
  `is_obsolete` tinyint(1) DEFAULT '0' COMMENT 'is this obsolete?',
  `order` int(10) NOT NULL DEFAULT '0' COMMENT 'Order in the list',
  `is_active` tinyint(1) DEFAULT '0' COMMENT 'This satus is considered as ACTIVE',
  `merchant_trade_name_status` varchar(50) COLLATE utf8mb4_unicode_520_ci  NOT NULL COMMENT 'Designation',
  `merchant_trade_name_status_description` text COLLATE utf8mb4_unicode_520_ci COMMENT 'Description/help text',
  PRIMARY KEY (`uuid`),
  UNIQUE KEY `unique_merchant_trade_name_status_designation` (`merchant_trade_name_status`) COMMENT 'The designation must be unique',
  KEY `merchant_trade_name_status_interface_id_creation` (`interface_id_creation`),
  KEY `merchant_trade_name_status_interface_id_update` (`interface_id_update`),
  CONSTRAINT `merchant_trade_name_status_interface_id_creation` FOREIGN KEY (`interface_id_creation`) REFERENCES `db_interfaces` (`uuid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `merchant_trade_name_status_interface_id_update` FOREIGN KEY (`interface_id_update`) REFERENCES `db_interfaces` (`uuid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC
;

# Make sure that a UUID is generated each time a new record is created in the table `statuses_merchant_trade_name`.
CREATE TRIGGER `uuid_statuses_merchant_trade_name`
  BEFORE INSERT ON `statuses_merchant_trade_name`
  FOR EACH ROW
  SET new.uuid = uuid()
;

# Create the table `logs_statuses_merchant_trade_name` to store the changes in the data
CREATE TABLE `logs_statuses_merchant_trade_name` (
  `action` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The action that was performed on the table',
  `action_datetime` TIMESTAMP NULL DEFAULT NULL COMMENT 'Timestamp - when was the operation done',
  `uuid` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The globally unique UUID for this record',
  `interface_id_creation` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the interface sytem that was used to CREATE the record?',
  `interface_id_update` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the interface sytem that was used to UPDATE the record?',
  `is_obsolete` tinyint(1) DEFAULT '0' COMMENT 'is this obsolete?',
  `order` int(10) NOT NULL DEFAULT '0' COMMENT 'Order in the list',
  `is_active` tinyint(1) DEFAULT '0' COMMENT 'This satus is considered as ACTIVE',
  `merchant_trade_name_status` varchar(50) COLLATE utf8mb4_unicode_520_ci  NOT NULL COMMENT 'Designation',
  `merchant_trade_name_status_description` text COLLATE utf8mb4_unicode_520_ci COMMENT 'Description/help text',
  KEY `statuses_merchant_trade_name_uuid` (`uuid`) COMMENT 'Index the UUID for improved performances'
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC
;

# After a successful INSERT in the table `statuses_merchant_trade_name`
# Record all the data Inserted in the table `statuses_merchant_trade_name`
# The information will be stored in the table `logs_statuses_merchant_trade_name`

DELIMITER $$

CREATE TRIGGER `logs_statuses_merchant_trade_name_insert` AFTER INSERT ON `statuses_merchant_trade_name`
FOR EACH ROW
BEGIN
  INSERT INTO `logs_statuses_merchant_trade_name` (
    `action`, 
    `action_datetime`, 
    `uuid`, 
    `interface_id_creation`, 
    `interface_id_update`, 
    `is_obsolete`, 
    `order`, 
    `is_active`, 
    `merchant_trade_name_status`, 
    `merchant_trade_name_status_description`
    )
  VALUES
    ('INSERT', 
      NOW(), 
      NEW.`uuid`, 
      NEW.`interface_id_creation`, 
      NEW.`interface_id_update`, 
      NEW.`is_obsolete`, 
      NEW.`order`, 
      NEW.`is_active`, 
      NEW.`merchant_trade_name_status`, 
      NEW.`merchant_trade_name_status_description`
    )
  ;
END
$$

DELIMITER ;

# After a successful UPDATE in the table `statuses_merchant_trade_name`
# Record all the values for the old record
# Record all the values for the new record
# data Inserted in the table `statuses_merchant_trade_name`
# The information will be stored in the table `logs_statuses_merchant_trade_name`

DELIMITER $$

CREATE TRIGGER `logs_statuses_merchant_trade_name_update` AFTER UPDATE ON `statuses_merchant_trade_name`
FOR EACH ROW
BEGIN
  INSERT INTO `logs_statuses_merchant_trade_name` (
    `action`, 
    `action_datetime`, 
    `uuid`,  
    `interface_id_creation`, 
    `interface_id_update`, 
    `is_obsolete`, 
    `order`, 
    `is_active`, 
    `merchant_trade_name_status`, 
    `merchant_trade_name_status_description`
    )
    VALUES
      ('UPDATE-OLD_VALUES', 
        NOW(), 
        OLD.`uuid`, 
        OLD.`interface_id_creation`, 
        OLD.`interface_id_update`, 
        OLD.`is_obsolete`, 
        OLD.`order`, 
        OLD.`is_active`, 
        OLD.`merchant_trade_name_status`, 
        OLD.`merchant_trade_name_status_description`
      ),
      ('UPDATE-NEW_VALUES', 
        NOW(), 
        NEW.`uuid`, 
        NEW.`interface_id_creation`, 
        NEW.`interface_id_update`, 
        NEW.`is_obsolete`, 
        NEW.`order`, 
        NEW.`is_active`, 
        NEW.`merchant_trade_name_status`, 
        NEW.`merchant_trade_name_status_description`
      )
  ;
END
$$

DELIMITER ;

# After a successful DELETE in the table `statuses_merchant_trade_name`
# Record all the values for the old record
# The information will be stored in the table `logs_statuses_merchant_trade_name`

DELIMITER $$

CREATE TRIGGER `logs_statuses_merchant_trade_name_delete` AFTER DELETE ON `statuses_merchant_trade_name`
FOR EACH ROW
BEGIN
  INSERT INTO `logs_statuses_merchant_trade_name` (
    `action`, 
    `action_datetime`, 
    `uuid`, 
    `interface_id_creation`, 
    `interface_id_update`, 
    `is_obsolete`, 
    `order`, 
    `is_active`, 
    `merchant_trade_name_status`, 
    `merchant_trade_name_status_description`
    )
    VALUES
      ('DELETE', 
          NOW(), 
          OLD.`uuid`, 
          OLD.`interface_id_creation`, 
          OLD.`interface_id_update`, 
          OLD.`is_obsolete`, 
          OLD.`order`, 
          OLD.`is_active`, 
          OLD.`merchant_trade_name_status`, 
          OLD.`merchant_trade_name_status_description`
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

# Insert sample values in the table
INSERT  INTO `statuses_merchant_trade_name`(
    `interface_id_creation`, 
    `is_obsolete`, 
    `order`, 
    `is_active`, 
    `merchant_trade_name_status`, 
    `merchant_trade_name_status_description`
    ) 
    VALUES 
        (@UUID_sql_seed_script, 0, 0, 0, 'UNKNOWN','We have no information about the merchant status. This is an INACTIVE Status'),
        (@UUID_sql_seed_script, 0, 0, 0, 'PROSPECT','The contract has NOT been signed. This is an INACTIVE Status'),
        (@UUID_sql_seed_script, 0, 0, 1, 'CONTRACT_SIGNED','The data has been sent. This is an ACTIVE Status'),
        (@UUID_sql_seed_script, 0, 0, 1, 'PENDING_ONBOARDING','We have NOT trained the merchant or performed On-Boarding activities yet. This is an ACTIVE Status'),
        (@UUID_sql_seed_script, 0, 0, 1, 'LIVE','The merchant is accepting our products. This is an ACTIVE Status'),
        (@UUID_sql_seed_script, 0, 0, 1, 'SUNSET','The merchant is accepting our products but we should NOT create new product for this merchant. This is an INACTIVE Status'),
        (@UUID_sql_seed_script, 0, 0, 0, 'INACTIVE','The merchant is inactive. This is an INACTIVE Status'),
        (@UUID_sql_seed_script, 0, 0, 0, 'TERMINATED','The contract with the merchant has been terminated. This is an INACTIVE Status'),
        (@UUID_sql_seed_script, 0, 0, 0, 'DUPLICATE','This is a duplicate of an existing record. This is an INACTIVE Status'),
        (@UUID_sql_seed_script, 0, 0, 0, 'LOST','We have lost that opportunity. This is an INACTIVE Status')
;