# Overview:

How to use the script `auto_create_table.sh`

# What This Script Does:

- This script uses a [`config`](#the-config-file) file as an input file.
- Use the variable `collation` to determine the collation to use when creating a record.
- Uses variables set in the [`config`](#the-config-file).
    - Define the prefix `tablePrefix` for the table.
    - Define the value for the name of the main field `main_field_name` in the table table.
    - Add more adhoc fields to the table if needed. Example:
        - `field_1`
        - `field_3`
    - Add more adhoc fields that will be Foreign Key to another table. Example field `field_3`, a FK to the field `uuid` in the table `other_table`
- Generates a SQL script that we can use to create the table and associated obejcts (log table and triggers).

# Pre-requisites:

The following database users MUST exist:

- `view.data`

# The Sources:

This script uses the following sources:

- The `config` file (see below).

# The `config` File:

- The config file is store in the folder `tables/auto_tabling/config/table`.
- File naming convention `table_nameOfThetable.config`. This is usually the same name as the table that we want to create followed byt the `.config` postfix.

# To Add A Table `tablePrefix_tableName` to the Database Schema:

## Pre-requisite:

 - None.

## Variables:

In the `config` file we need to have the following information:

```txt
table_prefix=<prefix-for-the-table-include-a-trailing-`_`>
xxx=<the-plural-version-of-the-main-field-name-for-this-table>
yyy=<the-singular-version-of-the-main-field-name-for-this-table>
core_data=<name-of-the-additional-field-1-you-need-to-create>="SQL-parameters-that-define-this-field"
core_data=<name-of-the-additional-field-2-you-need-to-create>="SQL-parameters-that-define-this-field"
foreign_key_data=<name-of-the-field-in-that-table="SQL-parameters-that-define-this-field"=<name-of-the-other-table-that-is-the-source-for-the-FK=<name-of-the-field-that-we-link-to-in-the-other-table>
```

Example

```txt
table_prefix=tablePrefix_
xxx=main_field_names
yyy=main_field_name
core_data=field_1="DECIMAL(15,4) DEFAULT NULL COMMENT 'This is the contractual price in percent of face value, for value based vouchers.'"
core_data=field_2="DECIMAL(15,4) DEFAULT NULL COMMENT 'This is the contractual price in dollar, for product based vouchers.'"
foreign_key_data=field_3="VARCHAR(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'This is the FK for expiry scheme'"=other_table=uuid
```

# How To Run It:

To run the script you need to run the command

```bash
bash auto_create_table.sh <path-to-the-config-file>
```

Example:

```bash
bash auto_create_table.sh ./config/table/tablePrefix_tableName.config
```
