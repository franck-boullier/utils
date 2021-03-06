# What this script will do:
#
# - Create a table `list_product_categories` to list the possible statutes for a record.
# - Create a trigger `uuid_list_product_categories` to automatically generate the UUID for a new record.
# - Create a table `logs_list_product_categories` to log all the changes in the table.
# - Create a trigger `logs_list_product_categories_insert` to automatically log INSERT operations on the table `list_product_categories`.
# - Create a trigger `logs_list_product_categories_update` to automatically log UPDATE operations on the table `list_product_categories`.
# - Create a trigger `logs_list_product_categories_delete` to automatically log DELETE operations on the table `list_product_categories`.
# - Insert some sample data in the table `list_product_categories`.
# 
# Constaints:
# - The status name must be unique.
# - The Interface to create the record MUST exist in the table `db_interfaces`
# - The Interface to update the record MUST exist in the table `db_interfaces`
#
# Automations and Triggers:
# - The UUID for a new record is automatically generated.
# - Logs of each changes in this table are recorded in the table `logs_list_product_categories`
#
# Sample data are inserted in the table:
# - Record that must exist in the table `db_interfaces`
#   - field `interface`, value 'sql_seed_script'.
#

# Create the table `list_product_categories`
CREATE TABLE `list_product_categories` (
  `uuid` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The globally unique UUID for this record',
  `created_interface_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the interface sytem that was used to CREATE the record?',
  `updated_interface_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the interface sytem that was used to UPDATE the record?',
  `is_obsolete` tinyint(1) DEFAULT '0' COMMENT 'is this obsolete?',
  `order` int(10) NOT NULL DEFAULT '0' COMMENT 'Order in the list',
  `product_category` varchar(50) COLLATE utf8mb4_unicode_520_ci  NOT NULL COMMENT 'Designation',
  `product_category_description` text COLLATE utf8mb4_unicode_520_ci COMMENT 'Description/help text',
  PRIMARY KEY (`uuid`),
  UNIQUE KEY `unique_product_category_designation` (`product_category`) COMMENT 'The designation must be unique',
  KEY `product_category_created_interface_id` (`created_interface_id`),
  KEY `product_category_updated_interface_id` (`updated_interface_id`),
  CONSTRAINT `product_category_created_interface_id` FOREIGN KEY (`created_interface_id`) REFERENCES `db_interfaces` (`uuid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `product_category_updated_interface_id` FOREIGN KEY (`updated_interface_id`) REFERENCES `db_interfaces` (`uuid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC
;

# Make sure that a UUID is generated each time a new record is created in the table `list_product_categories`.
CREATE TRIGGER `uuid_list_product_categories`
  BEFORE INSERT ON `list_product_categories`
  FOR EACH ROW
  SET new.uuid = uuid()
;

# Create the table `logs_list_product_categories` to store the changes in the data
CREATE TABLE `logs_list_product_categories` (
  `action` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The action that was performed on the table',
  `action_datetime` TIMESTAMP NULL DEFAULT NULL COMMENT 'Timestamp - when was the operation done',
  `uuid` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The globally unique UUID for this record',
  `created_interface_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the interface sytem that was used to CREATE the record?',
  `updated_interface_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the interface sytem that was used to UPDATE the record?',
  `is_obsolete` tinyint(1) DEFAULT '0' COMMENT 'is this obsolete?',
  `order` int(10) NOT NULL DEFAULT '0' COMMENT 'Order in the list',
  `product_category` varchar(50) COLLATE utf8mb4_unicode_520_ci  NOT NULL COMMENT 'Designation',
  `product_category_description` text COLLATE utf8mb4_unicode_520_ci COMMENT 'Description/help text',
  KEY `list_product_categories_uuid` (`uuid`) COMMENT 'Index the UUID for improved performances'
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC
;

# After a successful INSERT in the table `list_product_categories`
# Record all the data Inserted in the table `list_product_categories`
# The information will be stored in the table `logs_list_product_categories`

DELIMITER $$

CREATE TRIGGER `logs_list_product_categories_insert` AFTER INSERT ON `list_product_categories`
FOR EACH ROW
BEGIN
  INSERT INTO `logs_list_product_categories` (
    `action`, 
    `action_datetime`, 
    `uuid`, 
    `created_interface_id`, 
    `updated_interface_id`, 
    `is_obsolete`, 
    `order`, 
    `product_category`, 
    `product_category_description`
    )
  VALUES
    ('INSERT', 
      NOW(), 
      NEW.`uuid`, 
      NEW.`created_interface_id`, 
      NEW.`updated_interface_id`, 
      NEW.`is_obsolete`, 
      NEW.`order`, 
      NEW.`product_category`, 
      NEW.`product_category_description`
    )
  ;
END
$$

DELIMITER ;

# After a successful UPDATE in the table `list_product_categories`
# Record all the values for the old record
# Record all the values for the new record
# data Inserted in the table `list_product_categories`
# The information will be stored in the table `logs_list_product_categories`

DELIMITER $$

CREATE TRIGGER `logs_list_product_categories_update` AFTER UPDATE ON `list_product_categories`
FOR EACH ROW
BEGIN
  INSERT INTO `logs_list_product_categories` (
    `action`, 
    `action_datetime`, 
    `uuid`,  
    `created_interface_id`, 
    `updated_interface_id`, 
    `is_obsolete`, 
    `order`, 
    `product_category`, 
    `product_category_description`
    )
    VALUES
      ('UPDATE-OLD_VALUES', 
        NOW(), 
        OLD.`uuid`, 
        OLD.`created_interface_id`, 
        OLD.`updated_interface_id`, 
        OLD.`is_obsolete`, 
        OLD.`order`, 
        OLD.`product_category`, 
        OLD.`product_category_description`
      ),
      ('UPDATE-NEW_VALUES', 
        NOW(), 
        NEW.`uuid`, 
        NEW.`created_interface_id`, 
        NEW.`updated_interface_id`, 
        NEW.`is_obsolete`, 
        NEW.`order`, 
        NEW.`product_category`, 
        NEW.`product_category_description`
      )
  ;
END
$$

DELIMITER ;

# After a successful DELETE in the table `list_product_categories`
# Record all the values for the old record
# The information will be stored in the table `logs_list_product_categories`

DELIMITER $$

CREATE TRIGGER `logs_list_product_categories_delete` AFTER DELETE ON `list_product_categories`
FOR EACH ROW
BEGIN
  INSERT INTO `logs_list_product_categories` (
    `action`, 
    `action_datetime`, 
    `uuid`, 
    `created_interface_id`, 
    `updated_interface_id`, 
    `is_obsolete`, 
    `order`, 
    `product_category`, 
    `product_category_description`
    )
    VALUES
      ('DELETE', 
          NOW(), 
          OLD.`uuid`, 
          OLD.`created_interface_id`, 
          OLD.`updated_interface_id`, 
          OLD.`is_obsolete`, 
          OLD.`order`, 
          OLD.`product_category`, 
          OLD.`product_category_description`
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
INSERT  INTO `list_product_categories`(
    `created_interface_id`, 
    `is_obsolete`, 
    `order`, 
    `product_category`, 
    `product_category_description`
    ) 
    VALUES 
        (@UUID_sql_seed_script, 0, 0, 'Unknown','We have no information on the Product Reversal Limits'),
        (@UUID_sql_seed_script, 0, 10, 'BAU','Business As Usual - The product that we can sell `AS IS`'),
        (@UUID_sql_seed_script, 0, 20, 'Programs','INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, 0, 30, 'Deals','INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, 0, 40, 'OCBC Stack','INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, 0, 1000, 'Other','This is none of the above.')
;