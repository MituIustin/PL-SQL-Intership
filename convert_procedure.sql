CREATE OR REPLACE PROCEDURE convert_to_euro(
    p_currency IN VARCHAR2,
    p_amount IN NUMBER,
    p_result OUT NUMBER
)
IS
    l_rate NUMBER;
    l_xml_response CLOB;
BEGIN
    l_xml_response := utl_http.request('https://www.bnro.ro/nbrfxrates.xml');
   
    SELECT TO_NUMBER(
        EXTRACTVALUE(
            XMLTYPE(l_xml_response),
            '/DataSet/Body/Cube/Rate[@currency="' || p_currency || '"]/text()'
        )
    )
    INTO l_rate
    FROM DUAL;

    p_result := p_amount / l_rate;
EXCEPTION
    WHEN OTHERS THEN
        p_result := NULL;
END;
