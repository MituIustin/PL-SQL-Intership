CREATE OR REPLACE PROCEDURE load_currencies (p_rows OUT NUMBER)
IS
  l_xml_response CLOB;
  l_currencies currency_type;
BEGIN
  select utl_http.request('https://www.bnro.ro/nbrfxrates.xml',
                          null,
                          'file:/opt/oracle/wallet/trusted_guest',
                          'hev0YMEWOCqHRIuT')
  into l_xml_response
  from dual;

  SELECT x.currency,
         CASE
           WHEN x.multiplier IS NOT NULL THEN x.rate / x.multiplier
           ELSE x.rate
         END AS rate
  BULK COLLECT INTO l_currencies
  FROM XMLTable(xmlnamespaces(default 'http://www.bnr.ro/xsd'),
                '/DataSet/Body/Cube/Rate'
                PASSING XMLType(l_xml_response)
                COLUMNS currency VARCHAR2(3) PATH '@currency',
                        rate NUMBER PATH '.',
                        multiplier NUMBER PATH '@multiplier');

  FOR i IN 1..l_currencies.COUNT LOOP
    MERGE INTO currency c
    USING (SELECT i AS currency_id,
                  l_currencies(i).currency,
                  l_currencies(i).rate
           FROM DUAL) x
    ON (c.currency_id = x.currency_id)
    WHEN MATCHED THEN
      UPDATE SET c.rate = x.rate
    WHEN NOT MATCHED THEN
      INSERT (currency_id, rate) VALUES (x.currency_id, x.rate);
  END LOOP;

  p_rows := SQL%ROWCOUNT;

END;
