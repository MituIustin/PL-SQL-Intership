CREATE OR REPLACE PROCEDURE update_inventory(p_rows OUT NUMBER)
IS
BEGIN

  DELETE FROM inventory;

  INSERT INTO inventory (inventory_month, product_code, product_flags_max, transaction_count, quantity, amount_ron, sales_fee_percent_avg)
  SELECT TRUNC(transaction_date, 'MONTH') AS inventory_month,
         product_code,
         PRODUCT_FLAGS_MAX(product_flags) AS product_flags_max,
         COUNT(*) AS transaction_count,
         SUM(quantity) AS quantity,
         ROUND(SUM(amount * conversion_rate), 2) AS amount_ron,
         ROUND(AVG(sales_fee_percent), 2) AS sales_fee_percent_avg
  FROM transaction t
  JOIN currency c ON t.currency_id = c.currency_id
  GROUP BY TRUNC(transaction_date, 'MONTH'), product_code;

  SELECT COUNT(*) INTO p_rows FROM inventory;

EXCEPTION
  WHEN OTHERS THEN
    raise_application_error(-20000, SQLERRM);
END;
