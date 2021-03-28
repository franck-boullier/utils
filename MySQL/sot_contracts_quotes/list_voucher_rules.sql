# What this script will do:
#
# - Create a table `list_voucher_rules` to list the possible statutes for a record.
# - Create a trigger `uuid_list_voucher_rules` to automatically generate the UUID for a new record.
# - Create a table `logs_list_voucher_rules` to log all the changes in the table.
# - Create a trigger `logs_list_voucher_rules_insert` to automatically log INSERT operations on the table `list_voucher_rules`.
# - Create a trigger `logs_list_voucher_rules_update` to automatically log UPDATE operations on the table `list_voucher_rules`.
# - Create a trigger `logs_list_voucher_rules_delete` to automatically log DELETE operations on the table `list_voucher_rules`.
# - Insert some sample data in the table `list_voucher_rules`.
# 
# Constaints:
# - The status name must be unique.
# - The Interface to create the record MUST exist in the table `db_interfaces`
# - The Interface to update the record MUST exist in the table `db_interfaces`
#
# Automations and Triggers:
# - The UUID for a new record is automatically generated.
# - Logs of each changes in this table are recorded in the table `logs_list_voucher_rules`
#
# Sample data are inserted in the table:
# - Record that must exist in the table `db_interfaces`
#   - field `interface`, value 'sql_seed_script'.
#

# Create the table `list_voucher_rules`
CREATE TABLE `list_voucher_rules` (
  `uuid` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The globally unique UUID for this record',
  `created_interface_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the interface sytem that was used to CREATE the record?',
  `updated_interface_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the interface sytem that was used to UPDATE the record?',
  `is_obsolete` tinyint(1) DEFAULT '0' COMMENT 'is this obsolete?',
  `order` int(10) NOT NULL DEFAULT '0' COMMENT 'Order in the list',
  `voucher_rule` varchar(50) COLLATE utf8mb4_unicode_520_ci  NOT NULL COMMENT 'Designation',
  `voucher_rule_detail` varchar(50) COLLATE utf8mb4_unicode_520_ci  NOT NULL COMMENT 'The rule that we need to apply',
  `voucher_rule_description` text COLLATE utf8mb4_unicode_520_ci COMMENT 'Description/help text',
  PRIMARY KEY (`uuid`),
  UNIQUE KEY `unique_voucher_rule_designation` (`voucher_rule`) COMMENT 'The designation must be unique',
  KEY `voucher_rule_created_interface_id` (`created_interface_id`),
  KEY `voucher_rule_updated_interface_id` (`updated_interface_id`),
  CONSTRAINT `voucher_rule_created_interface_id` FOREIGN KEY (`created_interface_id`) REFERENCES `db_interfaces` (`uuid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `voucher_rule_updated_interface_id` FOREIGN KEY (`updated_interface_id`) REFERENCES `db_interfaces` (`uuid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC
;

# Make sure that a UUID is generated each time a new record is created in the table `list_voucher_rules`.
CREATE TRIGGER `uuid_list_voucher_rules`
  BEFORE INSERT ON `list_voucher_rules`
  FOR EACH ROW
  SET new.uuid = uuid()
;

# Create the table `logs_list_voucher_rules` to store the changes in the data
CREATE TABLE `logs_list_voucher_rules` (
  `action` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The action that was performed on the table',
  `action_datetime` TIMESTAMP NULL DEFAULT NULL COMMENT 'Timestamp - when was the operation done',
  `uuid` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The globally unique UUID for this record',
  `created_interface_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the interface sytem that was used to CREATE the record?',
  `updated_interface_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the interface sytem that was used to UPDATE the record?',
  `is_obsolete` tinyint(1) DEFAULT '0' COMMENT 'is this obsolete?',
  `order` int(10) NOT NULL DEFAULT '0' COMMENT 'Order in the list',
  `voucher_rule` varchar(50) COLLATE utf8mb4_unicode_520_ci  NOT NULL COMMENT 'Designation',
  `voucher_rule_detail` varchar(50) COLLATE utf8mb4_unicode_520_ci  NOT NULL COMMENT 'The rule that we need to apply',
  `voucher_rule_description` text COLLATE utf8mb4_unicode_520_ci COMMENT 'Description/help text',
  KEY `list_voucher_rules_uuid` (`uuid`) COMMENT 'Index the UUID for improved performances'
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC
;

# After a successful INSERT in the table `list_voucher_rules`
# Record all the data Inserted in the table `list_voucher_rules`
# The information will be stored in the table `logs_list_voucher_rules`

DELIMITER $$

CREATE TRIGGER `logs_list_voucher_rules_insert` AFTER INSERT ON `list_voucher_rules`
FOR EACH ROW
BEGIN
  INSERT INTO `logs_list_voucher_rules` (
    `action`, 
    `action_datetime`, 
    `uuid`, 
    `created_interface_id`, 
    `updated_interface_id`, 
    `is_obsolete`, 
    `order`, 
    `voucher_rule`, 
    `voucher_rule_detail`,
    `voucher_rule_description`
    )
  VALUES
    ('INSERT', 
      NOW(), 
      NEW.`uuid`, 
      NEW.`created_interface_id`, 
      NEW.`updated_interface_id`, 
      NEW.`is_obsolete`, 
      NEW.`order`, 
      NEW.`voucher_rule`, 
      NEW.`voucher_rule_detail`, 
      NEW.`voucher_rule_description`
    )
  ;
END
$$

DELIMITER ;

# After a successful UPDATE in the table `list_voucher_rules`
# Record all the values for the old record
# Record all the values for the new record
# data Inserted in the table `list_voucher_rules`
# The information will be stored in the table `logs_list_voucher_rules`

DELIMITER $$

CREATE TRIGGER `logs_list_voucher_rules_update` AFTER UPDATE ON `list_voucher_rules`
FOR EACH ROW
BEGIN
  INSERT INTO `logs_list_voucher_rules` (
    `action`, 
    `action_datetime`, 
    `uuid`,  
    `created_interface_id`, 
    `updated_interface_id`, 
    `is_obsolete`, 
    `order`, 
    `voucher_rule`,  
    `voucher_rule_detail`,
    `voucher_rule_description`
    )
    VALUES
      ('UPDATE-OLD_VALUES', 
        NOW(), 
        OLD.`uuid`, 
        OLD.`created_interface_id`, 
        OLD.`updated_interface_id`, 
        OLD.`is_obsolete`, 
        OLD.`order`, 
        OLD.`voucher_rule`, 
        OLD.`voucher_rule_detail`, 
        OLD.`voucher_rule_description`
      ),
      ('UPDATE-NEW_VALUES', 
        NOW(), 
        NEW.`uuid`, 
        NEW.`created_interface_id`, 
        NEW.`updated_interface_id`, 
        NEW.`is_obsolete`, 
        NEW.`order`, 
        NEW.`voucher_rule`, 
        NEW.`voucher_rule_detail`, 
        NEW.`voucher_rule_description`
      )
  ;
END
$$

DELIMITER ;

# After a successful DELETE in the table `list_voucher_rules`
# Record all the values for the old record
# The information will be stored in the table `logs_list_voucher_rules`

DELIMITER $$

CREATE TRIGGER `logs_list_voucher_rules_delete` AFTER DELETE ON `list_voucher_rules`
FOR EACH ROW
BEGIN
  INSERT INTO `logs_list_voucher_rules` (
    `action`, 
    `action_datetime`, 
    `uuid`, 
    `created_interface_id`, 
    `updated_interface_id`, 
    `is_obsolete`, 
    `order`, 
    `voucher_rule`,  
    `voucher_rule_detail`,
    `voucher_rule_description`
    )
    VALUES
      ('DELETE', 
        NOW(), 
        OLD.`uuid`, 
        OLD.`created_interface_id`, 
        OLD.`updated_interface_id`, 
        OLD.`is_obsolete`, 
        OLD.`order`, 
        OLD.`voucher_rule`, 
        OLD.`voucher_rule_detail`, 
        OLD.`voucher_rule_description`
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
INSERT  INTO `list_voucher_rules`(
    `created_interface_id`, 
    `is_obsolete`, 
    `order`, 
    `voucher_rule`,  
    `voucher_rule_detail`,
    `voucher_rule_description`
    ) 
    VALUES 
        (@UUID_sql_seed_script, 0, 0, 'Prefix UG005', 'UG005', 'Add this prefix to the Voucher Number'),
        (@UUID_sql_seed_script, 0, 10, 'Prefix UG010', 'UG005', 'Add this prefix to the Voucher Number'),
        (@UUID_sql_seed_script, 0, 20, 'Prefix UG020', 'UG020', 'Add this prefix to the Voucher Number'),
        (@UUID_sql_seed_script, 0, 30, 'Prefix UG030', 'UG030', 'Add this prefix to the Voucher Number'),
        (@UUID_sql_seed_script, 0, 40, 'Prefix UG050', 'UG050', 'Add this prefix to the Voucher Number'),
        (@UUID_sql_seed_script, 0, 50, 'Prefix UG100', 'UG100', 'Add this prefix to the Voucher Number'),
        (@UUID_sql_seed_script, 0, 60, 'Length 7', '7', 'The Voucher Number (excl. Prefix) should be this long'),
        (@UUID_sql_seed_script, 0, 70, 'Length 10', '10', 'The Voucher Number (excl. Prefix) should be this long'),
        (@UUID_sql_seed_script, 0, 80, 'Length 13', '13', 'The Voucher Number (excl. Prefix) should be this long'),
        (@UUID_sql_seed_script, 0, 90, 'All Digits', 'All Digits', 'The Voucher Number should ONLY Include digits')
;