# This query is to check if the 1st day of stay is the last day of the month or not

SELECT
	`db_all_dt_4_customers`.`id_customer` AS `id_customer`
	, `db_all_dt_4_customers`.`prospect_id` AS `contract_id`
	, `db_all_dt_4_customers`.`current_date_in`
	, `db_all_dt_4_customers`.`current_date_out`
	, 
	/* Is the Last day of stay also the last day of the month? */
	IF  ( 
		DAYOFMONTH (LAST_DAY (`db_all_dt_4_customers`.`current_date_in`)) = DAYOFMONTH (`db_all_dt_4_customers`.`current_date_in`)
				, 
				/* The 1st month is the month of February */
				/* Db is NOT 1*/
				/* Db is NOT 15 (middle of the month? */
				/* The FIRST day of stay is also the last day of the month */
				1
				,
				/* The 1st month is the month of February */
				/* Db is NOT 1*/
				/* Db is NOT 15 (middle of the month? */
				/* The FIRST day of stay is NOT the last day of the month */
				0
		)	
	AS `is_EOM`
	, DAYOFMONTH (`db_all_dt_4_customers`.`current_date_in`) 
	AS `first_day_of_month`
FROM `db_all_dt_4_customers`
WHERE ((`db_all_dt_4_customers`.`current_date_in` IS NOT NULL)
       AND (`db_all_dt_4_customers`.`current_date_out` IS NOT NULL));