# What this script will do:
#
# - Create a table `data_merchants` to list the possible statutes for a record.
# - Create a trigger `uuid_data_merchants` to automatically generate the UUID for a new record.
# - Create a table `logs_data_merchants` to log all the changes in the table.
# - Create a trigger `logs_data_merchants_insert` to automatically log INSERT operations on the table `data_merchants`.
# - Create a trigger `logs_data_merchants_update` to automatically log UPDATE operations on the table `data_merchants`.
# - Create a trigger `logs_data_merchants_delete` to automatically log DELETE operations on the table `data_merchants`.
# - Insert some sample data in the table `data_merchants`.
# 
# Constaints:
# - The designation must be unique.
# - The Interface to create the record MUST exist in the table `db_interfaces`
# - The Interface to update the record MUST exist in the table `db_interfaces`
# - The `merchant_status` record MUST exist in the the table `statuses_merchant`.
#
# Automations and Triggers:
# - The UUID for a new record is automatically generated.
# - Logs of each changes in this table are recorded in the table `logs_data_merchants`
#
# Sample data are inserted in the table:
# - Record that must exist in the table `db_interfaces`
#   - field `interface_designation`, value 'sql_seed_script'.
# - Record that must exist in the table `statuses_merchant`
#   - field `merchant_status`, value 'Unknown'.
#   - field `merchant_status`, value 'LIVE'.
#

# Create the table `data_merchants`
CREATE TABLE `data_merchants` (
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
  `merchant` varchar(50) COLLATE utf8mb4_unicode_520_ci  NOT NULL COMMENT 'Designation',
  `merchant_category_id_for_tx2` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'What is merchant category that we will select in TicketXpress/Move for this merchant?',
  `merchant_status_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'What is the status for this?',
  `merchant_uen` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The Singapore UEN for the legal entity associated to that merchant',
  `merchant_description` text COLLATE utf8mb4_unicode_520_ci COMMENT 'Description/help text',
  PRIMARY KEY (`uuid`),
  UNIQUE KEY `unique_merchant_designation` (`merchant`) COMMENT 'The designation must be unique',
  KEY `merchant_created_interface_id` (`created_interface_id`),
  KEY `merchant_updated_interface_id` (`updated_interface_id`),
  KEY `merchant_merchant_category_id_for_tx2` (`merchant_category_id_for_tx2`),
  KEY `merchant_merchant_status_id` (`merchant_status_id`),  
  CONSTRAINT `merchant_created_interface_id` FOREIGN KEY (`created_interface_id`) REFERENCES `db_interfaces` (`uuid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `merchant_updated_interface_id` FOREIGN KEY (`updated_interface_id`) REFERENCES `db_interfaces` (`uuid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `merchant_merchant_category_id_for_tx2` FOREIGN KEY (`merchant_category_id_for_tx2`) REFERENCES `list_merchant_categories` (`uuid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `merchant_merchant_status_id` FOREIGN KEY (`merchant_status_id`) REFERENCES `statuses_merchant` (`uuid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC
;

# Make sure that a UUID is generated each time a new record is created in the table `data_merchants`.
CREATE TRIGGER `uuid_data_merchants`
  BEFORE INSERT ON `data_merchants`
  FOR EACH ROW
  SET new.uuid = uuid()
;

# Create the table `logs_data_merchants` to store the changes in the data
# We first drop the table in case is exists

CREATE TABLE `logs_data_merchants` (
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
  `merchant` varchar(50) COLLATE utf8mb4_unicode_520_ci  NOT NULL COMMENT 'Designation',
  `merchant_category_id_for_tx2` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'What is merchant category that we will select in TicketXpress/Move for this merchant?',
  `merchant_status_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the product Type for this Voucher Template?',
  `merchant_uen` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The Singapore UEN for the legal entity associated to that merchant',
  `merchant_description` text COLLATE utf8mb4_unicode_520_ci COMMENT 'Description/help text',
  KEY `data_merchants_uuid` (`uuid`) COMMENT 'Index the UUID for improved performances'
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC
;

# After a successful INSERT in the table `data_merchants`
# Record all the data Inserted in the table `data_merchants`
# The information will be stored in the table `logs_data_merchants`

DELIMITER $$

CREATE TRIGGER `logs_data_merchants_insert` AFTER INSERT ON `data_merchants`
FOR EACH ROW
BEGIN
  INSERT INTO `logs_data_merchants` (
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
    `merchant`,
    `merchant_category_id_for_tx2`,
    `merchant_status_id`,
    `merchant_uen`,
    `merchant_description`
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
      NEW.`merchant`, 
      NEW.`merchant_category_id_for_tx2`, 
      NEW.`merchant_status_id`,
      NEW.`merchant_uen`, 
      NEW.`merchant_description`
    )
  ;
END
$$

DELIMITER ;

# After a successful UPDATE in the table `data_merchants`
# Record all the values for the old record
# Record all the values for the new record
# data Inserted in the table `data_merchants`
# The information will be stored in the table `logs_data_merchants`

DELIMITER $$

CREATE TRIGGER `logs_data_merchants_update` AFTER UPDATE ON `data_merchants`
FOR EACH ROW
BEGIN
  INSERT INTO `logs_data_merchants` (
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
    `merchant`,
    `merchant_category_id_for_tx2`,
    `merchant_status_id`, 
    `merchant_uen`,
    `merchant_description`
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
        OLD.`merchant`, 
        OLD.`merchant_category_id_for_tx2`, 
        OLD.`merchant_status_id`,
        OLD.`merchant_uen`, 
        OLD.`merchant_description`
      ),
      ('UPDATE-NEW_VALUES', 
        NOW(), 
        NEW.`uuid`, 
        NEW.`created_by_id`,
        NEW.`created_by_ref_table`,
        NEW.`created_by_username_field`,
        NEW.`updated_interface_id`, 
        NEW.`updated_by_id`,
        NEW.`updated_by_ref_table`,
        NEW.`updated_by_username_field`, 
        NEW.`order`, 
        NEW.`merchant`,  
        NEW.`merchant_category_id_for_tx2`, 
        NEW.`merchant_status_id`,
        NEW.`merchant_uen`, 
        NEW.`merchant_description`
      )
  ;
END
$$

DELIMITER ;

# After a successful DELETE in the table `data_merchants`
# Record all the values for the old record
# The information will be stored in the table `logs_data_merchants`

DELIMITER $$

CREATE TRIGGER `logs_data_merchants_delete` AFTER DELETE ON `data_merchants`
FOR EACH ROW
BEGIN
  INSERT INTO `logs_data_merchants` (
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
    `merchant`,
    `merchant_category_id_for_tx2`,
    `merchant_status_id`,
    `merchant_uen`, 
    `merchant_description`
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
        OLD.`merchant`, 
        OLD.`merchant_category_id_for_tx2`, 
        OLD.`merchant_status_id`,
        OLD.`merchant_uen`, 
        OLD.`merchant_description`
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

# We need to get the uuid for the `merchant_category` 'Unknown' in the table `list_merchant_categories`
# We put this into the variable [@UUID_merchant_category_Unknown]
SELECT `uuid`
    INTO @UUID_merchant_category_Unknown
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

# We need to get the uuid for the value 'UNKNOWN' in the table `statuses_merchant`
# We put this into the variable [@UUID_UNKNOWN_merchant_status]
SELECT `uuid`
    INTO @UUID_UNKNOWN_merchant_status
FROM `statuses_merchant`
    WHERE `merchant_status` = 'UNKNOWN'
;

# We need to get the uuid for the value 'LIVE' in the table `statuses_merchant`
# We put this into the variable [@UUID_LIVE_merchant_status]
SELECT `uuid`
    INTO @UUID_LIVE_merchant_status
FROM `statuses_merchant`
    WHERE `merchant_status` = 'LIVE'
;

# We use default values for creation of the seed data
SELECT 'db.user.running.sql.seed.script' INTO @created_by_id;
SELECT '---' INTO @created_by_ref_table;
SELECT '---' INTO @created_by_username_field;

# Insert sample values in the table
INSERT  INTO `data_merchants`(
    `created_interface_id`,
    `created_by_id`,
    `created_by_ref_table`,
    `created_by_username_field`,
    `order`, 
    `merchant`,
    `merchant_category_id_for_tx2`,
    `merchant_status_id`, 
    `merchant_description`
    ) 
    VALUES 
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 0, 'Unknown', @UUID_merchant_category_unknown, @UUID_UNKNOWN_merchant_status, 'We have no information'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 0, 'ABR Holdings Limited', @UUID_merchant_category_unknown, @UUID_LIVE_merchant_status, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 0, 'Bencoolen Enterprises Pte Ltd', @UUID_merchant_category_unknown, @UUID_LIVE_merchant_status, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 0, 'BreadTalk Pte Ltd', @UUID_merchant_category_unknown, @UUID_LIVE_merchant_status, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 0, 'COCA International Singapore Co Pte Ltd', @UUID_merchant_category_unknown, @UUID_LIVE_merchant_status, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 0, 'Commonwealth Retail Concepts Pte Ltd', @UUID_merchant_category_unknown, @UUID_LIVE_merchant_status, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 0, 'Courts (Singapore)', @UUID_merchant_category_unknown, @UUID_LIVE_merchant_status, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 0, 'Creative Eateries', @UUID_merchant_category_unknown, @UUID_LIVE_merchant_status, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 0, 'DMK (Singapore) Pte Ltd', @UUID_merchant_category_unknown, @UUID_LIVE_merchant_status, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 0, 'Focus Network Agencies (S) Pte Ltd', @UUID_merchant_category_unknown, @UUID_LIVE_merchant_status, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 0, 'Fragrance Foodstuff Pte Ltd', @UUID_merchant_category_unknown, @UUID_LIVE_merchant_status, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 0, 'General Mills Singapore Pte Ltd', @UUID_merchant_category_unknown, @UUID_LIVE_merchant_status, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 0, 'Golden Donuts Pte Ltd', @UUID_merchant_category_unknown, @UUID_LIVE_merchant_status, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 0, 'Gong Cha Singapore Pte Ltd', @UUID_merchant_category_unknown, @UUID_LIVE_merchant_status, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 0, 'Gratify Group Pte Ltd', @UUID_merchant_category_unknown, @UUID_LIVE_merchant_status, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 0, 'Jay Gee Enterprises Pte Ltd', @UUID_merchant_category_unknown, @UUID_LIVE_merchant_status, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 0, 'Jay Gee Health Pte Ltd', @UUID_merchant_category_unknown, @UUID_LIVE_merchant_status, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 0, 'Koshidaka Singapore Pte Ltd', @UUID_merchant_category_unknown, @UUID_LIVE_merchant_status, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 0, 'Luminous Group Dental Holdings Pte Ltd', @UUID_merchant_category_unknown, @UUID_LIVE_merchant_status, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 0, 'Manna 360 Pte Ltd', @UUID_merchant_category_unknown, @UUID_LIVE_merchant_status, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 0, 'Marche Resturants Singapore Pte Ltd', @UUID_merchant_category_unknown, @UUID_LIVE_merchant_status, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 0, 'Miracle Food Delight Pte Ltd', @UUID_merchant_category_unknown, @UUID_LIVE_merchant_status, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 0, 'Motherswork Pte Ltd', @UUID_merchant_category_unknown, @UUID_LIVE_merchant_status, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 0, 'Nanyang Optical Co. Pte Ltd', @UUID_merchant_category_unknown, @UUID_LIVE_merchant_status, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 0, 'New Ubin Seafood Projects Pte Ltd', @UUID_merchant_category_unknown, @UUID_LIVE_merchant_status, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 0, 'NF Gym Pte. Ltd', @UUID_merchant_category_unknown, @UUID_LIVE_merchant_status, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 0, 'ONI Global Pte Ltd', @UUID_merchant_category_unknown, @UUID_LIVE_merchant_status, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 0, 'OSIM International Pte Ltd', @UUID_merchant_category_unknown, @UUID_LIVE_merchant_status, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 0, 'Pet Lover Centre Pte Ltd', @UUID_merchant_category_unknown, @UUID_LIVE_merchant_status, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 0, 'Pezzo Singapore Pte Ltd', @UUID_merchant_category_unknown, @UUID_LIVE_merchant_status, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 0, 'PUMA Sports SEA Trading Pte Ltd ', @UUID_merchant_category_unknown, @UUID_LIVE_merchant_status, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 0, 'Riverview Tandoor Pte Ltd', @UUID_merchant_category_unknown, @UUID_LIVE_merchant_status, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 0, 'Robinson & Company (Singapore) Pte Ltd', @UUID_merchant_category_unknown, @UUID_LIVE_merchant_status, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 0, 'Royal Plaza ', @UUID_merchant_category_unknown, @UUID_LIVE_merchant_status, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 0, 'Sarika Connoisseur Café Pte Ltd', @UUID_merchant_category_unknown, @UUID_LIVE_merchant_status, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 0, 'Seager Inc. Pte Ltd', @UUID_merchant_category_unknown, @UUID_LIVE_merchant_status, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 0, 'Shell Eastern Petroleum Pte Ltd', @UUID_merchant_category_unknown, @UUID_LIVE_merchant_status, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 0, 'Singapore Hospitality Group', @UUID_merchant_category_unknown, @UUID_LIVE_merchant_status, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 0, 'Singapore Marriott Tang Plaza', @UUID_merchant_category_unknown, @UUID_LIVE_merchant_status, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 0, 'Spectacle Hut Pte Ltd', @UUID_merchant_category_unknown, @UUID_LIVE_merchant_status, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 0, 'The Swatch Group S.E.A. (S) Pte Ltd', @UUID_merchant_category_unknown, @UUID_LIVE_merchant_status, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 0, 'Times Experience Pte Ltd', @UUID_merchant_category_unknown, @UUID_LIVE_merchant_status, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 0, 'Tokyu Hands Singapore Pte Ltd', @UUID_merchant_category_unknown, @UUID_LIVE_merchant_status, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 0, 'Tuk Tuk Cha (S) Pte Ltd', @UUID_merchant_category_unknown, @UUID_LIVE_merchant_status, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 0, 'Tung Lok Millennium Pte Ltd', @UUID_merchant_category_unknown, @UUID_LIVE_merchant_status, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 0, 'Vincent Watch Pte Ltd', @UUID_merchant_category_unknown, @UUID_LIVE_merchant_status, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 0, 'Wagyu & Rotisserie Pte Ltd', @UUID_merchant_category_unknown, @UUID_LIVE_merchant_status, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 0, 'Xpressflowers.com Pte Ltd', @UUID_merchant_category_unknown, @UUID_LIVE_merchant_status, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 0, 'Zingrill Holdings Pte Ltd', @UUID_merchant_category_unknown, @UUID_LIVE_merchant_status, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 1000, 'Other - UNKNOWN', @UUID_merchant_category_unknown, @UUID_UNKNOWN_merchant_status, 'This is none of the above.'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field, 1010, 'Other - LIVE', @UUID_merchant_category_unknown, @UUID_LIVE_merchant_status, 'This is none of the above.')
;