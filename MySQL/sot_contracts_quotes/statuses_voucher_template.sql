# What this script will do:
#
# - Create a table `statuses_voucher_template` to list the possible statutes for a record.
# - Create a trigger `uuid_statuses_voucher_template` to automatically generate the UUID for a new record.
# - Create a table `logs_statuses_voucher_template` to log all the changes in the table.
# - Create a trigger `logs_statuses_voucher_template_insert` to automatically log INSERT operations on the table `statuses_voucher_template`.
# - Create a trigger `logs_statuses_voucher_template_update` to automatically log UPDATE operations on the table `statuses_voucher_template`.
# - Create a trigger `logs_statuses_voucher_template_delete` to automatically log DELETE operations on the table `statuses_voucher_template`.
# - Insert some sample data in the table `statuses_voucher_template`.
# 
# Constaints:
# - The status name must be unique.
# - The Interface to create the record MUST exist in the table `db_interfaces`
# - The Interface to update the record MUST exist in the table `db_interfaces`
#
# Automations and Triggers:
# - The UUID for a new record is automatically generated.
# - Logs of each changes in this table are recorded in the table `logs_statuses_voucher_template`
#
# Sample data are inserted in the table:
# - Record that must exist in the table `db_interfaces`
#   - field `interface`, value 'sql_seed_script'.
#

# Create the table `statuses_voucher_template`
CREATE TABLE `statuses_voucher_template` (
  `uuid` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The globally unique UUID for this record',
  `interface_id_creation` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the interface sytem that was used to CREATE the record?',
  `interface_id_update` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the interface sytem that was used to UPDATE the record?',
  `is_obsolete` tinyint(1) DEFAULT '0' COMMENT 'is this obsolete?',
  `order` int(10) NOT NULL DEFAULT '0' COMMENT 'Order in the list',
  `is_active` tinyint(1) DEFAULT '0' COMMENT 'This satus is considered as ACTIVE',
  `voucher_template_status` varchar(50) COLLATE utf8mb4_unicode_520_ci  NOT NULL COMMENT 'Designation',
  `voucher_template_status_description` text COLLATE utf8mb4_unicode_520_ci COMMENT 'Description/help text',
  PRIMARY KEY (`uuid`),
  UNIQUE KEY `unique_voucher_template_status_designation` (`voucher_template_status`) COMMENT 'The designation must be unique',
  KEY `voucher_template_status_interface_id_creation` (`interface_id_creation`),
  KEY `voucher_template_status_interface_id_update` (`interface_id_update`),
  CONSTRAINT `voucher_template_status_interface_id_creation` FOREIGN KEY (`interface_id_creation`) REFERENCES `db_interfaces` (`uuid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `voucher_template_status_interface_id_update` FOREIGN KEY (`interface_id_update`) REFERENCES `db_interfaces` (`uuid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC
;

# Make sure that a UUID is generated each time a new record is created in the table `statuses_voucher_template`.
CREATE TRIGGER `uuid_statuses_voucher_template`
  BEFORE INSERT ON `statuses_voucher_template`
  FOR EACH ROW
  SET new.uuid = uuid()
;

# Create the table `logs_statuses_voucher_template` to store the changes in the data
CREATE TABLE `logs_statuses_voucher_template` (
  `action` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The action that was performed on the table',
  `action_datetime` TIMESTAMP NULL DEFAULT NULL COMMENT 'Timestamp - when was the operation done',
  `uuid` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The globally unique UUID for this record',
  `interface_id_creation` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the interface sytem that was used to CREATE the record?',
  `interface_id_update` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the interface sytem that was used to UPDATE the record?',
  `is_obsolete` tinyint(1) DEFAULT '0' COMMENT 'is this obsolete?',
  `order` int(10) NOT NULL DEFAULT '0' COMMENT 'Order in the list',
  `is_active` tinyint(1) DEFAULT '0' COMMENT 'This satus is considered as ACTIVE',
  `voucher_template_status` varchar(50) COLLATE utf8mb4_unicode_520_ci  NOT NULL COMMENT 'Designation',
  `voucher_template_status_description` text COLLATE utf8mb4_unicode_520_ci COMMENT 'Description/help text',
  KEY `statuses_voucher_template_uuid` (`uuid`) COMMENT 'Index the UUID for improved performances'
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC
;

# After a successful INSERT in the table `statuses_voucher_template`
# Record all the data Inserted in the table `statuses_voucher_template`
# The information will be stored in the table `logs_statuses_voucher_template`

DELIMITER $$

CREATE TRIGGER `logs_statuses_voucher_template_insert` AFTER INSERT ON `statuses_voucher_template`
FOR EACH ROW
BEGIN
  INSERT INTO `logs_statuses_voucher_template` (
    `action`, 
    `action_datetime`, 
    `uuid`, 
    `interface_id_creation`, 
    `interface_id_update`, 
    `is_obsolete`, 
    `order`, 
    `is_active`, 
    `voucher_template_status`, 
    `voucher_template_status_description`
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
      NEW.`voucher_template_status`, 
      NEW.`voucher_template_status_description`
    )
  ;
END
$$

DELIMITER ;

# After a successful UPDATE in the table `statuses_voucher_template`
# Record all the values for the old record
# Record all the values for the new record
# data Inserted in the table `statuses_voucher_template`
# The information will be stored in the table `logs_statuses_voucher_template`

DELIMITER $$

CREATE TRIGGER `logs_statuses_voucher_template_update` AFTER UPDATE ON `statuses_voucher_template`
FOR EACH ROW
BEGIN
  INSERT INTO `logs_statuses_voucher_template` (
    `action`, 
    `action_datetime`, 
    `uuid`,  
    `interface_id_creation`, 
    `interface_id_update`, 
    `is_obsolete`, 
    `order`, 
    `is_active`, 
    `voucher_template_status`, 
    `voucher_template_status_description`
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
        OLD.`voucher_template_status`, 
        OLD.`voucher_template_status_description`
      ),
      ('UPDATE-NEW_VALUES', 
        NOW(), 
        NEW.`uuid`, 
        NEW.`interface_id_creation`, 
        NEW.`interface_id_update`, 
        NEW.`is_obsolete`, 
        NEW.`order`, 
        NEW.`is_active`, 
        NEW.`voucher_template_status`, 
        NEW.`voucher_template_status_description`
      )
  ;
END
$$

DELIMITER ;

# After a successful DELETE in the table `statuses_voucher_template`
# Record all the values for the old record
# The information will be stored in the table `logs_statuses_voucher_template`

DELIMITER $$

CREATE TRIGGER `logs_statuses_voucher_template_delete` AFTER DELETE ON `statuses_voucher_template`
FOR EACH ROW
BEGIN
  INSERT INTO `logs_statuses_voucher_template` (
    `action`, 
    `action_datetime`, 
    `uuid`, 
    `interface_id_creation`, 
    `interface_id_update`, 
    `is_obsolete`, 
    `order`, 
    `is_active`, 
    `voucher_template_status`, 
    `voucher_template_status_description`
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
          OLD.`voucher_template_status`, 
          OLD.`voucher_template_status_description`
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
INSERT  INTO `statuses_voucher_template`(
    `interface_id_creation`, 
    `is_obsolete`, 
    `order`, 
    `is_active`, 
    `voucher_template_status`, 
    `voucher_template_status_description`
    ) 
    VALUES 
        (@UUID_sql_seed_script, 0, 0, 0, 'UNKNOWN','We have no information about the voucher_template status. This is an INACTIVE Status'),
        (@UUID_sql_seed_script, 0, 10, 0, 'PROJECT','This is a project. This is an INACTIVE Status'),
        (@UUID_sql_seed_script, 0, 20, 0, 'DRAFT','The project has been approved and we have a draft of the template. This is an ACTIVE Status'),
        (@UUID_sql_seed_script, 0, 30, 0, 'READY','The template is ready but we have no voucher using the template yet. This is an INACTIVE Status'),
        (@UUID_sql_seed_script, 0, 40, 1, 'LIVE','The template is ready and in use. This is an ACTIVE Status'),
        (@UUID_sql_seed_script, 0, 50, 1, 'SUNSET','The template is currently used but we should NOT use it for new vouchers. This is an ACTIVE Status'),
        (@UUID_sql_seed_script, 0, 60, 0, 'TERMINATED','The contract with the merchant has been terminated. This is an INACTIVE Status'),
        (@UUID_sql_seed_script, 0, 70, 0, 'DUPLICATE','This is a duplicate of an existing record. This is an INACTIVE Status')
;