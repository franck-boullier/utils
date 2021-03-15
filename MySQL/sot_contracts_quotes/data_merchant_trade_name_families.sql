# What this script will do:
#
# - Create a table `data_merchant_trade_name_families` to list the possible statutes for a record.
# - Create a trigger `uuid_data_merchant_trade_name_families` to automatically generate the UUID for a new record.
# - Create a table `logs_data_merchant_trade_name_families` to log all the changes in the table.
# - Create a trigger `logs_data_merchant_trade_name_families_insert` to automatically log INSERT operations on the table `data_merchant_trade_name_families`.
# - Create a trigger `logs_data_merchant_trade_name_families_update` to automatically log UPDATE operations on the table `data_merchant_trade_name_families`.
# - Create a trigger `logs_data_merchant_trade_name_families_delete` to automatically log DELETE operations on the table `data_merchant_trade_name_families`.
# - Insert some sample data in the table `data_merchant_trade_name_families`.
# 
# Constaints:
# - The status name must be unique.
# - The Interface to create the record MUST exist in the table `db_interfaces`
# - The Interface to update the record MUST exist in the table `db_interfaces`
# - The `merchant_trade_name_status` record MUST exist in the the table `list_merchant_trade_name_statuses`.
#
# Automations and Triggers:
# - The UUID for a new record is automatically generated.
# - Logs of each changes in this table are recorded in the table `logs_data_merchant_trade_name_families`
#
# Sample data are inserted in the table:
# - Record that must exist in the table `db_interfaces`
#   - field `interface_designation`, value 'sql_seed_script'.
# - Record that must exist in the table `list_merchant_trade_name_statuses`
#   - field `merchant_trade_name_status`, value 'Unknown'.
#   - field `merchant_trade_name_status`, value 'LIVE'.
#

# Create the table `data_merchant_trade_name_families`
CREATE TABLE `data_merchant_trade_name_families` (
  `uuid` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The globally unique UUID for this record',
  `interface_id_creation` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the interface sytem that was used to CREATE the record?',
  `interface_id_update` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the interface sytem that was used to UPDATE the record?',
  `order` int(10) NOT NULL DEFAULT '0' COMMENT 'Order in the list',
  `merch_t_n_family` varchar(50) COLLATE utf8mb4_unicode_520_ci  NOT NULL COMMENT 'Designation',
  `tentative_starts_from` date DEFAULT NULL COMMENT 'The date when we PLANT to start the program',
  `actual_starts_from` date DEFAULT NULL COMMENT 'The date when we ACTUALLY started the program',
  `tentative_ends_on` date DEFAULT NULL COMMENT 'The date when we PLAN to end the program',
  `actual_ends_on` date DEFAULT NULL COMMENT 'The date when we ACTUALLY ended the program',
  `merch_t_n_family_status_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'What is the status for this?',
  `merch_t_n_family_description` text COLLATE utf8mb4_unicode_520_ci COMMENT 'Description/help text',
  PRIMARY KEY (`uuid`,`merch_t_n_family`),
  KEY `merch_t_n_family_interface_id_creation` (`interface_id_creation`),
  KEY `merch_t_n_family_interface_id_update` (`interface_id_update`),
  KEY `merch_t_n_family_merch_t_n_family_status_id` (`merch_t_n_family_status_id`),  
  CONSTRAINT `merch_t_n_family_interface_id_creation` FOREIGN KEY (`interface_id_creation`) REFERENCES `db_interfaces` (`uuid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `merch_t_n_family_interface_id_update` FOREIGN KEY (`interface_id_update`) REFERENCES `db_interfaces` (`uuid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `merch_t_n_family_merch_t_n_family_status_id` FOREIGN KEY (`merch_t_n_family_status_id`) REFERENCES `list_merch_t_name_family_statuses` (`uuid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC
;

# Make sure that a UUID is generated each time a new record is created in the table `data_merchant_trade_name_families`.
CREATE TRIGGER `uuid_data_merchant_trade_name_families`
  BEFORE INSERT ON `data_merchant_trade_name_families`
  FOR EACH ROW
  SET new.uuid = uuid()
;

# Create the table `logs_data_merchant_trade_name_families` to store the changes in the data
CREATE TABLE `logs_data_merchant_trade_name_families` (
  `action` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The action that was performed on the table',
  `action_datetime` TIMESTAMP NULL DEFAULT NULL COMMENT 'Timestamp - when was the operation done',
  `uuid` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The globally unique UUID for this record',
  `interface_id_creation` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the interface sytem that was used to CREATE the record?',
  `interface_id_update` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the interface sytem that was used to UPDATE the record?',
  `order` int(10) NOT NULL DEFAULT '0' COMMENT 'Order in the list',
  `merch_t_n_family` varchar(50) COLLATE utf8mb4_unicode_520_ci  NOT NULL COMMENT 'Designation',
  `tentative_starts_from` date DEFAULT NULL COMMENT 'The date when we PLANT to start the program',
  `actual_starts_from` date DEFAULT NULL COMMENT 'The date when we ACTUALLY started the program',
  `tentative_ends_on` date DEFAULT NULL COMMENT 'The date when we PLAN to end the program',
  `actual_ends_on` date DEFAULT NULL COMMENT 'The date when we ACTUALLY ended the program',
  `merch_t_n_family_status_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the product Type for this Voucher Template?',
  `merch_t_n_family_description` text COLLATE utf8mb4_unicode_520_ci COMMENT 'Description/help text',
  KEY `data_merch_t_n_family_families_uuid` (`uuid`) COMMENT 'Index the UUID for improved performances'
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC
;

# After a successful INSERT in the table `data_merchant_trade_name_families`
# Record all the data Inserted in the table `data_merchant_trade_name_families`
# The information will be stored in the table `logs_data_merchant_trade_name_families`

DELIMITER $$

CREATE TRIGGER `logs_data_merchant_trade_name_families_insert` AFTER INSERT ON `data_merchant_trade_name_families`
FOR EACH ROW
BEGIN
  INSERT INTO `logs_data_merchant_trade_name_families` (
    `action`, 
    `action_datetime`, 
    `uuid`, 
    `interface_id_creation`, 
    `interface_id_update`, 
    `order`,
    `tentative_starts_from`,
    `actual_starts_from`,
    `tentative_ends_on`,
    `actual_ends_on`,
    `merch_t_n_family`,
    `merch_t_n_family_status_id`,
    `merch_t_n_family_description`
    )
  VALUES
    ('INSERT', 
      NOW(), 
      NEW.`uuid`, 
      NEW.`interface_id_creation`, 
      NEW.`interface_id_update`, 
      NEW.`order`,
      NEW.`tentative_starts_from`,
      NEW.`actual_starts_from`,
      NEW.`tentative_ends_on`,
      NEW.`actual_ends_on`, 
      NEW.`merch_t_n_family`, 
      NEW.`merch_t_n_family_status_id`, 
      NEW.`merch_t_n_family_description`
    )
  ;
END
$$

DELIMITER ;

# After a successful UPDATE in the table `data_merchant_trade_name_families`
# Record all the values for the old record
# Record all the values for the new record
# data Inserted in the table `data_merchant_trade_name_families`
# The information will be stored in the table `logs_data_merchant_trade_name_families`

DELIMITER $$

CREATE TRIGGER `logs_data_merchant_trade_name_families_update` AFTER UPDATE ON `data_merchant_trade_name_families`
FOR EACH ROW
BEGIN
  INSERT INTO `logs_data_merchant_trade_name_families` (
    `action`, 
    `action_datetime`, 
    `uuid`,  
    `interface_id_creation`, 
    `interface_id_update`, 
    `order`,
    `tentative_starts_from`,
    `actual_starts_from`,
    `tentative_ends_on`,
    `actual_ends_on`, 
    `merch_t_n_family`,
    `merch_t_n_family_status_id`, 
    `merch_t_n_family_description`
    )
    VALUES
      ('UPDATE-OLD_VALUES', 
        NOW(), 
        OLD.`uuid`, 
        OLD.`interface_id_creation`, 
        OLD.`interface_id_update`, 
        OLD.`order`,
        OLD.`tentative_starts_from`,
        OLD.`actual_starts_from`,
        OLD.`tentative_ends_on`,
        OLD.`actual_ends_on`, 
        OLD.`merch_t_n_family`, 
        OLD.`merch_t_n_family_status_id`, 
        OLD.`merch_t_n_family_description`
      ),
      ('UPDATE-NEW_VALUES', 
        NOW(), 
        NEW.`uuid`, 
        NEW.`interface_id_creation`, 
        NEW.`interface_id_update`, 
        NEW.`order`,
        NEW.`tentative_starts_from`,
        NEW.`actual_starts_from`,
        NEW.`tentative_ends_on`,
        NEW.`actual_ends_on`, 
        NEW.`merch_t_n_family`, 
        NEW.`merch_t_n_family_status_id`, 
        NEW.`merch_t_n_family_description`
      )
  ;
END
$$

DELIMITER ;

# After a successful DELETE in the table `data_merchant_trade_name_families`
# Record all the values for the old record
# The information will be stored in the table `logs_data_merchant_trade_name_families`

DELIMITER $$

CREATE TRIGGER `logs_data_merchant_trade_name_families_delete` AFTER DELETE ON `data_merchant_trade_name_families`
FOR EACH ROW
BEGIN
  INSERT INTO `logs_data_merchant_trade_name_families` (
    `action`, 
    `action_datetime`, 
    `uuid`, 
    `interface_id_creation`, 
    `interface_id_update`, 
    `order`,
    `tentative_starts_from`,
    `actual_starts_from`,
    `tentative_ends_on`,
    `actual_ends_on`, 
    `merch_t_n_family`,
    `merch_t_n_family_status_id`, 
    `merch_t_n_family_description`
    )
    VALUES
      ('DELETE', 
        NOW(), 
        OLD.`uuid`, 
        OLD.`interface_id_creation`, 
        OLD.`interface_id_update`, 
        OLD.`order`,
        OLD.`tentative_starts_from`,
        OLD.`actual_starts_from`,
        OLD.`tentative_ends_on`,
        OLD.`actual_ends_on`, 
        OLD.`merch_t_n_family`, 
        OLD.`merch_t_n_family_status_id`, 
        OLD.`merch_t_n_family_description`
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
    WHERE `interface_designation` = 'sql_seed_script'
;

# We need to get the uuid for the value 'UNKNOWN' in the table `list_merch_t_name_family_statuses`
# We put this into the variable [@UUID_UNKNOWN_merch_t_n_family_status]
SELECT `uuid`
    INTO @UUID_UNKNOWN_merch_t_n_family_status
FROM `list_merch_t_name_family_statuses`
    WHERE `merch_t_name_family_status` = 'UNKNOWN'
;

# We need to get the uuid for the value 'LIVE' in the table `list_merch_t_name_family_statuses`
# We put this into the variable [@UUID_LIVE_merch_t_n_family_status]
SELECT `uuid`
    INTO @UUID_LIVE_merch_t_n_family_status
FROM `list_merch_t_name_family_statuses`
    WHERE `merch_t_name_family_status` = 'LIVE'
;

# Insert sample values in the table
INSERT  INTO `data_merchant_trade_name_families`(
    `interface_id_creation`, 
    `order`,
    `actual_starts_from`,
    `tentative_ends_on`,
    `merch_t_n_family`,
    `merch_t_n_family_status_id`, 
    `merch_t_n_family_description`
    ) 
    VALUES 
        (@UUID_sql_seed_script, 0, '2019-09-01', '2099-12-31', 'Unknown', @UUID_UNKNOWN_merch_t_n_family_status, 'We have no information'),
        (@UUID_sql_seed_script, 10, '2019-09-01', '2099-12-31', 'LIFESTYLE', @UUID_LIVE_merch_t_n_family_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, 20, '2019-09-01', '2099-12-31', 'DINING', @UUID_LIVE_merch_t_n_family_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, 30, '2019-09-01', '2099-12-31', 'RETAIL/SERVICES', @UUID_LIVE_merch_t_n_family_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, 1010, '2019-09-01', '2099-12-31', 'Other - LIVE', @UUID_LIVE_merch_t_n_family_status, 'This is none of the above.')
;