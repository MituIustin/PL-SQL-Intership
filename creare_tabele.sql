CREATE TABLE produs (
    id_produs NUMBER(4) NOT NULL,
    nume VARCHAR2(100),
    pret NUMBER(8),
    cantitate NUMBER(8)
);

CREATE TABLE prod_opt (
    id_produs NUMBER(4),
    id_optiune NUMBER(4)
);

CREATE TABLE optiune (
    id_optiune NUMBER(4) NOT NULL,
    nume VARCHAR2(100),
    descriere VARCHAR2(2000)
);

CREATE TABLE configuratie (
    id_configuratie NUMBER(4) NOT NULL,
    id_optiune NUMBER(4),
    pret_aditional NUMBER(4),
    tip VARCHAR2(100)
);

CREATE TABLE prod_serv (
    id_produs NUMBER(4),
    id_serviciu NUMBER(4)
);

CREATE TABLE serviciu (
    id_serviciu NUMBER(4) NOT NULL,
    pret_aditional NUMBER(4),
    descriere VARCHAR2(2000)
);

CREATE TABLE achizitie (
    id_produs NUMBER(4),
    id_utilizator NUMBER(4),
    cantitate NUMBER(8),
    moneda VARCHAR2(3)
);

CREATE TABLE utilizator (
    id_utilizator NUMBER(8) NOT NULL,
    nume VARCHAR2(100),
    telefon VARCHAR2(13),
    adresa VARCHAR2(200)
);

ALTER TABLE produs ADD CONSTRAINT pk_produs PRIMARY KEY (id_produs);
ALTER TABLE serviciu ADD CONSTRAINT pk_serviciu PRIMARY KEY (id_serviciu);
ALTER TABLE prod_serv ADD CONSTRAINT fk_prod1 FOREIGN KEY (id_produs) REFERENCES produs(id_produs);
ALTER TABLE prod_serv ADD CONSTRAINT fk_serv FOREIGN KEY (id_serviciu) REFERENCES serviciu(id_serviciu);
ALTER TABLE prod_serv ADD CONSTRAINT pk_prod_serv PRIMARY KEY (id_produs, id_serviciu);
ALTER TABLE optiune ADD CONSTRAINT pk_optiune PRIMARY KEY (id_optiune);
ALTER TABLE configuratie ADD CONSTRAINT pk_configuratie PRIMARY KEY (id_configuratie);
ALTER TABLE configuratie ADD CONSTRAINT fk_configuratie FOREIGN KEY (id_optiune) REFERENCES optiune(id_optiune);
ALTER TABLE prod_opt ADD CONSTRAINT fk_prod2 FOREIGN KEY (id_produs) REFERENCES produs(id_produs);
ALTER TABLE prod_opt ADD CONSTRAINT fk_opt FOREIGN KEY (id_optiune) REFERENCES optiune(id_optiune);
ALTER TABLE prod_opt ADD CONSTRAINT pk_prod_opt PRIMARY KEY (id_produs, id_optiune);
ALTER TABLE utilizator ADD CONSTRAINT pk_utilizator PRIMARY KEY (id_utilizator);
ALTER TABLE achizitie ADD CONSTRAINT fk_prod3 FOREIGN KEY (id_produs) REFERENCES produs(id_produs);
ALTER TABLE achizitie ADD CONSTRAINT fk_utilizator FOREIGN KEY (id_utilizator) REFERENCES utilizator(id_utilizator);
ALTER TABLE achizitie ADD CONSTRAINT pk_achizitie PRIMARY KEY (id_produs, id_utilizator);

COMMIT;
/*
drop table produs cascade constraints;
drop table prod_opt cascade constraints;
drop table optiune cascade constraints;
drop table configuratie cascade constraints;
drop table achizitie cascade constraints;
drop table utilizator cascade constraints;
drop table prod_serv cascade constraints;
drop table serviciu cascade constraints;
*/