# What this script will do:
#
# - Create a table `map_merch_trade_name_merch_cat` to list the possible relations between a merchant_trade_name and a merchant.
#   - Information about merchant_trade_names are stored in the table `data_merchant_trade_names`.
#   - Information about merchants are stored in the table `data_merchants`
# - Create a trigger `uuid_map_merch_trade_name_merch_cat` to automatically generate the UUID for a new record.
# - Create a table `logs_map_merch_trade_name_merch_cat` to log all the changes in the table.
# - Create a trigger `logs_map_merch_trade_name_merch_cat_insert` to automatically log INSERT operations on the table `map_merch_trade_name_merch_cat`.
# - Create a trigger `logs_map_merch_trade_name_merch_cat_update` to automatically log UPDATE operations on the table `map_merch_trade_name_merch_cat`.
# - Create a trigger `logs_map_merch_trade_name_merch_cat_delete` to automatically log DELETE operations on the table `map_merch_trade_name_merch_cat`.
# - Insert some sample data in the table `map_merch_trade_name_merch_cat`.
# 
# Constaints:
# - The Interface to create the record MUST exist in the table `db_interfaces`
# - The Interface to update the record MUST exist in the table `db_interfaces`
#
# Automations and Triggers:
# - The UUID for a new record is automatically generated.
# - Logs of each changes in this table are recorded in the table `logs_map_merch_trade_name_merch_cat`
#
# Sample data are inserted in the table:
#   - The table `db_interfaces` must exist in your database.
#   - A record with a value 'sql_seed_script' for the field `interface_designation` must exist in the  table `db_interfaces`.
#

# Create the table `map_merch_trade_name_merch_cat`
CREATE TABLE `map_merch_trade_name_merch_cat` (
  `uuid` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The globally unique UUID for this record',
  `interface_id_creation` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the interface sytem that was used to CREATE the record?',
  `created_by_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the user who created the record?',
  `interface_id_update` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the interface sytem that was used to UPDATE the record?',
  `updated_by_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the user who updated the record?',
  `is_obsolete` tinyint(1) DEFAULT '0' COMMENT 'is this obsolete?',
  `merch_trade_name_uuid` varchar(255) COLLATE utf8mb4_unicode_520_ci  NOT NULL COMMENT 'The UUID of the merchant_trade_name in the table `data_merchant_trade_names`',
  `merch_category_uuid` varchar(255) COLLATE utf8mb4_unicode_520_ci  NOT NULL COMMENT 'The UUID of the Merchant Category in the table `data_merchants`',
  `comment` TEXT COLLATE utf8mb4_unicode_520_ci  DEFAULT NULL COMMENT 'A comment',
  PRIMARY KEY (`merch_trade_name_uuid`, `merch_category_uuid`),
  KEY `map_merch_trade_name_merch_cat_interface_id_creation` (`interface_id_creation`),
  KEY `map_merch_trade_name_merch_cat_interface_id_update` (`interface_id_update`),
  KEY `map_merch_trade_name_merch_cat_merch_trade_name_uuid` (`merch_trade_name_uuid`),
  KEY `map_merch_trade_name_merch_cat_merch_category_uuid` (`merch_category_uuid`),
  CONSTRAINT `map_merch_trade_name_merch_cat_interface_id_creation` FOREIGN KEY (`interface_id_creation`) REFERENCES `db_interfaces` (`uuid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `map_merch_trade_name_merch_cat_interface_id_update` FOREIGN KEY (`interface_id_update`) REFERENCES `db_interfaces` (`uuid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `map_merch_trade_name_merch_cat_merch_trade_name_uuid` FOREIGN KEY (`merch_trade_name_uuid`) REFERENCES `data_merchant_trade_names` (`uuid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `map_merch_trade_name_merch_cat_merch_category_uuid` FOREIGN KEY (`merch_category_uuid`) REFERENCES `list_merchant_categories` (`uuid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC
;

# Make sure that a UUID is generated each time a new record is created in the table `map_merch_trade_name_merch_cat`.
CREATE TRIGGER `uuid_map_merch_trade_name_merch_cat`
  BEFORE INSERT ON `map_merch_trade_name_merch_cat`
  FOR EACH ROW
  SET new.uuid = uuid()
;

# Create the table `logs_map_merch_trade_name_merch_cat` to store the changes in the data
CREATE TABLE `logs_map_merch_trade_name_merch_cat` (
  `action` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The action that was performed on the table',
  `action_datetime` TIMESTAMP NULL DEFAULT NULL COMMENT 'Timestamp - when was the operation done',
  `uuid` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The globally unique UUID for this record',
  `interface_id_creation` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the interface sytem that was used to CREATE the record?',
  `created_by_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the user who created the record?',
  `interface_id_update` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the interface sytem that was used to UPDATE the record?',
  `updated_by_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the user who updated the record?',
  `is_obsolete` tinyint(1) DEFAULT '0' COMMENT 'is this obsolete?',
  `merch_trade_name_uuid` varchar(255) COLLATE utf8mb4_unicode_520_ci  NOT NULL COMMENT 'The UUID of the merchant_trade_name in the table `data_merchant_trade_names`',
  `merch_category_uuid` varchar(255) COLLATE utf8mb4_unicode_520_ci  NOT NULL COMMENT 'The UUID of the merchant category in the table `data_merchants`',
  `comment` TEXT COLLATE utf8mb4_unicode_520_ci  DEFAULT NULL COMMENT 'A comment',
  KEY `logs_map_merch_trade_name_merch_cat_uuid` (`uuid`) COMMENT 'Index the UUID for improved performances',
  KEY `logs_map_merch_trade_name_merch_cat_merch_trade_name_uuid` (`merch_trade_name_uuid`) COMMENT 'Index the merch_trade_name UUID for improved performances',
  KEY `logs_map_merch_trade_name_merch_cat_merch_category_uuid` (`merch_category_uuid`) COMMENT 'Index the merchant category UUID for improved performances'
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC
;

# After a successful INSERT in the table `map_merch_trade_name_merch_cat`
# Record all the data Inserted in the table `map_merch_trade_name_merch_cat`
# The information will be stored in the table `logs_map_merch_trade_name_merch_cat`

DELIMITER $$

CREATE TRIGGER `logs_map_merch_trade_name_merch_cat_insert` AFTER INSERT ON `map_merch_trade_name_merch_cat`
FOR EACH ROW
BEGIN
  INSERT INTO `logs_map_merch_trade_name_merch_cat` (
    `action`, 
    `action_datetime`, 
    `uuid`, 
    `interface_id_creation`, 
    `created_by_id`,
    `interface_id_update`, 
    `updated_by_id`,
    `is_obsolete`,
    `merch_trade_name_uuid`, 
    `merch_category_uuid`,
    `comment`
    )
  VALUES
    ('INSERT', 
      NOW(), 
      NEW.`uuid`, 
      NEW.`interface_id_creation`,  
      NEW.`created_by_id`,
      NEW.`interface_id_update`, 
      NEW.`updated_by_id`, 
      NEW.`is_obsolete`, 
      NEW.`merch_trade_name_uuid`, 
      NEW.`merch_category_uuid`, 
      NEW.`comment`
      )
  ;
END
$$

DELIMITER ;

# After a successful UPDATE in the table `map_merch_trade_name_merch_cat`
# Record all the values for the old record
# Record all the values for the new record
# data Inserted in the table `map_merch_trade_name_merch_cat`
# The information will be stored in the table `logs_map_merch_trade_name_merch_cat`

DELIMITER $$

CREATE TRIGGER `logs_map_merch_trade_name_merch_cat_update` AFTER UPDATE ON `map_merch_trade_name_merch_cat`
FOR EACH ROW
BEGIN
  INSERT INTO `logs_map_merch_trade_name_merch_cat` (
    `action`, 
    `action_datetime`, 
    `uuid`, 
    `interface_id_creation`, 
    `created_by_id`,
    `interface_id_update`, 
    `updated_by_id`,
    `is_obsolete`,
    `merch_trade_name_uuid`, 
    `merch_category_uuid`,
    `comment`
    )
    VALUES
        ('UPDATE-OLD_VALUES', 
            NOW(), 
            OLD.`uuid`, 
            OLD.`interface_id_creation`,  
            OLD.`created_by_id`,
            OLD.`interface_id_update`, 
            OLD.`updated_by_id`, 
            OLD.`is_obsolete`, 
            OLD.`merch_trade_name_uuid`, 
            OLD.`merch_category_uuid`, 
            OLD.`comment`
        ),
        ('UPDATE-NEW_VALUES', 
            NOW(), 
            NEW.`uuid`, 
            NEW.`interface_id_creation`,  
            NEW.`created_by_id`,
            NEW.`interface_id_update`, 
            NEW.`updated_by_id`, 
            NEW.`is_obsolete`, 
            NEW.`merch_trade_name_uuid`, 
            NEW.`merch_category_uuid`, 
            NEW.`comment`
        )
  ;
END
$$

DELIMITER ;

# After a successful DELETE in the table `map_merch_trade_name_merch_cat`
# Record all the values for the old record
# The information will be stored in the table `logs_map_merch_trade_name_merch_cat`

DELIMITER $$

CREATE TRIGGER `logs_map_merch_trade_name_merch_cat_delete` AFTER DELETE ON `map_merch_trade_name_merch_cat`
FOR EACH ROW
BEGIN
  INSERT INTO `logs_map_merch_trade_name_merch_cat` (
    `action`, 
    `action_datetime`, 
    `uuid`, 
    `interface_id_creation`, 
    `created_by_id`,
    `interface_id_update`, 
    `updated_by_id`,
    `is_obsolete`,
    `merch_trade_name_uuid`, 
    `merch_category_uuid`,
    `comment`
    )
    VALUES
        ('DELETE', 
            NOW(), 
            OLD.`uuid`, 
            OLD.`interface_id_creation`,  
            OLD.`created_by_id`,
            OLD.`interface_id_update`, 
            OLD.`updated_by_id`, 
            OLD.`is_obsolete`, 
            OLD.`merch_trade_name_uuid`, 
            OLD.`merch_category_uuid`, 
            OLD.`comment`
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

# We need to get the uuid for the `merchant_trade_name` 'Courts (Singapore)' in the table `data_merchant_trade_names`
# We put this into the variable [@UUID_merchant_trade_name_1]
SELECT `uuid`
    INTO @UUID_merchant_trade_name_1
FROM `data_merchant_trade_names`
    WHERE `merchant_trade_name` = 'Courts (Singapore)'
;

# We need to get the uuid for the `merchant_trade_name` 'Boarding Gate' in the table `data_merchant_trade_names`
# We put this into the variable [@UUID_merchant_trade_name_2]
SELECT `uuid`
    INTO @UUID_merchant_trade_name_2
FROM `data_merchant_trade_names`
    WHERE `merchant_trade_name` = 'Boarding Gate'
;

# We need to get the uuid for the `merchant_trade_name` 'The Wallet Shop' in the table `data_merchant_trade_names`
# We put this into the variable [@UUID_merchant_trade_name_3]
SELECT `uuid`
    INTO @UUID_merchant_trade_name_3
FROM `data_merchant_trade_names`
    WHERE `merchant_trade_name` = 'The Wallet Shop'
;

# We need to get the uuid for the `merchant_trade_name` 'Planet Traveller' in the table `data_merchant_trade_names`
# We put this into the variable [@UUID_merchant_trade_name_4]
SELECT `uuid`
    INTO @UUID_merchant_trade_name_4
FROM `data_merchant_trade_names`
    WHERE `merchant_trade_name` = 'Planet Traveller'
;

# We need to get the uuid for the `merchant_trade_name` 'Krispy Kreme' in the table `data_merchant_trade_names`
# We put this into the variable [@UUID_merchant_trade_name_5]
SELECT `uuid`
    INTO @UUID_merchant_trade_name_5
FROM `data_merchant_trade_names`
    WHERE `merchant_trade_name` = 'Krispy Kreme'
;

# We need to get the uuid for the `merchant_trade_name` 'Matcha 108' in the table `data_merchant_trade_names`
# We put this into the variable [@UUID_merchant_trade_name_6]
SELECT `uuid`
    INTO @UUID_merchant_trade_name_6
FROM `data_merchant_trade_names`
    WHERE `merchant_trade_name` = 'Matcha 108'
;

# We need to get the uuid for the `merchant_trade_name` 'llao llao' in the table `data_merchant_trade_names`
# We put this into the variable [@UUID_merchant_trade_name_7]
SELECT `uuid`
    INTO @UUID_merchant_trade_name_7
FROM `data_merchant_trade_names`
    WHERE `merchant_trade_name` = 'llao llao'
;

# We need to get the uuid for the `merchant_category` 'Unknown' in the table `list_merchant_categories`
# We put this into the variable [@UUID_merchant_category_unknown]
SELECT `uuid`
    INTO @UUID_merchant_category_unknown
FROM `list_merchant_categories`
    WHERE `merchant_category` = 'Unknown'
;

# We need to get the uuid for the `merchant_category` 'QSR' in the table `list_merchant_categories`
# We put this into the variable [@UUID_merchant_category_qsr]
SELECT `uuid`
    INTO @UUID_merchant_category_qsr
FROM `list_merchant_categories`
    WHERE `merchant_category` = 'QSR'
;

# We need to get the uuid for the `merchant_category` 'CSV' in the table `list_merchant_categories`
# We put this into the variable [@UUID_merchant_category_csv]
SELECT `uuid`
    INTO @UUID_merchant_category_csv
FROM `list_merchant_categories`
    WHERE `merchant_category` = 'CSV'
;

# We need to get the uuid for the `merchant_category` 'Retail' in the table `list_merchant_categories`
# We put this into the variable [@UUID_merchant_category_retail]
SELECT `uuid`
    INTO @UUID_merchant_category_retail
FROM `list_merchant_categories`
    WHERE `merchant_category` = 'Retail'
;

# We need to get the uuid for the `merchant_category` 'F&B' in the table `list_merchant_categories`
# We put this into the variable [@UUID_merchant_category_fb]
SELECT `uuid`
    INTO @UUID_merchant_category_fb
FROM `list_merchant_categories`
    WHERE `merchant_category` = 'F&B'
;

# We need to get the uuid for the `merchant_category` 'E-merchant' in the table `list_merchant_categories`
# We put this into the variable [@UUID_merchant_category_emerchant]
SELECT `uuid`
    INTO @UUID_merchant_category_emerchant
FROM `list_merchant_categories`
    WHERE `merchant_category` = 'E-merchant'
;

# We need to get the uuid for the `merchant_category` 'Other' in the table `list_merchant_categories`
# We put this into the variable [@UUID_merchant_category_other]
SELECT `uuid`
    INTO @UUID_merchant_category_other
FROM `list_merchant_categories`
    WHERE `merchant_category` = 'Other'
;

# Insert sample values in the table
INSERT  INTO `map_merch_trade_name_merch_cat`(
    `interface_id_creation`, 
    `created_by_id`,
    `merch_trade_name_uuid`, 
    `merch_category_uuid`,
    `comment`
    ) 
    VALUES 
        (@UUID_sql_seed_script, 'db.user.running.sql.seed.script', @UUID_merchant_trade_name_1, @UUID_merchant_category_unknown, 'imported from the Costing Table data'),
        (@UUID_sql_seed_script, 'db.user.running.sql.seed.script', @UUID_merchant_trade_name_2, @UUID_merchant_category_unknown, 'imported from the Costing Table data'),
        (@UUID_sql_seed_script, 'db.user.running.sql.seed.script', @UUID_merchant_trade_name_3, @UUID_merchant_category_unknown, 'imported from the Costing Table data'),
        (@UUID_sql_seed_script, 'db.user.running.sql.seed.script', @UUID_merchant_trade_name_4, @UUID_merchant_category_unknown, 'imported from the Costing Table data'),
        (@UUID_sql_seed_script, 'db.user.running.sql.seed.script', @UUID_merchant_trade_name_5, @UUID_merchant_category_unknown, 'imported from the Costing Table data'),
        (@UUID_sql_seed_script, 'db.user.running.sql.seed.script', @UUID_merchant_trade_name_6, @UUID_merchant_category_unknown, 'imported from the Costing Table data'),
        (@UUID_sql_seed_script, 'db.user.running.sql.seed.script', @UUID_merchant_trade_name_7, @UUID_merchant_category_unknown, 'imported from the Costing Table data')
;