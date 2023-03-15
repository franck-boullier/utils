# Overview:

How to use the script `auto_create_list.sh`

# What This Script Does:

- This script uses a [`config`](#the-config-file) file as an input file.
- Uses variables set in the [`config`](#the-config-file).
    - Define the value for the name of the main field in the list table.
    - Add more fields to the table if needed.
- Generates a SQL script that we can use to create the table and associated obejcts (log table and triggers).

# The Sources:

This script uses the following sources:

- The `config` file (see below).

# The `config` File:

- The config file is store in the folder `tables/auto_tabling/config/list`.
- File naming convention `list_nameOfTheList.config`. This is usually the same name as the table that we want to create followed byt the `.config` postfix.

# To Add A Table `list_newList` to the Database Schema:

## Pre-requisite:

 - None.

## Variables:

In the `config` file we need to have the following information:

```txt
xxx=<the-plural-version-of-the-main-field-name-for-this-list>
yyy=<the-singular-version-of-the-main-field-name-for-this-list>
core_data=<name-of-the-additional-field-you-need-to-create>="SQL-parameters-that-define-this-field"
```

Example

```txt
xxx=newLists
yyy=newList
core_data=uen="VARCHAR(255) NOT NULL COMMENT 'The UEN of the entity'"
```

# How To Run It:

To run the script you need to run the command

```bash
bash auto_create_list.sh <path-to-the-config-file>
```

Example:

```bash
bash auto_create_list.sh ./config/list/list_newList.config
```
