# What this script will do:
#
# - Create a table `db_schema_versions` to store information about the database schema version.
# - Create a trigger `uuid_db_schema_versions` to automatically generate the UUID for a new record.
# - Create a table `db_schema_versions_logs` to log all the changes in the table.
# - Create a trigger `logs_db_schema_versions_insert` to automatically log INSERT operations on the table `db_schema_versions`.
# - Create a trigger `logs_db_schema_versions_update` to automatically log UPDATE operations on the table `db_schema_versions`.
# - Create a trigger `logs_db_schema_versions_delete` to automatically log DELETE operations on the table `db_schema_versions`.
# - Insert some sample data in the table `db_schema_versions`.
# 
# Constaints:
# - The Schema version must be unique.
#
# Automations:
# - The UUID for a new record is automatically generated.
# - Logs of each changes (INSERT, UPDATE, DELETE) in this table are recorded in the table `db_schema_versions_logs`
#

# Create the table `db_schema_versions`
CREATE TABLE `db_schema_versions` (
  `uuid` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The globally unique UUID for this record',
  `schema_version` VARCHAR(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The current version of the DB schema',
  `update_datetime` TIMESTAMP NULL DEFAULT NULL COMMENT 'Timestamp - when this version was implemented in THIS environment',
  `update_script` VARCHAR(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The script we used to do the update',
  `comment` MEDIUMTEXT COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'Comment',
  PRIMARY KEY (`uuid`, `schema_version`)
) ENGINE=INNODB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC
;

# Make sure that a UUID is generated each time a new record is created in the table `db_schema_versions`.
CREATE TRIGGER `uuid_db_schema_versions`
  BEFORE INSERT ON `db_schema_versions`
  FOR EACH ROW
  SET NEW.uuid = uuid()
;

# Create the table `db_schema_versions_logs` to store the changes in the data
CREATE TABLE `db_schema_versions_logs` (
  `action` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The action that was performed on the table',
  `action_datetime` TIMESTAMP NULL DEFAULT NULL COMMENT 'Timestamp - when was the operation done',
  `uuid` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The globally unique UUID for this record',
  `schema_version` VARCHAR(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The current version of the DB schema',
  `update_datetime` TIMESTAMP NULL DEFAULT NULL COMMENT 'Timestamp - when this version was implemented in THIS environment',
  `update_script` VARCHAR(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The script we used to do the update',
  `comment` MEDIUMTEXT COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'Comment',
  KEY `db_schema_versions_uuid` (`uuid`) COMMENT 'Index the UUID for improved performances'
) ENGINE=INNODB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC
;

# After a successful INSERT in the table `db_schema_versions`
# Record all the data Inserted in the table `db_schema_versions`
# The information will be stored in the table `db_schema_versions_logs`

DELIMITER $$

CREATE TRIGGER `logs_db_schema_versions_insert` AFTER INSERT ON `db_schema_versions`
FOR EACH ROW
BEGIN
  INSERT INTO `db_schema_versions_logs` (
    `action`, 
    `action_datetime`, 
    `uuid`, 
    `schema_version`, 
    `update_datetime`, 
    `update_script`, 
    `comment`
    )
  VALUES('INSERT', NOW(), NEW.`uuid`, NEW.`schema_version`, NEW.`update_datetime`, NEW.`update_script`, NEW.`comment`)
  ;
END
$$

DELIMITER ;

# After a successful UPDATE in the table `db_schema_versions`
# Record all the values for the old record
# Record all the values for the new record
# data Inserted in the table `db_schema_versions`
# The information will be stored in the table `db_schema_versions_logs`

DELIMITER $$

CREATE TRIGGER `logs_db_schema_versions_update` AFTER UPDATE ON `db_schema_versions`
FOR EACH ROW
BEGIN
  INSERT INTO `db_schema_versions_logs` (
    `action`, 
    `action_datetime`, 
    `uuid`, 
    `schema_version`, 
    `update_datetime`, 
    `update_script`, 
    `comment`
    )
    VALUES
    ('UPDATE-OLD_VALUES', NOW(), OLD.`uuid`, OLD.`schema_version`, OLD.`update_datetime`, OLD.`update_script`, OLD.`comment`),
    ('UPDATE-NEW_VALUES', NOW(), NEW.`uuid`, NEW.`schema_version`, NEW.`update_datetime`, NEW.`update_script`, NEW.`comment`)
  ;
END
$$

DELIMITER ;

# After a successful DELETE in the table `db_schema_versions`
# Record all the values for the old record
# The information will be stored in the table `db_schema_versions_logs`

DELIMITER $$

CREATE TRIGGER `logs_db_schema_versions_delete` AFTER DELETE ON `db_schema_versions`
FOR EACH ROW
BEGIN
  INSERT INTO `db_schema_versions_logs` (
    `action`, 
    `action_datetime`, 
    `uuid`, 
    `schema_version`, 
    `update_datetime`, 
    `update_script`, 
    `comment`
    )
    VALUES
    ('DELETE', NOW(), OLD.`uuid`, OLD.`schema_version`, OLD.`update_datetime`, OLD.`update_script`, OLD.`comment`)
  ;
END
$$

DELIMITER ;

# Insert initial value in the table
INSERT  INTO `db_schema_versions`(
  `schema_version`,
  `update_datetime`,
  `update_script`,
  `comment`
  ) 
  VALUES 
    ('0.0.1',NOW(),'db_schema_versions.sql','This is the first version of the db Schema. NOT ready for PROD.')
;