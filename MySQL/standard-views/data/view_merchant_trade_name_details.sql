DROP VIEW IF EXISTS `view_merchant_trade_name_details`;

CREATE
    VIEW `view_merchant_trade_name_details` 
    AS
SELECT
  `data_2_merchant_trade_names`.`uuid`,
  `data_2_merchant_trade_names`.`merchant_trade_name`,
  `statuses_merchant_trade_name`.`is_active` AS `merchant_tn_is_active`,
  `statuses_merchant_trade_name`.`order` AS `merchant_tn_status_order`,
  `statuses_merchant_trade_name`.`merchant_trade_name_status` AS `merchant_tn_status`,
  `data_1_merchants`.`merchant`,
  `statuses_merchant`.`merchant_status`,
  `statuses_merchant`.`is_active` AS `merchant_is_active`,
  `statuses_merchant`.`order` AS `merchant_order`,
  `data_1_merchants`.`merchant_uen`
FROM
  `contracts-quotes-v0_1`.`data_2_merchant_trade_names`
  LEFT JOIN `contracts-quotes-v0_1`.`statuses_merchant_trade_name`
    ON (
      `data_2_merchant_trade_names`.`merchant_trade_name_status_id` = `statuses_merchant_trade_name`.`uuid`
    )
  LEFT JOIN `contracts-quotes-v0_1`.`data_1_merchants`
    ON (
      `data_2_merchant_trade_names`.`merchant_id` = `data_1_merchants`.`uuid`
    )
  LEFT JOIN `contracts-quotes-v0_1`.`statuses_merchant`
    ON (
      `data_1_merchants`.`merchant_status_id` = `statuses_merchant`.`uuid`
    )
ORDER BY `merchant_is_active` DESC,
  `merchant_order` ASC,
  `statuses_merchant`.`merchant_status` ASC,
  `data_1_merchants`.`merchant` ASC,
  `merchant_tn_is_active` DESC,
  `merchant_tn_status_order` ASC,
  `data_2_merchant_trade_names`.`merchant_trade_name` ASC
;