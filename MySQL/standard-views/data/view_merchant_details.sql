DROP VIEW IF EXISTS `view_merchant_details`;

CREATE
    VIEW `view_merchant_details` 
    AS
SELECT
  `data_1_merchants`.`uuid`,
  `data_1_merchants`.`order`,
  `data_1_merchants`.`merchant`,
  `data_1_merchants`.`merchant_category_id_for_tx2`,
  `list_merchant_categories`.`merchant_category`,
  `statuses_merchant`.`merchant_status`,
  `statuses_merchant`.`is_active`,
  `data_1_merchants`.`merchant_uen`,
  `data_1_merchants`.`merchant_description`,
  `statuses_merchant`.`order` AS `status_order`
FROM
  `contracts-quotes-v0_1`.`data_1_merchants`
  LEFT JOIN `contracts-quotes-v0_1`.`list_merchant_categories`
    ON (
      `data_1_merchants`.`merchant_category_id_for_tx2` = `list_merchant_categories`.`uuid`
    )
  LEFT JOIN `contracts-quotes-v0_1`.`statuses_merchant`
    ON (
      `data_1_merchants`.`merchant_status_id` = `statuses_merchant`.`uuid`
    )
ORDER BY `statuses_merchant`.`is_active` DESC,
  `status_order` ASC,
  `data_1_merchants`.`merchant` ASC
;