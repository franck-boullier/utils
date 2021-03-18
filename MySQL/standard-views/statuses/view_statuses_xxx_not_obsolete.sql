# Replace 
#   - `xxx` with the name of your list table.
#   - `yyy` with name you have chosen for the designation field of your list.

DROP VIEW IF EXISTS `view_xxx_not_obsolete`;

CREATE
    VIEW `view_xxx_not_obsolete` 
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
WHERE (`is_obsolete` = 0)
ORDER BY 
	`order` ASC
	, `status` ASC
;