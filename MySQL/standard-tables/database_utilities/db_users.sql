# What this script will do:
#
# - Create a table `db_users` to list the users that are allowed to interact and connect with this database.
# - Create a trigger `uuid_db_users` to automatically generate the UUID for a new record.
# - Create a table `logs_db_users` to log all the changes in the table.
# - Create a trigger `logs_db_users_insert` to automatically log INSERT operations on the table `db_users`.
# - Create a trigger `logs_db_users_update` to automatically log UPDATE operations on the table `db_users`.
# - Create a trigger `logs_db_users_delete` to automatically log DELETE operations on the table `db_users`.
# - Insert some sample data in the table `db_users`.
# 
# Constaints:
# - The user designation must be unique.
#
# Automations and Triggers:
# - The UUID for a new record is automatically generated.
# - Logs of each changes in this table are recorded in the table `logs_db_users`
#

# Create the table `db_users`
CREATE TABLE `db_users` (
  `uuid` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The globally unique UUID for this record',
  `is_obsolete` tinyint(1) DEFAULT '0' COMMENT 'is this obsolete?',
  `order` int(10) NOT NULL DEFAULT '0' COMMENT 'Order in the list',
  `user` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'Designation',
  `user_description` text COLLATE utf8mb4_unicode_520_ci COMMENT 'Description/help text)',
  PRIMARY KEY (`uuid`),
  UNIQUE KEY `unique_user_designation` (`user`) COMMENT 'The designation must be unique'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC
;

# Make sure that a UUID is generated each time a new record is created in the table `db_users`.
CREATE TRIGGER `uuid_db_users`
  BEFORE INSERT ON `db_users`
  FOR EACH ROW
  SET new.uuid = uuid()
;

# Create the table `logs_db_users` to store the changes in the data
CREATE TABLE `logs_db_users` (
  `action` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The action that was performed on the table',
  `action_datetime` TIMESTAMP NULL DEFAULT NULL COMMENT 'Timestamp - when was the operation done',
  `uuid` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The globally unique UUID for this record',
  `is_obsolete` tinyint(1) DEFAULT '0' COMMENT 'is this obsolete?',
  `order` int(10) NOT NULL DEFAULT '0' COMMENT 'Order in the list',
  `user` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'Designation',
  `user_description` text COLLATE utf8mb4_unicode_520_ci COMMENT 'Description/help text)',
  KEY `db_users_uuid` (`uuid`) COMMENT 'Index the UUID for improved performances'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC
;

# After a successful INSERT in the table `db_users`
# Record all the data Inserted in the table `db_users`
# The information will be stored in the table `logs_db_users`

DELIMITER $$

CREATE TRIGGER `logs_db_users_insert` AFTER INSERT ON `db_users`
FOR EACH ROW
BEGIN
  INSERT INTO `logs_db_users` (
    `action`, 
    `action_datetime`, 
    `uuid`, 
    `is_obsolete`, 
    `order`, 
    `user`, 
    `user_description`
    )
  VALUES
    ('INSERT', 
      NOW(), 
      NEW.`uuid`, 
      NEW.`is_obsolete`,
      NEW.`order`,
      NEW.`user`,
      NEW.`user_description`
      )
  ;
END
$$

DELIMITER ;

# After a successful UPDATE in the table `db_users`
# Record all the values for the old record
# Record all the values for the new record
# data Inserted in the table `db_users`
# The information will be stored in the table `logs_db_users`

DELIMITER $$

CREATE TRIGGER `logs_db_users_update` AFTER UPDATE ON `db_users`
FOR EACH ROW
BEGIN
  INSERT INTO `logs_db_users` (
    `action`, 
    `action_datetime`, 
    `uuid`, 
    `is_obsolete`, 
    `order`, 
    `user`, 
    `user_description`
    )
    VALUES
      ('UPDATE-OLD_VALUES', 
        NOW(), 
        OLD.`uuid`, 
        OLD.`is_obsolete`,
        OLD.`order`,
        OLD.`user`,
        OLD.`user_description`
        ),
      ('UPDATE-NEW_VALUES', 
        NOW(), 
        NEW.`uuid`, 
        NEW.`is_obsolete`,
        NEW.`order`,
        NEW.`user`,
        NEW.`user_description`
        )
  ;
END
$$

DELIMITER ;

# After a successful DELETE in the table `db_users`
# Record all the values for the old record
# The information will be stored in the table `logs_db_users`

DELIMITER $$

CREATE TRIGGER `logs_db_users_delete` AFTER DELETE ON `db_users`
FOR EACH ROW
BEGIN
  INSERT INTO `logs_db_users` (
    `action`, 
    `action_datetime`, 
    `uuid`, 
    `is_obsolete`, 
    `order`, 
    `user`, 
    `user_description`
    )
    VALUES
    ('DELETE', 
      NOW(), 
      OLD.`uuid`, 
      OLD.`is_obsolete`,
      OLD.`order`,
      OLD.`user`,
      OLD.`user_description`
      )
  ;
END
$$

DELIMITER ;

# Insert sample values in the table
INSERT  INTO `db_users`
    (`order`
      ,`user`
      ,`user_description`
    ) 
    VALUES 
      (0,
        'root'
        ,'the root user for the database instance.'
      ),
      (10,
        'php.runner',
        'The Db user we have created for interfaces built with phprunner. Can only READ the logs_xxx tables.'
      ),
      (20,
        'view.lists',
        'Can wiew all the `list_xxx` tables and the related views.'
      ),
      (30,
        'view.statuses',
        'Can wiew all the `satuses_xxx` tables and the related views.'
      ),
      (40,
        'view.data',
        'Can ONLY wiew all the tables and the related views.'
      )
;