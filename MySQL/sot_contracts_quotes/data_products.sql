# This table has been created based on the existing Costing table
# We need to have the following data in that table:
#
# OPEN QUESTION: why do we have several tabs? BAU vs Adhoc vs Smart Choice Vouchers???
# 
# From the `BAU` Tab in the Costing table file:
# - `costing_table_id`: id of the product in the costing table.
#
# Drop-down lists and constrained values (one possibility, several choices):
#
# Drill down and additional data possible
# - `merchant_name`: a FK to the table `data_merchants`.
# - `3rd_party_program`: a FK to the table `data_3rd_party_programs`.
# - `vendor`: a FK to the table `data_vendors`.
# - `sales_rep`: a FK to the table `data_sales_reps`.
#
# Simple drop-down lists:
# - `product_issuer`: a FK to the table `list_product_issuers`.
# - `voucher_generation_mode`: a FK to the table `list_product_generation_mode`.
# - `redemption_mode`: a FK to the table `list_product_redemption_modes`.
# - `template`: a FK to the table `list_voucher_templates`.
# - `reversal_limit`: a FK to the table `list_product_reversal_limits`.
# - `voucher_category`: a FK to the table `list_product_categories`.
# - `voucher_status`: a FK to the table `list_product_statuses`.
# - `voucher_type`: A FK to the table `list_product_types`.
#
# Maps between product and another table (many to many):
# - `voucher_rules`: a MAP between the records in the `data_products` table and the records in the `list_product_rules` table
#
# Core Data (no FK to an external table)
# - `tx2_internal_code`: a 15 character id that is coming from TicketXpress.
# - `can_issue`: a bit information (yes/no). <--- Can we manage that with a product status???
# - `product_parent`: the id of the parent for this product.
# - `product_code`:
# - `external_product_code`:
# - `product_name`: the Name of the product.
# - `product_description`: A description of the product.
# - `product_valid_from`: start of the validity period of the product.
# - `product_valid_until`: end of the validity period of the product.
# - `package_description`: 
# - `terms_and_conditions`:
# - `footnote`:
# - `face_value`: The retail price of the product. This is usually used for tax computation purposes for the recipient.
# - `default_selling_price`:
# - `gst`: the amount of GST applicable to this product
# - `discount`: ????
# - `comments`: Remarks in the costing table. ??WHO IS THE COMMENT FOR??
# - `timestamp`: <--- Unclear!!!
# - `store_url`: a web link to the catalogue or website associated to this product.
#
# COMPUTED VALUES:
# - `discount`: This is a COMPUTED VALUE (1-`default_selling_price`/`face_value`)
# - `margin`: This is a COMPUTED VALUE
# - `cost_before_gst`: This is a COMPUTED VALUE
# - `default_product_cost_product_based`: This is a COMPUTED VALUE
# - `default_product_cost_value_based`: This is a COMPUTED VALUE

TO DO:

Need to add the notion of product status, catalogue verification.
Need to add the notion of
- Product Family
- Product usage (BAU, Adhoc)

Merchant trading name --> Voucher family (lifestyle, dining, etcc..)