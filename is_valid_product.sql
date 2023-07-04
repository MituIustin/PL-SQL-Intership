CREATE OR REPLACE FUNCTION is_valid_product_code(p_product_code IN VARCHAR2) RETURN BOOLEAN
IS
  l_supplier_code VARCHAR2(2);
  l_checksum VARCHAR2(2);
  l_product_sku VARCHAR2(20);
  l_reordered_product_code VARCHAR2(50);
  l_numeric_code NUMBER;
BEGIN

  IF LENGTH(p_product_code) < 6 OR LENGTH(p_product_code) > 20 THEN
    RETURN FALSE;
  END IF;

  l_supplier_code := SUBSTR(p_product_code, 1, 2);
  l_checksum := SUBSTR(p_product_code, 3, 2);
  l_product_sku := SUBSTR(p_product_code, 5);

  l_reordered_product_code := l_product_sku || l_supplier_code;

  FOR i IN 65..90 -- A -> Z
  LOOP
    l_reordered_product_code :=
        REPLACE(l_reordered_product_code, CHR(i), TO_CHAR(i - 55));
  END LOOP;

  l_numeric_code := MOD(TO_NUMBER(l_reordered_product_code), 97);

  IF l_numeric_code = 1 THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END;
