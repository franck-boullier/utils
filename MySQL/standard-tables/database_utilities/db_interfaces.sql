# What this script will do:
#
# - Create a table `db_interfaces` to list the interfaces that are allowed to interact and connect with this database.
# - Create a trigger `uuid_db_interfaces` to automatically generate the UUID for a new record.
# - Create a table `logs_db_interfaces` to log all the changes in the table.
# - Create a trigger `logs_db_interfaces_insert` to automatically log INSERT operations on the table `db_interfaces`.
# - Create a trigger `logs_db_interfaces_update` to automatically log UPDATE operations on the table `db_interfaces`.
# - Create a trigger `logs_db_interfaces_delete` to automatically log DELETE operations on the table `db_interfaces`.
# - Insert some sample data in the table `db_interfaces`.
# 
# Constaints:
# - The interface name must be unique.
#
# Automations and Triggers:
# - The UUID for a new record is automatically generated.
# - Logs of each changes in this table are recorded in the table `logs_db_interfaces`
#

# Create the table `db_interfaces`
CREATE TABLE `db_interfaces` (
  `uuid` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The globally unique UUID for this record',
  `is_obsolete` tinyint(1) DEFAULT '0' COMMENT 'is this obsolete?',
  `order` int(10) NOT NULL DEFAULT '0' COMMENT 'Order in the list',
  `interface` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'Designation',
  `db_user_name` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The database user that this interface is using',
  `interface_description` text COLLATE utf8mb4_unicode_520_ci COMMENT 'Description/help text)',
  PRIMARY KEY (`uuid`),
  UNIQUE KEY `unique_interface_designation` (`interface`) COMMENT 'The designation must be unique'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC
;

# Make sure that a UUID is generated each time a new record is created in the table `db_interfaces`.
CREATE TRIGGER `uuid_db_interfaces`
  BEFORE INSERT ON `db_interfaces`
  FOR EACH ROW
  SET new.uuid = uuid()
;

# Create the table `logs_db_interfaces` to store the changes in the data
CREATE TABLE `logs_db_interfaces` (
  `action` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The action that was performed on the table',
  `action_datetime` TIMESTAMP NULL DEFAULT NULL COMMENT 'Timestamp - when was the operation done',
  `uuid` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The globally unique UUID for this record',
  `is_obsolete` tinyint(1) DEFAULT '0' COMMENT 'is this obsolete?',
  `order` int(10) NOT NULL DEFAULT '0' COMMENT 'Order in the list',
  `interface` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'Designation',
  `db_user_name` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The database user that this interface is using',
  `interface_description` text COLLATE utf8mb4_unicode_520_ci COMMENT 'Description/help text)',
  KEY `db_interfaces_uuid` (`uuid`) COMMENT 'Index the UUID for improved performances'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC
;

# After a successful INSERT in the table `db_interfaces`
# Record all the data Inserted in the table `db_interfaces`
# The information will be stored in the table `logs_db_interfaces`

DELIMITER $$

CREATE TRIGGER `logs_db_interfaces_insert` AFTER INSERT ON `db_interfaces`
FOR EACH ROW
BEGIN
  INSERT INTO `logs_db_interfaces` (
    `action`, 
    `action_datetime`, 
    `uuid`, 
    `is_obsolete`, 
    `order`, 
    `interface`,
    `db_user_name`,  
    `interface_description`
    )
  VALUES
    ('INSERT', 
      NOW(), 
      NEW.`uuid`, 
      NEW.`is_obsolete`,
      NEW.`order`,
      NEW.`interface`,
      NEW.`db_user_name`,
      NEW.`interface_description`
      )
  ;
END
$$

DELIMITER ;

# After a successful UPDATE in the table `db_interfaces`
# Record all the values for the old record
# Record all the values for the new record
# data Inserted in the table `db_interfaces`
# The information will be stored in the table `logs_db_interfaces`

DELIMITER $$

CREATE TRIGGER `logs_db_interfaces_update` AFTER UPDATE ON `db_interfaces`
FOR EACH ROW
BEGIN
  INSERT INTO `logs_db_interfaces` (
    `action`, 
    `action_datetime`, 
    `uuid`, 
    `is_obsolete`, 
    `order`, 
    `interface`, 
    `db_user_name`,  
    `interface_description`
    )
    VALUES
      ('UPDATE-OLD_VALUES', 
        NOW(), 
        OLD.`uuid`, 
        OLD.`is_obsolete`,
        OLD.`order`,
        OLD.`interface`,
        OLD.`db_user_name`,
        OLD.`interface_description`
        ),
      ('UPDATE-NEW_VALUES', 
        NOW(), 
        NEW.`uuid`, 
        NEW.`is_obsolete`,
        NEW.`order`,
        NEW.`interface`,
        NEW.`db_user_name`,
        NEW.`interface_description`
        )
  ;
END
$$

DELIMITER ;

# After a successful DELETE in the table `db_interfaces`
# Record all the values for the old record
# The information will be stored in the table `logs_db_interfaces`

DELIMITER $$

CREATE TRIGGER `logs_db_interfaces_delete` AFTER DELETE ON `db_interfaces`
FOR EACH ROW
BEGIN
  INSERT INTO `logs_db_interfaces` (
    `action`, 
    `action_datetime`, 
    `uuid`, 
    `is_obsolete`, 
    `order`, 
    `interface`, 
    `db_user_name`,  
    `interface_description`
    )
    VALUES
    ('DELETE', 
      NOW(), 
      OLD.`uuid`, 
      OLD.`is_obsolete`,
      OLD.`order`,
      OLD.`interface`,
      OLD.`db_user_name`,
      OLD.`interface_description`
      )
  ;
END
$$

DELIMITER ;

# Insert sample values in the table
INSERT  INTO `db_interfaces`
  (`is_obsolete`, 
    `order`, 
    `interface`, 
    `db_user_name`, 
    `interface_description`
    ) 
  VALUES 
    (0,
      0,
      'unknown',
      'root',
      'We have no information about how the change was made.'
    ),
    (0,
      10,
      'sql_manual',
      'root',
      'Direct update in the DB - there is no form or script involved.'
    ),
    (0,
      20,
      'sql_seed_script',
      'root',
      'These value where created by the script that created the database.'
    ),
    (0,
      30,
      'sql_script',
      'root',
      'The update was done with a SQL script.'
    )
;