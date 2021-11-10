# What this script will do:
#
# - Create a table `statuses_product` to list the possible statutes for a record.
# - Create a trigger `uuid_statuses_product` to automatically generate the UUID for a new record.
# - Create a table `logs_statuses_product` to log all the changes in the table.
# - Create a trigger `logs_statuses_product_insert` to automatically log INSERT operations on the table `statuses_product`.
# - Create a trigger `logs_statuses_product_update` to automatically log UPDATE operations on the table `statuses_product`.
# - Create a trigger `logs_statuses_product_delete` to automatically log DELETE operations on the table `statuses_product`.
# - Create a view `view_statuses_product_all` to list ALL the statuses.
# - Create a view `view_statuses_product_not_obsolete` to list the statuses that are NOT obsolete.
# - Insert some sample data in the table `statuses_product`.
# 
# Constaints:
# - The status name must be unique.
# - The Interface to create the record MUST exist in the table `db_interfaces`
# - The Interface to update the record MUST exist in the table `db_interfaces`
#
# Automations and Triggers:
# - The UUID for a new record is automatically generated.
# - Logs of each changes in this table are recorded in the table `logs_statuses_product`
#
# Sample data are inserted in the table:
# - Record that must exist in the table `db_interfaces`
#   - field `interface`, value 'sql_seed_script'.
#

# Create the table `statuses_product`
CREATE TABLE `statuses_product` (
  `uuid` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The globally unique UUID for this record',
  `interface_id_creation` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the interface sytem that was used to CREATE the record?',
  `interface_id_update` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the interface sytem that was used to UPDATE the record?',
  `is_obsolete` tinyint(1) DEFAULT '0' COMMENT 'is this obsolete?',
  `order` int(10) NOT NULL DEFAULT '0' COMMENT 'Order in the list',
  `is_active` tinyint(1) DEFAULT '0' COMMENT 'This satus is considered as ACTIVE',
  `product_status` varchar(50) COLLATE utf8mb4_unicode_520_ci  NOT NULL COMMENT 'Designation',
  `product_status_description` text COLLATE utf8mb4_unicode_520_ci COMMENT 'Description/help text',
  PRIMARY KEY (`uuid`),
  UNIQUE KEY `unique_product_status_designation` (`product_status`) COMMENT 'The designation must be unique',
  KEY `product_status_interface_id_creation` (`interface_id_creation`),
  KEY `product_status_interface_id_update` (`interface_id_update`),
  CONSTRAINT `product_status_interface_id_creation` FOREIGN KEY (`interface_id_creation`) REFERENCES `db_interfaces` (`uuid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `product_status_interface_id_update` FOREIGN KEY (`interface_id_update`) REFERENCES `db_interfaces` (`uuid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC
;

# Make sure that a UUID is generated each time a new record is created in the table `statuses_product`.
CREATE TRIGGER `uuid_statuses_product`
  BEFORE INSERT ON `statuses_product`
  FOR EACH ROW
  SET new.uuid = uuid()
;

# Create the table `logs_statuses_product` to store the changes in the data
CREATE TABLE `logs_statuses_product` (
  `action` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The action that was performed on the table',
  `action_datetime` TIMESTAMP NULL DEFAULT NULL COMMENT 'Timestamp - when was the operation done',
  `uuid` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The globally unique UUID for this record',
  `interface_id_creation` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the interface sytem that was used to CREATE the record?',
  `interface_id_update` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the interface sytem that was used to UPDATE the record?',
  `is_obsolete` tinyint(1) DEFAULT '0' COMMENT 'is this obsolete?',
  `order` int(10) NOT NULL DEFAULT '0' COMMENT 'Order in the list',
  `is_active` tinyint(1) DEFAULT '0' COMMENT 'This satus is considered as ACTIVE',
  `product_status` varchar(50) COLLATE utf8mb4_unicode_520_ci  NOT NULL COMMENT 'Designation',
  `product_status_description` text COLLATE utf8mb4_unicode_520_ci COMMENT 'Description/help text',
  KEY `statuses_product_uuid` (`uuid`) COMMENT 'Index the UUID for improved performances'
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC
;

# After a successful INSERT in the table `statuses_product`
# Record all the data Inserted in the table `statuses_product`
# The information will be stored in the table `logs_statuses_product`

DELIMITER $$

CREATE TRIGGER `logs_statuses_product_insert` AFTER INSERT ON `statuses_product`
FOR EACH ROW
BEGIN
  INSERT INTO `logs_statuses_product` (
    `action`, 
    `action_datetime`, 
    `uuid`, 
    `interface_id_creation`, 
    `interface_id_update`, 
    `is_obsolete`, 
    `order`, 
    `is_active`, 
    `product_status`, 
    `product_status_description`
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
      NEW.`product_status`, 
      NEW.`product_status_description`
    )
  ;
END
$$

DELIMITER ;

# After a successful UPDATE in the table `statuses_product`
# Record all the values for the old record
# Record all the values for the new record
# data Inserted in the table `statuses_product`
# The information will be stored in the table `logs_statuses_product`

DELIMITER $$

CREATE TRIGGER `logs_statuses_product_update` AFTER UPDATE ON `statuses_product`
FOR EACH ROW
BEGIN
  INSERT INTO `logs_statuses_product` (
    `action`, 
    `action_datetime`, 
    `uuid`,  
    `interface_id_creation`, 
    `interface_id_update`, 
    `is_obsolete`, 
    `order`, 
    `is_active`, 
    `product_status`, 
    `product_status_description`
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
        OLD.`product_status`, 
        OLD.`product_status_description`
      ),
      ('UPDATE-NEW_VALUES', 
        NOW(), 
        NEW.`uuid`, 
        NEW.`interface_id_creation`, 
        NEW.`interface_id_update`, 
        NEW.`is_obsolete`, 
        NEW.`order`, 
        NEW.`is_active`, 
        NEW.`product_status`, 
        NEW.`product_status_description`
      )
  ;
END
$$

DELIMITER ;

# After a successful DELETE in the table `statuses_product`
# Record all the values for the old record
# The information will be stored in the table `logs_statuses_product`

DELIMITER $$

CREATE TRIGGER `logs_statuses_product_delete` AFTER DELETE ON `statuses_product`
FOR EACH ROW
BEGIN
  INSERT INTO `logs_statuses_product` (
    `action`, 
    `action_datetime`, 
    `uuid`, 
    `interface_id_creation`, 
    `interface_id_update`, 
    `is_obsolete`, 
    `order`, 
    `is_active`, 
    `product_status`, 
    `product_status_description`
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
          OLD.`product_status`, 
          OLD.`product_status_description`
        )
  ;
END
$$

DELIMITER ;

# Create the View for all the statuses
DROP VIEW IF EXISTS `view_statuses_product_all`;

CREATE
    VIEW `view_statuses_product_all` 
    AS
SELECT
    `uuid`
    , `product_status` AS `status`
    , `is_active`
    , `is_obsolete`
    , `order`
    , `product_status_description` AS `status_description`
FROM
    `statuses_product`
ORDER BY 
	`order` ASC
	, `status` ASC
;

# Create the View for the statuses that are NOT obsolete
DROP VIEW IF EXISTS `view_statuses_product_not_obsolete`;

CREATE
    VIEW `view_statuses_product_not_obsolete` 
    AS
SELECT
    `uuid`
    , `product_status` AS `status`
    , `is_active`
    , `is_obsolete`
    , `order`
    , `product_status_description` AS `status_description`
FROM
    `statuses_product`
WHERE (`is_obsolete` = 0)
ORDER BY 
	`order` ASC
	, `status` ASC
;

# We need to get the uuid for the value `sql_seed_script` in the table `db_interfaces`
# We put this into the variable [@UUID_sql_seed_script]
SELECT `uuid`
    INTO @UUID_sql_seed_script
FROM `db_interfaces`
    WHERE `interface` = 'sql_seed_script'
;

# Insert sample values in the table
INSERT  INTO `statuses_product`(
    `interface_id_creation`, 
    `is_obsolete`, 
    `order`, 
    `is_active`, 
    `product_status`, 
    `product_status_description`
    ) 
    VALUES 
        (@UUID_sql_seed_script, 0, 0, 0, 'UNKNOWN','We have no information about the product status. This is an INACTIVE Status'),
        (@UUID_sql_seed_script, 0, 0, 0, 'PENDING','The product has NOT been create yet. This is an INACTIVE Status'),
        (@UUID_sql_seed_script, 0, 0, 1, 'ACTIVE','The product is accepting our products. This is an ACTIVE Status'),
        (@UUID_sql_seed_script, 0, 0, 1, 'SUNSET','The product is accepting our products but we should NOT create new product for this product. This is an INACTIVE Status'),
        (@UUID_sql_seed_script, 0, 0, 0, 'INACTIVE','The product is inactive. This is an INACTIVE Status'),
        (@UUID_sql_seed_script, 0, 0, 0, 'DUPLICATE','This is a duplicate of an existing record. This is an INACTIVE Status')
;