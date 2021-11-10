# What this script will do:
#
# - Create a table `data_voucher_templates` to list the possible statutes for a record.
# - Create a trigger `uuid_data_voucher_templates` to automatically generate the UUID for a new record.
# - Create a table `logs_data_voucher_templates` to log all the changes in the table.
# - Create a trigger `logs_data_voucher_templates_insert` to automatically log INSERT operations on the table `data_voucher_templates`.
# - Create a trigger `logs_data_voucher_templates_update` to automatically log UPDATE operations on the table `data_voucher_templates`.
# - Create a trigger `logs_data_voucher_templates_delete` to automatically log DELETE operations on the table `data_voucher_templates`.
# - Insert some sample data in the table `data_voucher_templates`.
# 
# Constaints:
# - The designation must be unique.
# - The Interface to create the record MUST exist in the table `db_interfaces`.
# - The Interface to update the record MUST exist in the table `db_interfaces`.
# - The Product Type record MUST exist in the the table `list_product_types`.
# - The Voucher Template Type MUST exist in the table `list_voucher_template_types`.
#
# Automations and Triggers:
# - The UUID for a new record is automatically generated.
# - Logs of each changes in this table are recorded in the table `logs_data_voucher_templates`
#
# Sample data are inserted in the table:
# - Record that must exist in the table `db_interfaces`
#   - field `interface_designation`, value 'sql_seed_script'.
# - Record that must exist in the table `statuses_voucher_template`
#   - field `voucher_template_status`, value 'Unknown'.
#   - field `voucher_template_status`, value 'LIVE'.
# - Record that must exist in the table `list_voucher_template_types`
#   - field `voucher_template_type`, value 'Unknown'.
#   - field `voucher_template_type`, value 'Action Item'.
#   - field `voucher_template_type`, value 'Barcode128'.
#   - field `voucher_template_type`, value 'Barcode39'.
#   - field `voucher_template_type`, value 'QR Code'.
#   - field `voucher_template_type`, value 'Other'.
#

# Create the table `data_voucher_templates`
CREATE TABLE `data_voucher_templates` (
  `uuid` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The globally unique UUID for this record',
  `created_interface_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the interface sytem that was used to CREATE the record?',
  `created_by_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the user who created the record?',
  `created_by_ref_table` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the name of the table where we store user information?',
  `created_by_username_field` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the name of the field that stores the username associated to the userid?',
  `updated_interface_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the interface sytem that was used to UPDATE the record?',
  `updated_by_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the user who updated the record?',
  `updated_by_ref_table` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the name of the table where we store user information?',
  `updated_by_username_field` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the name of the field that stores the username associated to the userid?',
  `is_obsolete` tinyint(1) DEFAULT '0' COMMENT 'is this obsolete?',
  `order` int(10) NOT NULL DEFAULT '0' COMMENT 'Order in the list',
  `voucher_template` varchar(50) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'Designation',
  `voucher_template_status_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'What is the id of the Voucher Template Status for this Voucher Template?',
  `is_collapsible_tc` tinyint(1) DEFAULT '0' COMMENT 'Are the T&C collapsible in the Voucher Template?',
  `product_type_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the product Type for this Voucher Template?',
  `voucher_template_type_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'What is the id of the Voucher Template Type for this Voucher Template?',
  `voucher_template_description` text COLLATE utf8mb4_unicode_520_ci COMMENT 'Description/help text',
  PRIMARY KEY (`uuid`),
  UNIQUE KEY `unique_voucher_template_designation` (`voucher_template`) COMMENT 'The designation must be unique',
  KEY `voucher_template_created_interface_id` (`created_interface_id`),
  KEY `voucher_template_updated_interface_id` (`updated_interface_id`),
  KEY `voucher_template_voucher_template_status_id` (`voucher_template_status_id`),
  KEY `voucher_template_product_type_id` (`product_type_id`),
  KEY `voucher_template_voucher_template_type_id` (`voucher_template_type_id`),  
  CONSTRAINT `voucher_template_created_interface_id` FOREIGN KEY (`created_interface_id`) REFERENCES `db_interfaces` (`uuid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `voucher_template_updated_interface_id` FOREIGN KEY (`updated_interface_id`) REFERENCES `db_interfaces` (`uuid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `voucher_template_voucher_template_status_id` FOREIGN KEY (`voucher_template_status_id`) REFERENCES `statuses_voucher_template` (`uuid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `voucher_template_product_type_id` FOREIGN KEY (`product_type_id`) REFERENCES `list_product_types` (`uuid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `voucher_template_voucher_template_type_id` FOREIGN KEY (`voucher_template_type_id`) REFERENCES `list_voucher_template_types` (`uuid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC
;

# Make sure that a UUID is generated each time a new record is created in the table `data_voucher_templates`.
CREATE TRIGGER `uuid_data_voucher_templates`
  BEFORE INSERT ON `data_voucher_templates`
  FOR EACH ROW
  SET new.uuid = uuid()
;

# Create the table `logs_data_voucher_templates` to store the changes in the data
CREATE TABLE `logs_data_voucher_templates` (
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
  `is_obsolete` tinyint(1) DEFAULT '0' COMMENT 'is this obsolete?',
  `order` int(10) NOT NULL DEFAULT '0' COMMENT 'Order in the list',
  `voucher_template` varchar(50) COLLATE utf8mb4_unicode_520_ci  NOT NULL COMMENT 'Designation',
  `voucher_template_status_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'What is the id of the Voucher Template Status for this Voucher Template?',
  `is_collapsible_tc` tinyint(1) DEFAULT '0' COMMENT 'Are the T&C collapsible in the Voucher Template?',
  `product_type_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the product Type for this Voucher Template?',
  `voucher_template_type_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the Voucher Template Type for this Voucher Template?',
  `voucher_template_description` text COLLATE utf8mb4_unicode_520_ci COMMENT 'Description/help text',
  KEY `data_voucher_templates_uuid` (`uuid`) COMMENT 'Index the UUID for improved performances',
  KEY `data_voucher_templates_voucher_template_status_id` (`voucher_template_status_id`) COMMENT 'Index the `voucher_template_status_id` for improved performances',
  KEY `data_voucher_templates_product_type_id` (`product_type_id`) COMMENT 'Index the `product_type_id` for improved performances',
  KEY `data_voucher_template_type_id` (`voucher_template_type_id`) COMMENT 'Index the `voucher_template_type_id` for improved performances'
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC
;

# After a successful INSERT in the table `data_voucher_templates`
# Record all the data Inserted in the table `data_voucher_templates`
# The information will be stored in the table `logs_data_voucher_templates`

DELIMITER $$

CREATE TRIGGER `logs_data_voucher_templates_insert` AFTER INSERT ON `data_voucher_templates`
FOR EACH ROW
BEGIN
  INSERT INTO `logs_data_voucher_templates` (
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
    `is_obsolete`, 
    `order`, 
    `voucher_template`,
    `voucher_template_status_id`,
    `is_collapsible_tc`,
    `product_type_id`,
    `voucher_template_type_id`,
    `voucher_template_description`
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
      NEW.`is_obsolete`, 
      NEW.`order`, 
      NEW.`voucher_template`,
      NEW.`voucher_template_status_id`,
      NEW.`is_collapsible_tc`,
      NEW.`product_type_id`,
      NEW.`voucher_template_type_id`,
      NEW.`voucher_template_description`
    )
  ;
END
$$

DELIMITER ;

# After a successful UPDATE in the table `data_voucher_templates`
# Record all the values for the old record
# Record all the values for the new record
# data Inserted in the table `data_voucher_templates`
# The information will be stored in the table `logs_data_voucher_templates`

DELIMITER $$

CREATE TRIGGER `logs_data_voucher_templates_update` AFTER UPDATE ON `data_voucher_templates`
FOR EACH ROW
BEGIN
  INSERT INTO `logs_data_voucher_templates` (
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
    `is_obsolete`, 
    `order`, 
    `voucher_template`,
    `voucher_template_status_id`,
    `is_collapsible_tc`,
    `product_type_id`,
    `voucher_template_type_id`, 
    `voucher_template_description`
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
            OLD.`is_obsolete`, 
            OLD.`order`, 
            OLD.`voucher_template`,
            OLD.`voucher_template_status_id`,
            OLD.`is_collapsible_tc`,
            OLD.`product_type_id`,
            OLD.`voucher_template_type_id`,
            OLD.`voucher_template_description`
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
            NEW.`is_obsolete`, 
            NEW.`order`, 
            NEW.`voucher_template`,
            NEW.`voucher_template_status_id`,
            NEW.`is_collapsible_tc`,
            NEW.`product_type_id`,
            NEW.`voucher_template_type_id`,
            NEW.`voucher_template_description`
        )
    ;
END
$$

DELIMITER ;

# After a successful DELETE in the table `data_voucher_templates`
# Record all the values for the old record
# The information will be stored in the table `logs_data_voucher_templates`

DELIMITER $$

CREATE TRIGGER `logs_data_voucher_templates_delete` AFTER DELETE ON `data_voucher_templates`
FOR EACH ROW
BEGIN
  INSERT INTO `logs_data_voucher_templates` (
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
    `is_obsolete`, 
    `order`, 
    `voucher_template`,
    `voucher_template_status_id`,
    `is_collapsible_tc`,
    `product_type_id`,
    `voucher_template_type_id`, 
    `voucher_template_description`
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
            OLD.`is_obsolete`, 
            OLD.`order`, 
            OLD.`voucher_template`,
            OLD.`voucher_template_status_id`,
            OLD.`is_collapsible_tc`,
            OLD.`product_type_id`,
            OLD.`voucher_template_type_id`,
            OLD.`voucher_template_description`
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

# We need to get the uuid for the value 'UNKNOWN' in the table `statuses_voucher_template`
# We put this into the variable [@UUID_UNKNOWN_voucher_template_status]
SELECT `uuid`
    INTO @UUID_UNKNOWN_voucher_template_status
FROM `statuses_voucher_template`
    WHERE `voucher_template_status` = 'UNKNOWN'
;

# We need to get the uuid for the value 'LIVE' in the table `statuses_voucher_template`
# We put this into the variable [@UUID_LIVE_voucher_template_status]
SELECT `uuid`
    INTO @UUID_LIVE_voucher_template_status
FROM `statuses_voucher_template`
    WHERE `voucher_template_status` = 'LIVE'
;

# We need to get the uuid for the value 'Unknown' in the table `list_product_types`
# We put this into the variable [@UUID_unknown_product_type]
SELECT `uuid`
    INTO @UUID_unknown_product_type
FROM `list_product_types`
    WHERE `product_type` = 'Unknown'
;

# We need to get the uuid for the value 'Value Voucher' in the table `list_product_types`
# We put this into the variable [@UUID_value_voucher]
SELECT `uuid`
    INTO @UUID_value_voucher
FROM `list_product_types`
    WHERE `product_type` = 'Value Voucher'
;

# We need to get the uuid for the value 'Product Voucher' in the table `list_product_types`
# We put this into the variable [@UUID_product_voucher]
SELECT `uuid`
    INTO @UUID_product_voucher
FROM `list_product_types`
    WHERE `product_type` = 'Product Voucher'
;

# We need to get the uuid for the value 'Unknown' in the table `list_voucher_template_types`
# We put this into the variable [@UUID_unknown_voucher_template_type]
SELECT `uuid`
    INTO @UUID_unknown_voucher_template_type
FROM `list_voucher_template_types`
    WHERE `voucher_template_type` = 'Unknown'
;

# We need to get the uuid for the value 'Action Item' in the table `list_voucher_template_types`
# We put this into the variable [@UUID_action_item_voucher_template_type]
SELECT `uuid`
    INTO @UUID_action_item_voucher_template_type
FROM `list_voucher_template_types`
    WHERE `voucher_template_type` = 'Action Item'
;

# We need to get the uuid for the value 'Barcode128' in the table `list_voucher_template_types`
# We put this into the variable [@UUID_barcode128_voucher_template_type]
SELECT `uuid`
    INTO @UUID_barcode128_voucher_template_type
FROM `list_voucher_template_types`
    WHERE `voucher_template_type` = 'Barcode128'
;

# We need to get the uuid for the value 'Barcode39' in the table `list_voucher_template_types`
# We put this into the variable [@UUID_barcode39_voucher_template_type]
SELECT `uuid`
    INTO @UUID_barcode39_voucher_template_type
FROM `list_voucher_template_types`
    WHERE `voucher_template_type` = 'Barcode39'
;

# We need to get the uuid for the value 'QR Code' in the table `list_voucher_template_types`
# We put this into the variable [@UUID_qrcode_voucher_template_type]
SELECT `uuid`
    INTO @UUID_qrcode_voucher_template_type
FROM `list_voucher_template_types`
    WHERE `voucher_template_type` = 'QR Code'
;

# We need to get the uuid for the value 'Other' in the table `list_voucher_template_types`
# We put this into the variable [@UUID_other_voucher_template_type]
SELECT `uuid`
    INTO @UUID_other_voucher_template_type
FROM `list_voucher_template_types`
    WHERE `voucher_template_type` = 'Other'
;

# We use default values for creation of the seed data
SELECT 'db.user.running.sql.seed.script' INTO @created_by_id;
SELECT '---' INTO @created_by_ref_table;
SELECT '---' INTO @created_by_username_field;

# Insert sample values in the table
INSERT  INTO `data_voucher_templates`(
    `created_interface_id`,
    `created_by_id`,
    `created_by_ref_table`,
    `created_by_username_field`,
    `is_obsolete`, 
    `order`, 
    `voucher_template`,
    `voucher_template_status_id`,
    `is_collapsible_tc`,
    `product_type_id`,
    `voucher_template_type_id`, 
    `voucher_template_description`
    ) 
    VALUES 
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field,  0, 0, 'Unknown', @UUID_UNKNOWN_voucher_template_status, 0, @UUID_unknown_product_type, @UUID_unknown_voucher_template_type, 'We have no information on the Product Reversal Limits'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field,  0, 10, '2019 Barcode 128 - Product', @UUID_LIVE_voucher_template_status, 0, @UUID_product_voucher, @UUID_barcode128_voucher_template_type, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field,  0, 20, '2019 Barcode 128 - Value', @UUID_LIVE_voucher_template_status, 0, @UUID_value_voucher, @UUID_barcode128_voucher_template_type, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field,  0, 30, '2019 Barcode 39 - Product', @UUID_LIVE_voucher_template_status, 0, @UUID_product_voucher, @UUID_barcode39_voucher_template_type, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field,  0, 40, '2019 Barcode 39 - Value', @UUID_LIVE_voucher_template_status, 0, @UUID_value_voucher, @UUID_barcode39_voucher_template_type, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field,  0, 50, 'UQ Action Item', @UUID_LIVE_voucher_template_status, 0, @UUID_unknown_product_type, @UUID_action_item_voucher_template_type, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field,  0, 60, 'UQ Barcode 128', @UUID_LIVE_voucher_template_status, 0, @UUID_unknown_product_type, @UUID_barcode128_voucher_template_type, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field,  0, 70, 'UQ Barcode 39', @UUID_LIVE_voucher_template_status, 0, @UUID_unknown_product_type, @UUID_barcode39_voucher_template_type, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field,  0, 80, 'UQ QR Code', @UUID_LIVE_voucher_template_status, 0, @UUID_unknown_product_type, @UUID_qrcode_voucher_template_type, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field,  0, 90, 'UQ Value Base barcode 128', @UUID_LIVE_voucher_template_status, 0, @UUID_value_voucher, @UUID_barcode128_voucher_template_type, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field,  0, 100, 'UQ Value Base barcode 39', @UUID_LIVE_voucher_template_status, 0, @UUID_value_voucher, @UUID_barcode39_voucher_template_type, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field,  0, 110, 'UQ Value Base QR code', @UUID_LIVE_voucher_template_status, 0, @UUID_value_voucher, @UUID_qrcode_voucher_template_type, 'INSERT DESCRIPTION HERE'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field,  0, 120, '2020 QR Product - collapsible TC', @UUID_LIVE_voucher_template_status, 1, @UUID_product_voucher, @UUID_qrcode_voucher_template_type, '2020 QR product based template with full collapsible T & C'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field,  0, 130, '2020 QR Value - collapsible TC', @UUID_LIVE_voucher_template_status, 1, @UUID_value_voucher, @UUID_qrcode_voucher_template_type, '2020 QR value based template with full collapsible T & C'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field,  0, 140, '2020 Barcode 128 Product - collapsible TC', @UUID_LIVE_voucher_template_status, 1, @UUID_product_voucher, @UUID_barcode128_voucher_template_type, '2020 Barcode 128 Product based with full collapse T & C'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field,  0, 150, '2020 Barcode 128 Value - collapsible TC', @UUID_LIVE_voucher_template_status, 1, @UUID_value_voucher, @UUID_barcode128_voucher_template_type, '2020 Barcode 128 Value based with full collapse T & C'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field,  0, 160, '2020 Action Button - collapsible TC', @UUID_LIVE_voucher_template_status, 1, @UUID_unknown_product_type, @UUID_action_item_voucher_template_type, '2020 Action Button template with full collapse T & C'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field,  0, 170, 'OCBC Action - collapsible TC', @UUID_LIVE_voucher_template_status, 1, @UUID_unknown_product_type, @UUID_action_item_voucher_template_type, 'OCBC Action Item with full collapse of T&C'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field,  0, 180, 'OCBC product barcode 128 - collapsible TC', @UUID_LIVE_voucher_template_status, 1, @UUID_product_voucher, @UUID_barcode128_voucher_template_type, 'OCBC product based barcode 128 with full collapse of T&C'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field,  0, 190, 'OCBC product barcode 39 - collapsible TC', @UUID_LIVE_voucher_template_status, 1, @UUID_product_voucher, @UUID_barcode39_voucher_template_type, 'OCBC product based barcode 39 with full collapse of T&C'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field,  0, 200, 'OCBC product QR code - collapsible TC', @UUID_LIVE_voucher_template_status, 1, @UUID_product_voucher, @UUID_qrcode_voucher_template_type, 'OCBC product based QR code with full collapse of T&C'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field,  0, 210, 'OCBC value barcode 128 - collapsible TC', @UUID_LIVE_voucher_template_status, 1, @UUID_value_voucher, @UUID_barcode128_voucher_template_type, 'OCBC value based barcode 128 with full collapse of T & C'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field,  0, 220, 'OCBC value barcode 39 - collapsible TC', @UUID_LIVE_voucher_template_status, 1, @UUID_value_voucher, @UUID_barcode39_voucher_template_type, 'OCBC value based barcode 39 with full collapse of T & C'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field,  0, 230, 'OCBC value - collapsible TC', @UUID_LIVE_voucher_template_status, 1, @UUID_unknown_product_type, @UUID_unknown_voucher_template_type, 'OCBC value based QR code with full collapse of T&C'),
        (@UUID_sql_seed_script, @created_by_id, @created_by_ref_table, @created_by_username_field,  0, 1000, 'Other', @UUID_UNKNOWN_voucher_template_status, 0, @UUID_unknown_product_type, @UUID_unknown_voucher_template_type, 'This is none of the above.')
;