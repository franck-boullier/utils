#
# What we want to achieve:
#
# After a successful UPDATE in the table `mytable`
# Record all the values for the old record
# Record all the values for the new record
# data Inserted in the table `mytable`
# The information will be stored in the table `mytable_logs`
#
# Pre-Requisite:
#   - the table `mytable` exists
#   - the table `mytable_logs` exists
#   - the table `mytable_logs` has a schema similar to the schema for the `mytable`
#     We have added 2 additional columns on the table `mytable_logs`:
#        - `action`
#        - `action_datetime`

DELIMITER $$

CREATE TRIGGER `logs_mytable_update` AFTER UPDATE ON `mytable`
FOR EACH ROW
BEGIN
  INSERT INTO `mytable_logs` (
    `action`, 
    `action_datetime`, 
    `data1`, 
    `data2`, 
    `data3`
    )
    VALUES
    ('UPDATE-OLD_VALUES', NOW(), OLD.`data1`, OLD.`data2`, OLD.`data3`),
    ('UPDATE-NEW_VALUES', NOW(), NEW.`data1`, NEW.`data2`, NEW.`data3`),
  ;
END
$$

DELIMITER ;