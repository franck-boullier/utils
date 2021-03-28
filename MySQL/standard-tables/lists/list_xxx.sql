# Replace 
#   - `xxx` with the name of your list table the name should start with `list_` and end with an `s` (ex: `list_user_roles`)
#   - `yyy` with name you have chosen for the designation field of your list table (ex: `user_role`).


# What this script will do:
#
# - Create a table `xxx` to list the possible statutes for a record.
# - Create a trigger `uuid_xxx` to automatically generate the UUID for a new record.
# - Create a table `logs_xxx` to log all the changes in the table.
# - Create a trigger `logs_xxx_insert` to automatically log INSERT operations on the table `xxx`.
# - Create a trigger `logs_xxx_update` to automatically log UPDATE operations on the table `xxx`.
# - Create a trigger `logs_xxx_delete` to automatically log DELETE operations on the table `xxx`.
# - Insert some sample data in the table `xxx`.
# 
# Constaints:
# - The status name must be unique.
# - The Interface to create the record MUST exist in the table `db_interfaces`
# - The Interface to update the record MUST exist in the table `db_interfaces`
#
# Automations and Triggers:
# - The UUID for a new record is automatically generated.
# - Logs of each changes in this table are recorded in the table `logs_xxx`
#
# Sample data are inserted in the table:
# - Record that must exist in the table `db_interfaces`
#   - field `interface`, value 'sql_seed_script'.
#

# Create the table `xxx`
CREATE TABLE `xxx` (
  `uuid` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The globally unique UUID for this record',
  `created_interface_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the interface sytem that was used to CREATE the record?',
  `updated_interface_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the interface sytem that was used to UPDATE the record?',
  `is_obsolete` tinyint(1) DEFAULT '0' COMMENT 'is this obsolete?',
  `order` int(10) NOT NULL DEFAULT '0' COMMENT 'Order in the list',
  `yyy` varchar(50) COLLATE utf8mb4_unicode_520_ci  NOT NULL COMMENT 'Designation',
  `yyy_description` text COLLATE utf8mb4_unicode_520_ci COMMENT 'Description/help text',
  PRIMARY KEY (`uuid`),
  UNIQUE KEY `unique_yyy_designation` (`yyy`) COMMENT 'The designation must be unique',
  KEY `yyy_created_interface_id` (`created_interface_id`),
  KEY `yyy_updated_interface_id` (`updated_interface_id`),
  CONSTRAINT `yyy_created_interface_id` FOREIGN KEY (`created_interface_id`) REFERENCES `db_interfaces` (`uuid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `yyy_updated_interface_id` FOREIGN KEY (`updated_interface_id`) REFERENCES `db_interfaces` (`uuid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC
;

# Make sure that a UUID is generated each time a new record is created in the table `xxx`.
CREATE TRIGGER `uuid_xxx`
  BEFORE INSERT ON `xxx`
  FOR EACH ROW
  SET new.uuid = uuid()
;

# Create the table `logs_xxx` to store the changes in the data
CREATE TABLE `logs_xxx` (
  `action` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The action that was performed on the table',
  `action_datetime` TIMESTAMP NULL DEFAULT NULL COMMENT 'Timestamp - when was the operation done',
  `uuid` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The globally unique UUID for this record',
  `created_interface_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the interface sytem that was used to CREATE the record?',
  `updated_interface_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the interface sytem that was used to UPDATE the record?',
  `is_obsolete` tinyint(1) DEFAULT '0' COMMENT 'is this obsolete?',
  `order` int(10) NOT NULL DEFAULT '0' COMMENT 'Order in the list',
  `yyy` varchar(50) COLLATE utf8mb4_unicode_520_ci  NOT NULL COMMENT 'Designation',
  `yyy_description` text COLLATE utf8mb4_unicode_520_ci COMMENT 'Description/help text',
  KEY `xxx_uuid` (`uuid`) COMMENT 'Index the UUID for improved performances'
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC
;

# After a successful INSERT in the table `xxx`
# Record all the data Inserted in the table `xxx`
# The information will be stored in the table `logs_xxx`

DELIMITER $$

CREATE TRIGGER `logs_xxx_insert` AFTER INSERT ON `xxx`
FOR EACH ROW
BEGIN
  INSERT INTO `logs_xxx` (
    `action`, 
    `action_datetime`, 
    `uuid`, 
    `created_interface_id`, 
    `updated_interface_id`, 
    `is_obsolete`, 
    `order`, 
    `yyy`, 
    `yyy_description`
    )
  VALUES
    ('INSERT', 
      NOW(), 
      NEW.`uuid`, 
      NEW.`created_interface_id`, 
      NEW.`updated_interface_id`, 
      NEW.`is_obsolete`, 
      NEW.`order`, 
      NEW.`yyy`, 
      NEW.`yyy_description`
    )
  ;
END
$$

DELIMITER ;

# After a successful UPDATE in the table `xxx`
# Record all the values for the old record
# Record all the values for the new record
# data Inserted in the table `xxx`
# The information will be stored in the table `logs_xxx`

DELIMITER $$

CREATE TRIGGER `logs_xxx_update` AFTER UPDATE ON `xxx`
FOR EACH ROW
BEGIN
  INSERT INTO `logs_xxx` (
    `action`, 
    `action_datetime`, 
    `uuid`,  
    `created_interface_id`, 
    `updated_interface_id`, 
    `is_obsolete`, 
    `order`, 
    `yyy`, 
    `yyy_description`
    )
    VALUES
      ('UPDATE-OLD_VALUES', 
        NOW(), 
        OLD.`uuid`, 
        OLD.`created_interface_id`, 
        OLD.`updated_interface_id`, 
        OLD.`is_obsolete`, 
        OLD.`order`, 
        OLD.`yyy`, 
        OLD.`yyy_description`
      ),
      ('UPDATE-NEW_VALUES', 
        NOW(), 
        NEW.`uuid`, 
        NEW.`created_interface_id`, 
        NEW.`updated_interface_id`, 
        NEW.`is_obsolete`, 
        NEW.`order`, 
        NEW.`yyy`, 
        NEW.`yyy_description`
      )
  ;
END
$$

DELIMITER ;

# After a successful DELETE in the table `xxx`
# Record all the values for the old record
# The information will be stored in the table `logs_xxx`

DELIMITER $$

CREATE TRIGGER `logs_xxx_delete` AFTER DELETE ON `xxx`
FOR EACH ROW
BEGIN
  INSERT INTO `logs_xxx` (
    `action`, 
    `action_datetime`, 
    `uuid`, 
    `created_interface_id`, 
    `updated_interface_id`, 
    `is_obsolete`, 
    `order`, 
    `yyy`, 
    `yyy_description`
    )
    VALUES
      ('DELETE', 
        NOW(), 
        OLD.`uuid`, 
        OLD.`created_interface_id`, 
        OLD.`updated_interface_id`, 
        OLD.`is_obsolete`, 
        OLD.`order`, 
        OLD.`yyy`, 
        OLD.`yyy_description`
      )
  ;
END
$$

DELIMITER ;

# Create the View for all the values in the list
DROP VIEW IF EXISTS `view_xxx_all`;

CREATE
    VIEW `view_xxx_all` 
    AS
SELECT
    `uuid`
    , `created_interface_id`
    , `updated_interface_id`
    , `is_obsolete`
    , `order`
    , `yyy`
    , `yyy_description`
FROM
    `xxx`
ORDER BY 
	`order` ASC
	, `yyy` ASC
;

# Create the View for the the values in the list that are NOT obsolete
DROP VIEW IF EXISTS `view_xxx_not_obsolete`;

CREATE
    VIEW `view_xxx_not_obsolete` 
    AS
SELECT
    `uuid`
    , `created_interface_id`
    , `updated_interface_id`
    , `is_obsolete`
    , `order`
    , `yyy`
    , `yyy_description`
FROM
    `xxx`
WHERE (`is_obsolete` = 0)
ORDER BY 
	`order` ASC
	, `yyy` ASC
;

# We need to get the uuid for the value `sql_seed_script` in the table `db_interfaces`
# We put this into the variable [@UUID_sql_seed_script]
SELECT `uuid`
    INTO @UUID_sql_seed_script
FROM `db_interfaces`
    WHERE `interface` = 'sql_seed_script'
;

# Insert sample values in the table
INSERT  INTO `xxx`(
    `created_interface_id`, 
    `is_obsolete`, 
    `order`, 
    `yyy`, 
    `yyy_description`
    ) 
    VALUES 
        (@UUID_sql_seed_script, 0, 0, 'Unknown','We have no information on this record'),
        (@UUID_sql_seed_script, 0, 10, 'CAM','Customer Account Manager - this is a person in charge a customer'),
        (@UUID_sql_seed_script, 0, 20, 'MAM','Merchant Account Manager - this is a person in charge a merchant'),
        (@UUID_sql_seed_script, 0, 30, 'PM-Tx2','Product Manager in charge of the TicketXpress products'),
        (@UUID_sql_seed_script, 0, 40, 'CS','Customer Success in charge of supporting the customers'),
        (@UUID_sql_seed_script, 0, 50, 'MS','Merchant Success in charge of supporting the Merchants'),
        (@UUID_sql_seed_script, 0, 60, 'Control','In charge of generating reports and checking Data'),
        (@UUID_sql_seed_script, 0, 70, 'Accounting','In charge of generating invoices and payment to merchants'),
        (@UUID_sql_seed_script, 0, 1000, 'Other','This is none of the above.')
;