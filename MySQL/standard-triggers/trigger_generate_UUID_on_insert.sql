# This is a function to generate a trigger that will:
#   - Fire each time a new record is inserted in the table `mytable`
#   - Generate a UUID
#   - Copy the UUID in the field `uuid` in the table `mytable` (that fiel MUST exist in the table `mytable`)

CREATE TRIGGER `uuid_mytable`
  BEFORE INSERT ON `mytable`
  FOR EACH ROW
  SET new.uuid = uuid();