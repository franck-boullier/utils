DROP VIEW IF EXISTS `view_voucher_templates_details`;

CREATE
    VIEW `view_voucher_templates_details` 
    AS
SELECT
    `data_1_voucher_templates`.`uuid`
    , `data_1_voucher_templates`.`is_obsolete`
    , `data_1_voucher_templates`.`order`
    , `data_1_voucher_templates`.`voucher_template`
    , `statuses_voucher_template`.`is_active`
    , `statuses_voucher_template`.`voucher_template_status`
    , `statuses_voucher_template`.`voucher_template_status_description`
    , `statuses_voucher_template`.`order` AS `status_order`
    , `data_1_voucher_templates`.`is_collapsible_tc` AS `collapsible_tc`
    , `list_product_types`.`product_type`
    , `list_product_types`.`order` AS `product_type_order`
    , `list_voucher_template_types`.`voucher_template_type`
    , `list_voucher_template_types`.`order` AS `template_type_order`
    , `list_voucher_template_types`.`voucher_template_type_description`
    , `list_product_types`.`product_type_description`
    , `data_1_voucher_templates`.`voucher_template_description`
FROM
    `contracts-quotes-v0_1`.`data_1_voucher_templates`
    LEFT JOIN `contracts-quotes-v0_1`.`list_voucher_template_types` 
        ON (`data_1_voucher_templates`.`voucher_template_type_id` = `list_voucher_template_types`.`uuid`)
    LEFT JOIN `contracts-quotes-v0_1`.`statuses_voucher_template` 
        ON (`data_1_voucher_templates`.`voucher_template_status_id` = `statuses_voucher_template`.`uuid`)
    LEFT JOIN `contracts-quotes-v0_1`.`list_product_types` 
        ON (`data_1_voucher_templates`.`product_type_id` = `list_product_types`.`uuid`)
;