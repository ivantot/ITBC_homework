-- Zadatak 1.
-- Napišite SQL skriptu za kreiranje baze podataka i tabela, vodeći računa o domenima atributa.

DROP DATABASE IF EXISTS evidencija_proizvoda;
CREATE DATABASE IF NOT EXISTS evidencija_proizvoda;
USE evidencija_proizvoda;

CREATE TABLE IF NOT EXISTS kupac
(
ime VARCHAR(100) NOT NULL,
prezime VARCHAR(100) NOT NULL,
jmbg VARCHAR(20) NOT NULL,
adresa VARCHAR (100) NOT NULL,
tel VARCHAR (100) NOT NULL,
mesto_naziv VARCHAR (100) NOT NULL
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS mesto
(
naziv VARCHAR(100) NOT NULL,
zip VARCHAR(100) NOT NULL,
zemlja VARCHAR(100) NOT NULL
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS materijal
(
naziv VARCHAR(100) NOT NULL,
opis VARCHAR(100) NOT NULL,
slika VARCHAR(100) NOT NULL
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS proizvod
(
naziv VARCHAR(100) NOT NULL,
opis VARCHAR(100) NOT NULL,
slika VARCHAR(100) NOT NULL,
cena FLOAT NOT NULL
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS sastavnica
(
proizvod_naziv VARCHAR(100) NOT NULL,
materijal_naziv VARCHAR(100) NOT NULL,
kolicina INT NOT NULL
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS kupovina_proizvoda
(
proizvod_naziv VARCHAR(100) NOT NULL,
mesto_naziv VARCHAR(100) NOT NULL,
kupac_ime VARCHAR(100) NOT NULL,
kolicina INT NOT NULL,
ukupna_cena FLOAT NOT NULL,
datum TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Izmenite tabele korišćenjem naredbe ALTER TABLE tako što ćete za svaku od njih:
--     definisati jedinstveni identifikator tabele, odabirom najboljeg kandidata od datih atributa.

ALTER TABLE kupac
ADD PRIMARY KEY (jmbg);

ALTER TABLE mesto
ADD PRIMARY KEY (zip);

ALTER TABLE materijal
ADD PRIMARY KEY (naziv);

ALTER TABLE proizvod
ADD PRIMARY KEY (naziv);

ALTER TABLE sastavnica
ADD PRIMARY KEY (proizvod_naziv);

ALTER TABLE kupovina_proizvoda
ADD PRIMARY KEY (datum);

--     ukoliko procenite da neki od navedenih atributa nije dobar kandidat za jedinstveni
--     identifikator, definisati surogat kljuć i njega proglasiti primarnim ključem, a postojeći
--     ukloniti.

ALTER TABLE kupac
DROP PRIMARY KEY,
ADD COLUMN id_kupac INT AUTO_INCREMENT PRIMARY KEY;

ALTER TABLE mesto
DROP PRIMARY KEY,
ADD COLUMN id_mesto INT AUTO_INCREMENT PRIMARY KEY;

ALTER TABLE materijal
DROP PRIMARY KEY,
ADD COLUMN id_materijal INT AUTO_INCREMENT PRIMARY KEY;

ALTER TABLE proizvod
DROP PRIMARY KEY,
ADD COLUMN id_proizvod INT AUTO_INCREMENT PRIMARY KEY;

ALTER TABLE sastavnica
DROP PRIMARY KEY,
ADD COLUMN id_sastavnica INT AUTO_INCREMENT PRIMARY KEY;

ALTER TABLE kupovina_proizvoda
DROP PRIMARY KEY,
ADD COLUMN id_kupovina_proizvoda INT AUTO_INCREMENT PRIMARY KEY;

--     dodati strane ključeve, tamo gde postoji veza sa pratećim restrikcijama. Ukoliko su uvedeni surogat
--     ključevi, oni treba da učestvuju u vezi tabela, a iz tabela ukloniti nepotrebne atribute

ALTER TABLE kupac
ADD COLUMN id_mesto INT,
ADD CONSTRAINT fk_kupac_mesto FOREIGN KEY (id_mesto) REFERENCES mesto(id_mesto) ON UPDATE CASCADE ON DELETE CASCADE,
DROP COLUMN mesto_naziv;

ALTER TABLE sastavnica
ADD COLUMN id_proizvod INT,
ADD COLUMN id_materijal INT,
ADD CONSTRAINT fk_sastavnica_proizvod FOREIGN KEY (id_proizvod) REFERENCES proizvod(id_proizvod) ON UPDATE CASCADE ON DELETE CASCADE,
ADD CONSTRAINT fk_sastavnica_materijal FOREIGN KEY (id_materijal) REFERENCES materijal(id_materijal) ON UPDATE CASCADE ON DELETE CASCADE,
DROP COLUMN proizvod_naziv,
DROP COLUMN materijal_naziv;

ALTER TABLE kupovina_proizvoda
ADD COLUMN id_proizvod INT,
ADD COLUMN id_kupac INT,
ADD CONSTRAINT fk_kupovina_proizvoda_proizvod FOREIGN KEY (id_proizvod) REFERENCES proizvod(id_proizvod) ON UPDATE CASCADE ON DELETE CASCADE,
ADD CONSTRAINT fk_kupovina_proizvoda_kupac FOREIGN KEY (id_kupac) REFERENCES kupac(id_kupac) ON UPDATE CASCADE ON DELETE CASCADE,
DROP COLUMN proizvod_naziv,
DROP COLUMN mesto_naziv,
DROP COLUMN kupac_ime;

--     izbrisati iz svih tabela atribut Slika

ALTER TABLE materijal
DROP COLUMN slika;

ALTER TABLE proizvod
DROP COLUMN slika;

--     sve kolone koje za naziv imaju skracenicu, preimenovati sa punim nazivom (npr. tel - telefon)

ALTER TABLE kupac
RENAME COLUMN jmbg TO jedinstveni_maticni_broj_gradjana,
RENAME COLUMN tel TO telefon;

ALTER TABLE mesto
RENAME COLUMN zip TO postanski_broj;

--     (BONUS) za brojeve JMBG i brojeve telefona proveriti da li sadrže samo cifre pomoću CHECK ograničenja

ALTER TABLE kupac
ADD CONSTRAINT chk_kupac_jmbg CHECK (jedinstveni_maticni_broj_gradjana REGEXP '^[0-9]{13}$'),
ADD CONSTRAINT chk_kupac_telefon CHECK (telefon REGEXP '^[0-9]*$');

-- Za svaku bazu podataka kreirati po izboru novu tabelu koja treba da sadrži strane ključeve iz postojeće dve tabele

CREATE TABLE IF NOT EXISTS poreklo_materijala
(
id_poreklo_materijala INT AUTO_INCREMENT PRIMARY KEY,
id_materijal INT,
id_mesto INT,
dobavljac VARCHAR (100) NOT NULL,
CONSTRAINT fk_poreklo_materijala_materijal FOREIGN KEY (id_materijal) REFERENCES materijal(id_materijal) ON UPDATE CASCADE ON DELETE CASCADE,
CONSTRAINT fk_poreklo_materijala_mesto FOREIGN KEY (id_mesto) REFERENCES mesto(id_mesto) ON UPDATE CASCADE ON DELETE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- U svaku od tabela uneti po nekoliko redova poštujući referencijalne integritete baze podataka.

INSERT INTO mesto (id_mesto, naziv, postanski_broj, zemlja) VALUES 
(NULL, 'Novi Sad', '21000', 'R. Srbija'),
(NULL, 'Beograd', '11000', 'R. Srbija'),
(NULL, 'Nis', '18000', 'R. Srbija'),
(NULL, 'Vranje', '17500', 'R. Srbija');

INSERT INTO materijal (id_materijal, naziv, opis) VALUES 
(NULL, 'Vijak M12', 'Vijak od celika negarantovanog kvaliteta'),
(NULL, 'Navrtka M12', 'Navrtka od celika negarantovanog kvaliteta'),
(NULL, 'Podloska M12', 'Podloska od celika negarantovanog kvaliteta'),
(NULL, 'Radilica', 'Radilica motora');

INSERT INTO proizvod (id_proizvod, naziv, opis, cena) VALUES 
(NULL, 'M-1', 'Traktor model M-1 sa motorom od 110KS', 1300000),
(NULL, 'L-1', 'Traktor model L-1 sa motorom od 120KS', 1400000),
(NULL, 'XL-1', 'Traktor model XL-1 sa motorom od 140KS', 1600000),
(NULL, 'XXL-1', 'Traktor model XXL-1 sa motorom od 160KS', 1700000);

INSERT INTO kupac (id_kupac, ime, prezime, jedinstveni_maticni_broj_gradjana, adresa, telefon, id_mesto) VALUES 
(NULL, 'Jordan', 'Rudess', '1029384756473', 'Vojvodjanska 22', '381650656475', 1),
(NULL, 'James', 'Hadfield', '1647382910293', 'Bore Stankovica 109', '38160566555', 2),
(NULL, 'Ada', 'Lovelace', '1122112211124', 'Marsala Tita 2', '38166506655', 3);

INSERT INTO sastavnica (id_sastavnica, id_proizvod, id_materijal, kolicina) VALUES 
(NULL, 1, 1 , 10),
(NULL, 1, 2 , 20),
(NULL, 1, 3 , 10);

INSERT INTO kupovina_proizvoda (id_kupovina_proizvoda, id_proizvod, id_kupac, kolicina, ukupna_cena) VALUES 
(NULL, 1, 1, 1, 1300000),
(NULL, 2, 2, 1, 1400000),
(NULL, 2, 3, 1, 1400000);

INSERT INTO poreklo_materijala (id_poreklo_materijala, id_materijal, id_mesto, dobavljac) VALUES 
(NULL, 1, 4, 'ResTrade'),
(NULL, 2, 4, 'ResTrade'),
(NULL, 3, 4, 'AgroGlobe');

-- Dodati sekvencu za čišćenje podataka. Obrisati sve redove iz tabela, pa zatim tabele i na kraju i samo bazu.
/*
ALTER TABLE kupac
DROP CONSTRAINT fk_kupac_mesto;

ALTER TABLE sastavnica
DROP CONSTRAINT fk_sastavnica_proizvod,
DROP CONSTRAINT fk_sastavnica_materijal;

ALTER TABLE kupovina_proizvoda
DROP CONSTRAINT fk_kupovina_proizvoda_proizvod,
DROP CONSTRAINT fk_kupovina_proizvoda_kupac;

ALTER TABLE poreklo_materijala
DROP CONSTRAINT fk_poreklo_materijala_materijal,
DROP CONSTRAINT fk_poreklo_materijala_mesto;

TRUNCATE TABLE poreklo_materijala;
TRUNCATE TABLE kupovina_proizvoda;
TRUNCATE TABLE sastavnica;
TRUNCATE TABLE materijal;
TRUNCATE TABLE proizvod;
TRUNCATE TABLE kupac;
TRUNCATE TABLE mesto;

ALTER TABLE kupac
ADD CONSTRAINT fk_kupac_mesto FOREIGN KEY (id_mesto) REFERENCES mesto(id_mesto) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE sastavnica
ADD CONSTRAINT fk_sastavnica_proizvod FOREIGN KEY (id_proizvod) REFERENCES proizvod(id_proizvod) ON UPDATE CASCADE ON DELETE CASCADE,
ADD CONSTRAINT fk_sastavnica_materijal FOREIGN KEY (id_materijal) REFERENCES materijal(id_materijal) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE kupovina_proizvoda
ADD CONSTRAINT fk_kupovina_proizvoda_proizvod FOREIGN KEY (id_proizvod) REFERENCES proizvod(id_proizvod) ON UPDATE CASCADE ON DELETE CASCADE,
ADD CONSTRAINT fk_kupovina_proizvoda_kupac FOREIGN KEY (id_kupac) REFERENCES kupac(id_kupac) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE poreklo_materijala
ADD CONSTRAINT fk_poreklo_materijala_materijal FOREIGN KEY (id_materijal) REFERENCES materijal(id_materijal) ON UPDATE CASCADE ON DELETE CASCADE,
ADD CONSTRAINT fk_poreklo_materijala_mesto FOREIGN KEY (id_mesto) REFERENCES mesto(id_mesto) ON UPDATE CASCADE ON DELETE CASCADE;

DROP TABLE sastavnica;
DROP TABLE kupovina_proizvoda;
DROP TABLE poreklo_materijala;
DROP TABLE materijal;
DROP TABLE proizvod;
DROP TABLE kupac;
DROP TABLE mesto;

DROP DATABASE IF EXISTS evidencija_proizvoda;
*/

-- Zadatak 2.
-- Napišite SQL skriptu za kreiranje baze podataka i tabela, vodeći računa o domenima atributa.

DROP DATABASE IF EXISTS zdravstveni_kartoni;
CREATE DATABASE IF NOT EXISTS zdravstveni_kartoni;
USE zdravstveni_kartoni;

CREATE TABLE IF NOT EXISTS pacijent
(
ime VARCHAR(100) NOT NULL,
prezime VARCHAR(100) NOT NULL,
jmbg VARCHAR(20) NOT NULL,
adresa VARCHAR (100) NOT NULL,
telefon VARCHAR (100) NOT NULL,
doktor_br_licence VARCHAR (100) NOT NULL
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS doktor
(
ime VARCHAR(100) NOT NULL,
prezime VARCHAR(100) NOT NULL,
jmbg VARCHAR(20) NOT NULL,
specijalizacija VARCHAR (100) NOT NULL,
br_licence VARCHAR (100) NOT NULL
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `medikament (lek)`
(
naziv VARCHAR(100) NOT NULL,
sifra VARCHAR(100) NOT NULL,
proizvodjac_naziv VARCHAR(100) NOT NULL
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS bolest
(
naziv VARCHAR(100) NOT NULL,
opis VARCHAR(100) NOT NULL,
slika VARCHAR(100) NOT NULL
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS proizvodjac
(
naziv VARCHAR(100) NOT NULL,
adresa VARCHAR(100) NOT NULL,
tel VARCHAR(100) NOT NULL
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS boluje_od
(
pacijent_ime VARCHAR(100) NOT NULL,
doktor_ime VARCHAR(100) NOT NULL,
bolest_naziv VARCHAR(100) NOT NULL,
datum_dijagnoze TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Izmenite tabele korišćenjem naredbe ALTER TABLE tako što ćete za svaku od njih:
--     definisati jedinstveni identifikator tabele, odabirom najboljeg kandidata od datih atributa.

ALTER TABLE pacijent
ADD PRIMARY KEY (jmbg);

ALTER TABLE doktor
ADD PRIMARY KEY (jmbg);

ALTER TABLE `medikament (lek)`
ADD PRIMARY KEY (sifra);

ALTER TABLE bolest
ADD PRIMARY KEY (naziv);

ALTER TABLE proizvodjac
ADD PRIMARY KEY (naziv);

ALTER TABLE boluje_od
ADD PRIMARY KEY (datum_dijagnoze);

--     ukoliko procenite da neki od navedenih atributa nije dobar kandidat za jedinstveni
--     identifikator, definisati surogat kljuć i njega proglasiti primarnim ključem, a postojeći
--     ukloniti.

ALTER TABLE pacijent
DROP PRIMARY KEY,
ADD COLUMN id_pacijent INT AUTO_INCREMENT PRIMARY KEY;

ALTER TABLE doktor
DROP PRIMARY KEY,
ADD COLUMN id_doktor INT AUTO_INCREMENT PRIMARY KEY;

ALTER TABLE `medikament (lek)`
DROP PRIMARY KEY,
ADD COLUMN id_medikament INT AUTO_INCREMENT PRIMARY KEY;

ALTER TABLE bolest
DROP PRIMARY KEY,
ADD COLUMN id_bolest INT AUTO_INCREMENT PRIMARY KEY;

ALTER TABLE proizvodjac
DROP PRIMARY KEY,
ADD COLUMN id_proizvodjac INT AUTO_INCREMENT PRIMARY KEY;

ALTER TABLE boluje_od
DROP PRIMARY KEY,
ADD COLUMN id_boluje_od INT AUTO_INCREMENT PRIMARY KEY;

--     dodati strane ključeve, tamo gde postoji veza sa pratećim restrikcijama. Ukoliko su uvedeni surogat
--     ključevi, oni treba da učestvuju u vezi tabela, a iz tabela ukloniti nepotrebne atribute

ALTER TABLE pacijent
ADD COLUMN id_doktor INT,
ADD CONSTRAINT fk_pacijent_doktor FOREIGN KEY (id_doktor) REFERENCES doktor(id_doktor) ON UPDATE CASCADE ON DELETE CASCADE,
DROP COLUMN doktor_br_licence;

ALTER TABLE `medikament (lek)`
ADD COLUMN id_proizvodjac INT,
ADD CONSTRAINT fk_medikament_proizvodjac FOREIGN KEY (id_proizvodjac) REFERENCES proizvodjac(id_proizvodjac) ON UPDATE CASCADE ON DELETE CASCADE,
DROP COLUMN proizvodjac_naziv;

ALTER TABLE boluje_od
ADD COLUMN id_pacijent INT,
ADD COLUMN id_bolest INT,
ADD CONSTRAINT fk_boluje_od_pacijent FOREIGN KEY (id_pacijent) REFERENCES pacijent(id_pacijent) ON UPDATE CASCADE ON DELETE CASCADE,
ADD CONSTRAINT fk_boluje_od_bolest FOREIGN KEY (id_bolest) REFERENCES bolest(id_bolest) ON UPDATE CASCADE ON DELETE CASCADE,
DROP COLUMN pacijent_ime,
DROP COLUMN doktor_ime,
DROP COLUMN bolest_naziv;

--     izbrisati iz svih tabela atribut Slika

ALTER TABLE bolest
DROP COLUMN slika;

--     sve kolone koje za naziv imaju skracenicu, preimenovati sa punim nazivom (npr. tel - telefon)

ALTER TABLE pacijent
RENAME COLUMN jmbg TO jedinstveni_maticni_broj_gradjana;

ALTER TABLE doktor
RENAME COLUMN br_licence TO broj_licence,
RENAME COLUMN jmbg TO jedinstveni_maticni_broj_gradjana;

ALTER TABLE proizvodjac
RENAME COLUMN tel TO telefon;

--     (BONUS) za brojeve JMBG i brojeve telefona proveriti da li sadrže samo cifre pomoću CHECK ograničenja

ALTER TABLE pacijent
ADD CONSTRAINT chk_pacijent_jmbg CHECK (jedinstveni_maticni_broj_gradjana REGEXP '^[0-9]{13}$'),
ADD CONSTRAINT chk_pacijent_telefon CHECK (telefon REGEXP '^[0-9]*$');

ALTER TABLE doktor
ADD CONSTRAINT chk_doktor_jmbg CHECK (jedinstveni_maticni_broj_gradjana REGEXP '^[0-9]{13}$');

ALTER TABLE proizvodjac
ADD CONSTRAINT chk_proizvodjac_telefon CHECK (telefon REGEXP '^[0-9]*$');

-- Za svaku bazu podataka kreirati po izboru novu tabelu koja treba da sadrži strane ključeve iz postojeće dve tabele

CREATE TABLE IF NOT EXISTS saradnja_sa_proizvodjacem
(
id_saradnja_sa_proizvodjacem INT AUTO_INCREMENT PRIMARY KEY,
id_doktor INT,
id_proizvodjac INT,
naknada FLOAT NOT NULL,
CONSTRAINT fk_saradnja_sa_proizvodjacem_doktor FOREIGN KEY (id_doktor) REFERENCES doktor(id_doktor) ON UPDATE CASCADE ON DELETE CASCADE,
CONSTRAINT fk_saradnja_sa_proizvodjacem_proizvodjac FOREIGN KEY (id_proizvodjac) REFERENCES proizvodjac(id_proizvodjac) ON UPDATE CASCADE ON DELETE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- U svaku od tabela uneti po nekoliko redova poštujući referencijalne integritete baze podataka.

INSERT INTO doktor (id_doktor, ime, prezime, jedinstveni_maticni_broj_gradjana, specijalizacija, broj_licence) VALUES 
(NULL, 'Alexander', 'Fleming', '1029384756473', 'bakteriolog', '122-T'),
(NULL, 'Helen', 'Brooke Taussig', '0192820384012', 'opta praksa', '112-G'),
(NULL, 'Virginia', 'Apgar', '1988372481999', 'pedijatar', '251-G'),
(NULL, 'Georges', 'Mathé', '2212485738921', 'opta praksa', '541-L');

INSERT INTO bolest (id_bolest, naziv, opis) VALUES 
(NULL, 'Grip', 'Svi oblici infekcije virusom gripa'),
(NULL, 'Covid', 'Svi sojevi infekcije virusom Covid'),
(NULL, 'Gojaznost', 'Prekomerna telesna tezina, BMI preko 30'),
(NULL, 'Depresija', 'Stanje koje nepovoljno utice na osecanja, razmidljanje i delovanje');

INSERT INTO proizvodjac (id_proizvodjac, naziv, adresa, telefon) VALUES 
(NULL, 'Pfizer', 'California, USA', '8894442291'),
(NULL, 'Johnson & Johnson', 'California, USA', '8893823331'),
(NULL, 'Roche', 'California, USA', '8893829991'),
(NULL, 'Novartis', 'California, USA', '8896662291');

INSERT INTO pacijent (id_pacijent, ime, prezime, jedinstveni_maticni_broj_gradjana, adresa, telefon, id_doktor) VALUES 
(NULL, 'Jordan', 'Rudess', '1029384756473', 'Vojvodjanska 22', '381650656475', 2),
(NULL, 'James', 'Hadfield', '1647382910293', 'Bore Stankovica 109', '38160566555', 2),
(NULL, 'Ada', 'Lovelace', '1122112211124', 'Marsala Tita 2', '38166506655', 4);

INSERT INTO `medikament (lek)` (id_medikament, naziv, sifra, id_proizvodjac) VALUES 
(NULL, 'EpiPen', 'PF-1' , 1),
(NULL, 'Neosporin', 'PF-2' , 1),
(NULL, 'Voltaren', 'N-1' , 4);

INSERT INTO boluje_od (id_boluje_od, id_pacijent, id_bolest) VALUES 
(NULL, 1, 2),
(NULL, 1, 3),
(NULL, 3, 4);

INSERT INTO saradnja_sa_proizvodjacem (id_saradnja_sa_proizvodjacem, id_doktor, id_proizvodjac, naknada) VALUES 
(NULL, 1, 1, 10000),
(NULL, 1, 2, 20000),
(NULL, 1, 3, 40000);

-- Dodati sekvencu za čišćenje podataka. Obrisati sve redove iz tabela, pa zatim tabele i na kraju i samo bazu.
/*
ALTER TABLE pacijent
DROP CONSTRAINT fk_pacijent_doktor;

ALTER TABLE `medikament (lek)`
DROP CONSTRAINT fk_medikament_proizvodjac;

ALTER TABLE boluje_od
DROP CONSTRAINT fk_boluje_od_pacijent,
DROP CONSTRAINT fk_boluje_od_bolest;

ALTER TABLE saradnja_sa_proizvodjacem
DROP CONSTRAINT fk_saradnja_sa_proizvodjacem_doktor,
DROP CONSTRAINT fk_saradnja_sa_proizvodjacem_proizvodjac;

TRUNCATE TABLE saradnja_sa_proizvodjacem;
TRUNCATE TABLE boluje_od;
TRUNCATE TABLE `medikament (lek)`;
TRUNCATE TABLE pacijent;
TRUNCATE TABLE proizvodjac;
TRUNCATE TABLE bolest;
TRUNCATE TABLE doktor;

ALTER TABLE pacijent
ADD CONSTRAINT fk_pacijent_doktor FOREIGN KEY (id_doktor) REFERENCES doktor(id_doktor) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE `medikament (lek)`
ADD CONSTRAINT fk_medikament_proizvodjac FOREIGN KEY (id_proizvodjac) REFERENCES proizvodjac(id_proizvodjac) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE boluje_od
ADD CONSTRAINT fk_boluje_od_pacijent FOREIGN KEY (id_pacijent) REFERENCES pacijent(id_pacijent) ON UPDATE CASCADE ON DELETE CASCADE,
ADD CONSTRAINT fk_boluje_od_bolest FOREIGN KEY (id_bolest) REFERENCES bolest(id_bolest) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE saradnja_sa_proizvodjacem
ADD CONSTRAINT fk_saradnja_sa_proizvodjacem_doktor FOREIGN KEY (id_doktor) REFERENCES doktor(id_doktor) ON UPDATE CASCADE ON DELETE CASCADE,
ADD CONSTRAINT fk_saradnja_sa_proizvodjacem_proizvodjac FOREIGN KEY (id_proizvodjac) REFERENCES proizvodjac(id_proizvodjac) ON UPDATE CASCADE ON DELETE CASCADE;

DROP TABLE saradnja_sa_proizvodjacem;
DROP TABLE boluje_od;
DROP TABLE `medikament (lek)`;
DROP TABLE pacijent;
DROP TABLE proizvodjac;
DROP TABLE bolest;
DROP TABLE doktor;

DROP DATABASE IF EXISTS zdravstveni_kartoni;
*/