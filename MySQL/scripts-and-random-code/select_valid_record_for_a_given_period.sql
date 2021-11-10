/*
Query to select valid records during a given period:
Convention:
Start: Start date of the period
End: End date of the period

IN: Date when the record/contract starts
OUT: Date when the record/contract ends

a VALID case is a scenario where the customer has stayed during the given period.

We have 6 cases to address: (2 INVALIDs and 4 VALIDs)
INVALID:	IN	OUT	Start			End		
VALID: 		IN		Start			End		OUT
VALID:		IN 		Start	OUT		End
VALID:				Start	IN	OUT	End
VALID:				Start	IN		End		OUT
INVALID: 			Start			End 	IN	OUT

The query to do this is
	(Start >= IN 
		AND Start <= OUT
	)
OR	(End >= IN 
		AND End <= OUT
	)
OR	(IN >= Start 
		AND IN <= End
		AND OUT >= Start
		AND OUT <= End
	)
*/
# Changelog:
# 	v2.0: add information about the record type


# Start of the period that you need to evaluate
SET @START = '2016-07-01';
# END of the period that you need to evaluate
SET @END = '2017-06-30';
# We have everything
# Run the query
SELECT
    `db_all_sourcing_dt_4_lmb_record`.`id_lmb_record`
    , `db_all_sourcing_dt_4_lmb_record`.`flat_id`
    , `172_record_types`.`record_type`
    , `db_sourcing_ls_0_record_status`.`record_status`
    , `db_sourcing_ls_0_record_status`.`is_valid`
    , `db_all_sourcing_dt_4_lmb_record`.`lease_start`
    , `db_all_sourcing_dt_4_lmb_record`.`lease_end`
    , `db_all_sourcing_dt_4_lmb_record`.`rent_offered`
    , `db_all_sourcing_dt_4_lmb_record`.`deposit_amount_agreed`
FROM
    `db_all_sourcing_dt_4_lmb_record`
    INNER JOIN `db_sourcing_ls_0_record_status` 
        ON (`db_all_sourcing_dt_4_lmb_record`.`record_status_id` = `db_sourcing_ls_0_record_status`.`id_record_status`)
    INNER JOIN `172_record_types` 
        ON (`db_all_sourcing_dt_4_lmb_record`.`record_type_id` = `172_record_types`.`id_record_type`)
WHERE (
		(`db_sourcing_ls_0_record_status`.`is_valid` =1)
		AND 
		(@START >= `db_all_sourcing_dt_4_lmb_record`.`lease_start`)
		AND
		(@START <= `db_all_sourcing_dt_4_lmb_record`.`lease_end`)
	)
	OR (
		(`db_sourcing_ls_0_record_status`.`is_valid` =1)
		AND
		(@END >= `db_all_sourcing_dt_4_lmb_record`.`lease_start`)
		AND
		(@END <= `db_all_sourcing_dt_4_lmb_record`.`lease_end`)
	)
	OR (
		(`db_sourcing_ls_0_record_status`.`is_valid` =1)
		AND
		(`db_all_sourcing_dt_4_lmb_record`.`lease_start` >= @START)
		AND
		(`db_all_sourcing_dt_4_lmb_record`.`lease_start` <= @END)
		AND
		(`db_all_sourcing_dt_4_lmb_record`.`lease_end` >= @START)
		AND
		(`db_all_sourcing_dt_4_lmb_record`.`lease_end` <= @END)
	)
ORDER BY `db_all_sourcing_dt_4_lmb_record`.`lease_start` ASC, `db_all_sourcing_dt_4_lmb_record`.`lease_end` ASC;