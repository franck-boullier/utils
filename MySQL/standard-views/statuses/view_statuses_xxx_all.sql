# Replace 
#   - `xxx` with the name of your list table.
#   - `yyy` with name you have chosen for the designation field of your list.

DROP VIEW IF EXISTS `view_xxx_all`;

CREATE
    VIEW `view_xxx_all` 
    AS
SELECT
    `uuid`
    , `yyy` AS `status`
    , `is_active`
    , `is_obsolete`
    , `order`
    , `yyy_description` AS `status_description`
FROM
    `xxx`
ORDER BY 
	`order` ASC
	, `status` ASC
;