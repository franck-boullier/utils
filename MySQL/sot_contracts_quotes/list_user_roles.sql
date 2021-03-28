# What this script will do:
#
# - Create a table `list_user_roles` to list the possible statutes for a record.
# - Create a trigger `uuid_list_user_roles` to automatically generate the UUID for a new record.
# - Create a table `logs_list_user_roles` to log all the changes in the table.
# - Create a trigger `logs_list_user_roles_insert` to automatically log INSERT operations on the table `list_user_roles`.
# - Create a trigger `logs_list_user_roles_update` to automatically log UPDATE operations on the table `list_user_roles`.
# - Create a trigger `logs_list_user_roles_delete` to automatically log DELETE operations on the table `list_user_roles`.
# - Insert some sample data in the table `list_user_roles`.
# 
# Constaints:
# - The status name must be unique.
# - The Interface to create the record MUST exist in the table `db_interfaces`
# - The Interface to update the record MUST exist in the table `db_interfaces`
#
# Automations and Triggers:
# - The UUID for a new record is automatically generated.
# - Logs of each changes in this table are recorded in the table `logs_list_user_roles`
#
# Sample data are inserted in the table:
# - Record that must exist in the table `db_interfaces`
#   - field `interface`, value 'sql_seed_script'.
#

# Create the table `list_user_roles`
CREATE TABLE `list_user_roles` (
  `uuid` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The globally unique UUID for this record',
  `created_interface_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the interface sytem that was used to CREATE the record?',
  `updated_interface_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the interface sytem that was used to UPDATE the record?',
  `is_obsolete` tinyint(1) DEFAULT '0' COMMENT 'is this obsolete?',
  `order` int(10) NOT NULL DEFAULT '0' COMMENT 'Order in the list',
  `user_role` varchar(50) COLLATE utf8mb4_unicode_520_ci  NOT NULL COMMENT 'Designation',
  `user_role_description` text COLLATE utf8mb4_unicode_520_ci COMMENT 'Description/help text',
  PRIMARY KEY (`uuid`),
  UNIQUE KEY `unique_user_role_designation` (`user_role`) COMMENT 'The designation must be unique',
  KEY `user_role_created_interface_id` (`created_interface_id`),
  KEY `user_role_updated_interface_id` (`updated_interface_id`),
  CONSTRAINT `user_role_created_interface_id` FOREIGN KEY (`created_interface_id`) REFERENCES `db_interfaces` (`uuid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `user_role_updated_interface_id` FOREIGN KEY (`updated_interface_id`) REFERENCES `db_interfaces` (`uuid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC
;

# Make sure that a UUID is generated each time a new record is created in the table `list_user_roles`.
CREATE TRIGGER `uuid_list_user_roles`
  BEFORE INSERT ON `list_user_roles`
  FOR EACH ROW
  SET new.uuid = uuid()
;

# Create the table `logs_list_user_roles` to store the changes in the data
CREATE TABLE `logs_list_user_roles` (
  `action` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The action that was performed on the table',
  `action_datetime` TIMESTAMP NULL DEFAULT NULL COMMENT 'Timestamp - when was the operation done',
  `uuid` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The globally unique UUID for this record',
  `created_interface_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the interface sytem that was used to CREATE the record?',
  `updated_interface_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the interface sytem that was used to UPDATE the record?',
  `is_obsolete` tinyint(1) DEFAULT '0' COMMENT 'is this obsolete?',
  `order` int(10) NOT NULL DEFAULT '0' COMMENT 'Order in the list',
  `user_role` varchar(50) COLLATE utf8mb4_unicode_520_ci  NOT NULL COMMENT 'Designation',
  `user_role_description` text COLLATE utf8mb4_unicode_520_ci COMMENT 'Description/help text',
  KEY `list_user_roles_uuid` (`uuid`) COMMENT 'Index the UUID for improved performances'
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC
;

# After a successful INSERT in the table `list_user_roles`
# Record all the data Inserted in the table `list_user_roles`
# The information will be stored in the table `logs_list_user_roles`

DELIMITER $$

CREATE TRIGGER `logs_list_user_roles_insert` AFTER INSERT ON `list_user_roles`
FOR EACH ROW
BEGIN
  INSERT INTO `logs_list_user_roles` (
    `action`, 
    `action_datetime`, 
    `uuid`, 
    `created_interface_id`, 
    `updated_interface_id`, 
    `is_obsolete`, 
    `order`, 
    `user_role`, 
    `user_role_description`
    )
  VALUES
    ('INSERT', 
      NOW(), 
      NEW.`uuid`, 
      NEW.`created_interface_id`, 
      NEW.`updated_interface_id`, 
      NEW.`is_obsolete`, 
      NEW.`order`, 
      NEW.`user_role`, 
      NEW.`user_role_description`
    )
  ;
END
$$

DELIMITER ;

# After a successful UPDATE in the table `list_user_roles`
# Record all the values for the old record
# Record all the values for the new record
# data Inserted in the table `list_user_roles`
# The information will be stored in the table `logs_list_user_roles`

DELIMITER $$

CREATE TRIGGER `logs_list_user_roles_update` AFTER UPDATE ON `list_user_roles`
FOR EACH ROW
BEGIN
  INSERT INTO `logs_list_user_roles` (
    `action`, 
    `action_datetime`, 
    `uuid`,  
    `created_interface_id`, 
    `updated_interface_id`, 
    `is_obsolete`, 
    `order`, 
    `user_role`, 
    `user_role_description`
    )
    VALUES
      ('UPDATE-OLD_VALUES', 
        NOW(), 
        OLD.`uuid`, 
        OLD.`created_interface_id`, 
        OLD.`updated_interface_id`, 
        OLD.`is_obsolete`, 
        OLD.`order`, 
        OLD.`user_role`, 
        OLD.`user_role_description`
      ),
      ('UPDATE-NEW_VALUES', 
        NOW(), 
        NEW.`uuid`, 
        NEW.`created_interface_id`, 
        NEW.`updated_interface_id`, 
        NEW.`is_obsolete`, 
        NEW.`order`, 
        NEW.`user_role`, 
        NEW.`user_role_description`
      )
  ;
END
$$

DELIMITER ;

# After a successful DELETE in the table `list_user_roles`
# Record all the values for the old record
# The information will be stored in the table `logs_list_user_roles`

DELIMITER $$

CREATE TRIGGER `logs_list_user_roles_delete` AFTER DELETE ON `list_user_roles`
FOR EACH ROW
BEGIN
  INSERT INTO `logs_list_user_roles` (
    `action`, 
    `action_datetime`, 
    `uuid`, 
    `created_interface_id`, 
    `updated_interface_id`, 
    `is_obsolete`, 
    `order`, 
    `user_role`, 
    `user_role_description`
    )
    VALUES
      ('DELETE', 
        NOW(), 
        OLD.`uuid`, 
        OLD.`created_interface_id`, 
        OLD.`updated_interface_id`, 
        OLD.`is_obsolete`, 
        OLD.`order`, 
        OLD.`user_role`, 
        OLD.`user_role_description`
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
INSERT  INTO `list_user_roles`(
    `created_interface_id`, 
    `is_obsolete`, 
    `order`, 
    `user_role`, 
    `user_role_description`
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