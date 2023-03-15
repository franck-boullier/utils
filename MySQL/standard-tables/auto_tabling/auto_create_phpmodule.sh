#!/bin/bash

# read config file
# read from template file
# generate script
#


source $1


# add all core data
while IFS='=' read -r k v1 v2 v3 v4
do

    if [[ "$k" == "core_data" ]];
    then
        echo "---core data--- $v2"

    elif [[ "$k" == "foreign_key_data" ]];
    then
        echo "---foreign key data--- $v2 -----> $v3.$v4"
    fi

done <$1


# start new output
# WARNING: must have 2 spaces before EOM!!!!!
cat > ./output/phpr_module_${xxx}_all_tables.sql <<-EOM
# This script creates ALL the tables that a phprunner module \`${xxx}\` needs
# - \`phpr_module_${xxx}_audit\`
# - \`phpr_module_${xxx}_settings\`
# - \`phpr_module_${xxx}_uggroups\`
# - \`phpr_module_${xxx}_ugmembers\`
# - \`phpr_module_${xxx}_ugrights\`

CREATE TABLE \`phpr_module_${xxx}_audit\` (
  \`id\` int(11) NOT NULL AUTO_INCREMENT,
  \`datetime\` datetime NOT NULL,
  \`ip\` varchar(40) CHARACTER SET utf8mb4 NOT NULL,
  \`user\` varchar(300) CHARACTER SET utf8mb4 DEFAULT NULL,
  \`table\` varchar(300) CHARACTER SET utf8mb4 DEFAULT NULL,
  \`action\` varchar(250) CHARACTER SET utf8mb4 NOT NULL,
  \`description\` mediumtext CHARACTER SET utf8mb4,
  PRIMARY KEY (\`id\`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci
;

CREATE TABLE \`phpr_module_${xxx}_settings\` (
  \`ID\` int(11) NOT NULL AUTO_INCREMENT,
  \`TYPE\` int(11) DEFAULT '1',
  \`NAME\` mediumtext,
  \`USERNAME\` mediumtext,
  \`COOKIE\` varchar(500) DEFAULT NULL,
  \`SEARCH\` mediumtext,
  \`TABLENAME\` varchar(300) DEFAULT NULL,
  PRIMARY KEY (\`ID\`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci
;

CREATE TABLE \`phpr_module_${xxx}_uggroups\` (
  \`GroupID\` int(11) NOT NULL AUTO_INCREMENT,
  \`Label\` varchar(300) DEFAULT NULL,
  PRIMARY KEY (\`GroupID\`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci
;

CREATE TABLE \`phpr_module_${xxx}_ugmembers\` (
  \`UserName\` varchar(300) NOT NULL,
  \`GroupID\` int(11) NOT NULL,
  PRIMARY KEY (\`UserName\`(50),\`GroupID\`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci
;

CREATE TABLE \`phpr_module_${xxx}_ugrights\` (
  \`TableName\` varchar(300) NOT NULL,
  \`GroupID\` int(11) NOT NULL,
  \`AccessMask\` varchar(10) DEFAULT NULL,
  \`Page\` mediumtext,
  PRIMARY KEY (\`TableName\`(50),\`GroupID\`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci
;
EOM

