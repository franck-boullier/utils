# What this script will do:
#
# - Create a table `list_product_redemption_modes` to list the possible statutes for a record.
# - Create a trigger `uuid_list_product_redemption_modes` to automatically generate the UUID for a new record.
# - Create a table `logs_list_product_redemption_modes` to log all the changes in the table.
# - Create a trigger `logs_list_product_redemption_modes_insert` to automatically log INSERT operations on the table `list_product_redemption_modes`.
# - Create a trigger `logs_list_product_redemption_modes_update` to automatically log UPDATE operations on the table `list_product_redemption_modes`.
# - Create a trigger `logs_list_product_redemption_modes_delete` to automatically log DELETE operations on the table `list_product_redemption_modes`.
# - Insert some sample data in the table `list_product_redemption_modes`.
# 
# Constaints:
# - The status name must be unique.
# - The Interface to create the record MUST exist in the table `db_interfaces`
# - The Interface to update the record MUST exist in the table `db_interfaces`
#
# Automations and Triggers:
# - The UUID for a new record is automatically generated.
# - Logs of each changes in this table are recorded in the table `logs_list_product_redemption_modes`
#
# Sample data are inserted in the table:
#   - The table `db_interfaces` must exist in your database.
#   - A record with a value 'sql_seed_script' for the field `interface_designation` must exist in the  table `db_interfaces`.
#

# Create the table `list_product_redemption_modes`
CREATE TABLE `list_product_redemption_modes` (
  `uuid` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The globally unique UUID for this record',
  `interface_id_creation` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the interface sytem that was used to CREATE the record?',
  `interface_id_update` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the interface sytem that was used to UPDATE the record?',
  `is_obsolete` tinyint(1) DEFAULT '0' COMMENT 'is this obsolete?',
  `order` int(10) NOT NULL DEFAULT '0' COMMENT 'Order in the list',
  `product_redemption_mode` varchar(50) COLLATE utf8mb4_unicode_520_ci  NOT NULL COMMENT 'Designation',
  `product_redemption_mode_description` text COLLATE utf8mb4_unicode_520_ci COMMENT 'Description/help text',
  PRIMARY KEY (`uuid`,`product_redemption_mode`),
  KEY `product_redemption_mode_interface_id_creation` (`interface_id_creation`),
  KEY `product_redemption_mode_interface_id_update` (`interface_id_update`),
  CONSTRAINT `product_redemption_mode_interface_id_creation` FOREIGN KEY (`interface_id_creation`) REFERENCES `db_interfaces` (`uuid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `product_redemption_mode_interface_id_update` FOREIGN KEY (`interface_id_update`) REFERENCES `db_interfaces` (`uuid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC
;

# Make sure that a UUID is generated each time a new record is created in the table `list_product_redemption_modes`.
CREATE TRIGGER `uuid_list_product_redemption_modes`
  BEFORE INSERT ON `list_product_redemption_modes`
  FOR EACH ROW
  SET new.uuid = uuid()
;

# Create the table `logs_list_product_redemption_modes` to store the changes in the data
CREATE TABLE `logs_list_product_redemption_modes` (
  `action` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The action that was performed on the table',
  `action_datetime` TIMESTAMP NULL DEFAULT NULL COMMENT 'Timestamp - when was the operation done',
  `uuid` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The globally unique UUID for this record',
  `interface_id_creation` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the interface sytem that was used to CREATE the record?',
  `interface_id_update` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the interface sytem that was used to UPDATE the record?',
  `is_obsolete` tinyint(1) DEFAULT '0' COMMENT 'is this obsolete?',
  `order` int(10) NOT NULL DEFAULT '0' COMMENT 'Order in the list',
  `product_redemption_mode` varchar(50) COLLATE utf8mb4_unicode_520_ci  NOT NULL COMMENT 'Designation',
  `product_redemption_mode_description` text COLLATE utf8mb4_unicode_520_ci COMMENT 'Description/help text',
  KEY `list_product_redemption_modes_uuid` (`uuid`) COMMENT 'Index the UUID for improved performances'
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC
;

# After a successful INSERT in the table `list_product_redemption_modes`
# Record all the data Inserted in the table `list_product_redemption_modes`
# The information will be stored in the table `logs_list_product_redemption_modes`

DELIMITER $$

CREATE TRIGGER `logs_list_product_redemption_modes_insert` AFTER INSERT ON `list_product_redemption_modes`
FOR EACH ROW
BEGIN
  INSERT INTO `logs_list_product_redemption_modes` (
    `action`, 
    `action_datetime`, 
    `uuid`, 
    `interface_id_creation`, 
    `interface_id_update`, 
    `is_obsolete`, 
    `order`, 
    `product_redemption_mode`, 
    `product_redemption_mode_description`
    )
  VALUES('INSERT', NOW(), NEW.`uuid`, NEW.`interface_id_creation`, NEW.`interface_id_update`, NEW.`is_obsolete`, NEW.`order`, NEW.`product_redemption_mode`, NEW.`product_redemption_mode_description`)
  ;
END
$$

DELIMITER ;

# After a successful UPDATE in the table `list_product_redemption_modes`
# Record all the values for the old record
# Record all the values for the new record
# data Inserted in the table `list_product_redemption_modes`
# The information will be stored in the table `logs_list_product_redemption_modes`

DELIMITER $$

CREATE TRIGGER `logs_list_product_redemption_modes_update` AFTER UPDATE ON `list_product_redemption_modes`
FOR EACH ROW
BEGIN
  INSERT INTO `logs_list_product_redemption_modes` (
    `action`, 
    `action_datetime`, 
    `uuid`,  
    `interface_id_creation`, 
    `interface_id_update`, 
    `is_obsolete`, 
    `order`, 
    `product_redemption_mode`, 
    `product_redemption_mode_description`
    )
    VALUES
    ('UPDATE-OLD_VALUES', NOW(), OLD.`uuid`, OLD.`interface_id_creation`, OLD.`interface_id_update`, OLD.`is_obsolete`, OLD.`order`, OLD.`product_redemption_mode`, OLD.`product_redemption_mode_description`),
    ('UPDATE-NEW_VALUES', NOW(), NEW.`uuid`, NEW.`interface_id_creation`, NEW.`interface_id_update`, NEW.`is_obsolete`, NEW.`order`, NEW.`product_redemption_mode`, NEW.`product_redemption_mode_description`)
  ;
END
$$

DELIMITER ;

# After a successful DELETE in the table `list_product_redemption_modes`
# Record all the values for the old record
# The information will be stored in the table `logs_list_product_redemption_modes`

DELIMITER $$

CREATE TRIGGER `logs_list_product_redemption_modes_delete` AFTER DELETE ON `list_product_redemption_modes`
FOR EACH ROW
BEGIN
  INSERT INTO `logs_list_product_redemption_modes` (
    `action`, 
    `action_datetime`, 
    `uuid`, 
    `interface_id_creation`, 
    `interface_id_update`, 
    `is_obsolete`, 
    `order`, 
    `product_redemption_mode`, 
    `product_redemption_mode_description`
    )
    VALUES
    ('DELETE', NOW(), OLD.`uuid`, OLD.`interface_id_creation`, OLD.`interface_id_update`, OLD.`is_obsolete`, OLD.`order`, OLD.`product_redemption_mode`, OLD.`product_redemption_mode_description`)
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

# Insert sample values in the table
INSERT  INTO `list_product_redemption_modes`(
    `interface_id_creation`, 
    `is_obsolete`, 
    `order`, 
    `product_redemption_mode`, 
    `product_redemption_mode_description`
    ) 
    VALUES 
        (@UUID_sql_seed_script, 0, 0, 'Unknown','We have no information on the Product Category'),
        (@UUID_sql_seed_script, 0, 10, 'POS','INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, 0, 20, 'FTP','INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, 0, 30, 'WEB','INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, 0, 1000, 'Other','This is non of the above')
;