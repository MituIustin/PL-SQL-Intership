CREATE OR REPLACE PROCEDURE load_transactions(
    p_file    IN VARCHAR2,
    p_sha256  IN VARCHAR2,
    p_rows    OUT NUMBER,
    p_bad_pc  OUT NUMBER,
    p_dupl    OUT NUMBER
)
IS
  l_blob BLOB;
  l_decompressed_blob BLOB;
  l_sha256 VARCHAR2(64);
  l_json CLOB;
BEGIN
  -- Validare parametri de intrare
  IF p_file IS NULL OR p_sha256 IS NULL THEN
    raise_application_error(-20000, 'null arguments');
  END IF;

  -- Verificare existenta fisier
  BEGIN
    SELECT utl_raw.cast_to_varchar2(dbms_lob.substr(bfile_data, 2000, 1))
    INTO l_sha256
    FROM bfiles

    WHERE bfile_name = p_file;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        raise_application_error(-20000, 'file not found');
  END;

  -- Verificare fisier gol
  IF l_sha256 IS NULL THEN
    raise_application_error(-20000, 'empty file');
  END IF;

  -- Validare SHA256
  IF l_sha256 <> p_sha256 THEN
    raise_application_error(-20000, 'invalid sha256');
  END IF;

  -- Incarcare fisier in BLOB
  BEGIN
    SELECT bfile_data
    INTO l_blob
    FROM bfiles
    WHERE bfile_name = p_file;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        raise_application_error(-20000, 'file not found');
  END;

  -- Decompresare BLOB
  BEGIN
    l_decompressed_blob := utl_compress.lz_uncompress(l_blob);

    EXCEPTION
      WHEN OTHERS THEN
        raise_application_error(-20000, 'invalid gzip');
  END;

  -- Conversie BLOB în CLOB
  l_json := utl_raw.cast_to_varchar2(l_decompressed_blob);

  -- Validare JSON
  IF NOT apex_json.is_valid(l_json) THEN
    raise_application_error(-20000, 'invalid payload');
  END IF;

  -- Variabile pentru numarul de inregistrari inserate si ignorate
  p_rows := 0;
  p_bad_pc := 0;
  p_dupl := 0;

  -- Populare tabela TRANSACTION cu datele JSON
  FOR i IN 1..apex_json.get_count(p_path => '$')
  LOOP
    DECLARE
      l_transaction_id NUMBER;
      l_product_code VARCHAR2(50);
    BEGIN
      -- Extrage valorile din JSON
      l_transaction_id := apex_json.get_number(p_path => '[' || i || '].transaction_id');
      l_product_code := apex_json.get_varchar2(p_path => '[' || i || '].product_code');

      -- Validare PRODUCT_CODE
      IF NOT is_valid_product_code(l_product_code) THEN
        p_bad_pc := p_bad_pc + 1;
        CONTINUE;
      END IF;

      -- Verificare duplicat TRANSACTION_ID
      BEGIN
        SELECT 1
        INTO dummy
        FROM transaction
        WHERE transaction_id = l_transaction_id;

        p_dupl := p_dupl + 1;
        CONTINUE;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;
      END;

      -- Inserare inregistrare in tabela TRANSACTION
      INSERT INTO transaction (transaction_id, product_code)
      VALUES (l_transaction_id, l_product_code);

      p_rows := p_rows + 1;
    END;
  END LOOP;
  
EXCEPTION
  WHEN OTHERS THEN
    raise_application_error(-20000, SQLERRM);
END;
