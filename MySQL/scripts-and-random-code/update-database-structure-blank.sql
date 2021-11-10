# For any question about this script - Ask Franck
#
# Pre-requisite:
#   - you have a table `db_schema_versions` in your database that stores versioning information about the database.
#
###################################################
# CHANGE THESE VARIABLES ACCORDING TO YOUR NEEDS
###################################################

	SET @old_database_schema = 'v1.0.0';
	SET @new_database_schema = 'v1.1.1';
	SET @this_script = CONCAT('THE_sql_query_to_update_the_database_from_', @old_database_schema, '_to_', @new_database_schema , '.sql'  );

###################################################
# WE HAVE ALL WE NEED - WE DO THIS!
#
# THIS SCRIP NEEDS TO BE RUN AS THE ROOT USER FOR THE db
#
###################################################
#
# INFORMATION ABOUT THIS SCRIPT:
#
# Document what the script is doing
#
#
# Insert the SQL code that will perform the update
#
#
# We can now update the version of the database schema
	# A comment for the update
		SET @comment_update_schema_version = CONCAT (
			'Database updated from '
			, @old_database_schema
			, ' to '
			, @new_database_schema
		)
	    ;
		
	# Timestamp:
		SET @timestamp = NOW();
	
	# We record that the table has been updated to the new version.
    	INSERT INTO `db_schema_versions`
            (`schema_version`
            , `update_datetime`
            , `update_script`
            , `comment`
            )
            VALUES
            (@new_database_schema
            , @timestamp
            , @this_script
            , @comment_update_schema_version
            )
        ;