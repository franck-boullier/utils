# Overview:

How to use the script `auto_create_status.sh`

# What This Script Does:

- This script uses a [`config`](#the-config-file) file as an input file.
- Uses variables set in the [`config`](#the-config-file).
    - Define the value for the name of the main field in the status table.
- Generates a SQL script that we can use to create the table and associated obejcts (log table and triggers).

# The Sources:

This script uses the following sources:

- The `config` file (see below).

# The `config` File:

- The config file is store in the folder `tables/auto_tabling/config/status`.
- File naming convention `statusesnameOfThestatus.config`. This is usually the same name as the table that we want to create followed byt the `.config` postfix.

# To Add A Table `statusesnewStatus` to the Database Schema:

## Pre-requisite:

 - None.

## Variables:

In the `config` file we need to have the following information:

```txt
xxx=<the-name-of-the-main-field-name-for-this-status>
yyy=<the-name-of-the-main-field-name-for-this-status-followed-by-`_status`>
```

Example

```txt
xxx=newStatus
yyy=newStatus_status
```

# How To Run It:

To run the script you need to run the command

```bash
bash auto_create_status.sh <path-to-the-config-file>
```

Example:

```bash
bash auto_create_status.sh ./config/status/statusesnewStatus.config
```
