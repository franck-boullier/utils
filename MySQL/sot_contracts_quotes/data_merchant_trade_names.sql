# What this script will do:
#
# - Create a table `data_merchant_trade_names` to list the possible statutes for a record.
# - Create a trigger `uuid_data_merchant_trade_names` to automatically generate the UUID for a new record.
# - Create a table `logs_data_merchant_trade_names` to log all the changes in the table.
# - Create a trigger `logs_data_merchant_trade_names_insert` to automatically log INSERT operations on the table `data_merchant_trade_names`.
# - Create a trigger `logs_data_merchant_trade_names_update` to automatically log UPDATE operations on the table `data_merchant_trade_names`.
# - Create a trigger `logs_data_merchant_trade_names_delete` to automatically log DELETE operations on the table `data_merchant_trade_names`.
# - Insert some sample data in the table `data_merchant_trade_names`.
# 
# Constaints:
# - The status name must be unique.
# - The Interface to create the record MUST exist in the table `db_interfaces`
# - The Interface to update the record MUST exist in the table `db_interfaces`
# - The `merchant_trade_name_status` record MUST exist in the the table `statuses_merchant_trade_name`.
#
# Automations and Triggers:
# - The UUID for a new record is automatically generated.
# - Logs of each changes in this table are recorded in the table `logs_data_merchant_trade_names`
#
# Sample data are inserted in the table:
# - Record that must exist in the table `db_interfaces`
#   - field `interface_designation`, value 'sql_seed_script'.
# - Record that must exist in the table `statuses_merchant_trade_name`
#   - field `merchant_trade_name_status`, value 'Unknown'.
#   - field `merchant_trade_name_status`, value 'LIVE'.
#

# Create the table `data_merchant_trade_names`
CREATE TABLE `data_merchant_trade_names` (
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
  `merchant_trade_name` varchar(50) COLLATE utf8mb4_unicode_520_ci  NOT NULL COMMENT 'Designation',
  `merchant_trade_name_status_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'What is the status for this?',
  `merchant_trade_name_description` text COLLATE utf8mb4_unicode_520_ci COMMENT 'Description/help text',
  PRIMARY KEY (`uuid`),
  UNIQUE KEY `unique_merchant_trade_name_designation` (`merchant_trade_name`) COMMENT 'The designation must be unique',
  KEY `merchant_trade_name_created_interface_id` (`created_interface_id`),
  KEY `merchant_trade_name_updated_interface_id` (`updated_interface_id`),
  KEY `merchant_trade_name_merchant_trade_name_status_id` (`merchant_trade_name_status_id`),  
  CONSTRAINT `merchant_trade_name_created_interface_id` FOREIGN KEY (`created_interface_id`) REFERENCES `db_interfaces` (`uuid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `merchant_trade_name_updated_interface_id` FOREIGN KEY (`updated_interface_id`) REFERENCES `db_interfaces` (`uuid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `merchant_trade_name_merchant_trade_name_status_id` FOREIGN KEY (`merchant_trade_name_status_id`) REFERENCES `statuses_merchant_trade_name` (`uuid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC
;

# Make sure that a UUID is generated each time a new record is created in the table `data_merchant_trade_names`.
CREATE TRIGGER `uuid_data_merchant_trade_names`
  BEFORE INSERT ON `data_merchant_trade_names`
  FOR EACH ROW
  SET new.uuid = uuid()
;

# Create the table `logs_data_merchant_trade_names` to store the changes in the data
CREATE TABLE `logs_data_merchant_trade_names` (
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
  `merchant_trade_name` varchar(50) COLLATE utf8mb4_unicode_520_ci  NOT NULL COMMENT 'Designation',
  `merchant_trade_name_status_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the product Type for this Voucher Template?',
  `merchant_trade_name_description` text COLLATE utf8mb4_unicode_520_ci COMMENT 'Description/help text',
  KEY `data_merchant_trade_names_uuid` (`uuid`) COMMENT 'Index the UUID for improved performances'
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC
;

# After a successful INSERT in the table `data_merchant_trade_names`
# Record all the data Inserted in the table `data_merchant_trade_names`
# The information will be stored in the table `logs_data_merchant_trade_names`

DELIMITER $$

CREATE TRIGGER `logs_data_merchant_trade_names_insert` AFTER INSERT ON `data_merchant_trade_names`
FOR EACH ROW
BEGIN
  INSERT INTO `logs_data_merchant_trade_names` (
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
    `merchant_trade_name`,
    `merchant_trade_name_status_id`,
    `merchant_trade_name_description`
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
      NEW.`merchant_trade_name`, 
      NEW.`merchant_trade_name_status_id`, 
      NEW.`merchant_trade_name_description`
    )
  ;
END
$$

DELIMITER ;

# After a successful UPDATE in the table `data_merchant_trade_names`
# Record all the values for the old record
# Record all the values for the new record
# data Inserted in the table `data_merchant_trade_names`
# The information will be stored in the table `logs_data_merchant_trade_names`

DELIMITER $$

CREATE TRIGGER `logs_data_merchant_trade_names_update` AFTER UPDATE ON `data_merchant_trade_names`
FOR EACH ROW
BEGIN
  INSERT INTO `logs_data_merchant_trade_names` (
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
    `merchant_trade_name`,
    `merchant_trade_name_status_id`, 
    `merchant_trade_name_description`
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
        OLD.`merchant_trade_name`, 
        OLD.`merchant_trade_name_status_id`, 
        OLD.`merchant_trade_name_description`
      ),  
      ('UPDATE-NEW_VALUES', 
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
        NEW.`merchant_trade_name`, 
        NEW.`merchant_trade_name_status_id`, 
        NEW.`merchant_trade_name_description`
      )
  ;
END
$$

DELIMITER ;

# After a successful DELETE in the table `data_merchant_trade_names`
# Record all the values for the old record
# The information will be stored in the table `logs_data_merchant_trade_names`

DELIMITER $$

CREATE TRIGGER `logs_data_merchant_trade_names_delete` AFTER DELETE ON `data_merchant_trade_names`
FOR EACH ROW
BEGIN
  INSERT INTO `logs_data_merchant_trade_names` (
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
    `merchant_trade_name`,
    `merchant_trade_name_status_id`, 
    `merchant_trade_name_description`
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
        OLD.`merchant_trade_name`, 
        OLD.`merchant_trade_name_status_id`, 
        OLD.`merchant_trade_name_description`
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

# We need to get the uuid for the value 'UNKNOWN' in the table `statuses_merchant_trade_name`
# We put this into the variable [@UUID_UNKNOWN_merchant_trade_name_status]
SELECT `uuid`
    INTO @UUID_UNKNOWN_merchant_trade_name_status
FROM `statuses_merchant_trade_name`
    WHERE `merchant_trade_name_status` = 'UNKNOWN'
;

# We need to get the uuid for the value 'LIVE' in the table `statuses_merchant_trade_name`
# We put this into the variable [@UUID_LIVE_merchant_trade_name_status]
SELECT `uuid`
    INTO @UUID_LIVE_merchant_trade_name_status
FROM `statuses_merchant_trade_name`
    WHERE `merchant_trade_name_status` = 'LIVE'
;

# We use default values for creation of the seed data
SELECT 'db.user.running.sql.seed.script' INTO @created_by_id;
SELECT '---' INTO @created_by_ref_table;
SELECT '---' INTO @created_by_username_field;

# Insert sample values in the table
INSERT  INTO `data_merchant_trade_names`(
    `created_interface_id`,
    `created_by_id`,
    `created_by_ref_table`,
    `created_by_username_field`,
    `order`, 
    `merchant_trade_name`,
    `merchant_trade_name_status_id`, 
    `merchant_trade_name_description`
    ) 
    VALUES 
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 0, 'Unknown', @UUID_UNKNOWN_merchant_trade_name_status, 'We have no information'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'Al-Futtaim', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'Andersen s of Denmark Ice Cream', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'Big Fish Small Fish', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'Boarding Gate', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'Carousel', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'Coca Restaurants', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'Commons', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'Courts (Singapore)', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'Creative Eateries', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'DMK', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'Dunkin Donuts', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'Earle Swensen s', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'Fragrance', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'GNC', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'Gong Cha', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'Gyu & Tori', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'Haagen-Dazs', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'Java+', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'Jay Gee Enterprises', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'Jay Gee Health', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'Knots Café & Living', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'Krispy Kreme', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'Lifescan Medical Centre', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'llao llao', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'Lobby Lounge', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'LSC Eye Clinic', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'Luminous Dental Group', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'Manekineko', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'Marche Movenpick', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'Marriott Café', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'Matcha 108', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'Motherswork', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'Nanyang Optical', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'New Ubin Seafood', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'OSIM', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'PastaMania', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'Pet Lovers Centre', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'Pezzo', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'Pizza Maru', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'Planet Traveller', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'PUMA', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'Royal Palm at Orchid Country Club', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'Seoul Garden', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'Seoul Garden HotPot', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'Seoul Yummy', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'Shell', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'Spectacle Hut', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'Swensen s', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'The Cocoa Trees', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'The Connoisseur Concerto (TCC)', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'The Dental Studio', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'The Landmark', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'The Swatch Group', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'The Wallet Shop', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'Times Experience', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'Toast Box', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'Tokyu Hands', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'Tuk Tuk Cha', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'Tung Lok Group', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'UFC Gym', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'Under Armour', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'Vincent Watch', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'Wan Shao Chinese Resturant', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 10, 'Xpressflower', @UUID_LIVE_merchant_trade_name_status , 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 1000, 'Other - UNKNOWN', @UUID_UNKNOWN_merchant_trade_name_status, 'This is none of the above.'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 1010, 'Other - LIVE', @UUID_LIVE_merchant_trade_name_status, 'This is none of the above.')
;