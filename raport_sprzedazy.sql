CREATE temp VIEW ceny1 AS
SELECT DISTINCT
    p.poz_id,
    a.art_id,
    a.prefiks,
    a.indeks,
    a.nazwa,
--    a.opis,
    a.litraz,
    a.nr_oryginalu,
    a.mp_org,
    p.cena AS cenaSP,
    p.ilosc as ilosc1,
    sp.numer AS numer1,
	sp.data_wystawienia as data_wystawienia,
    null AS skrot,
    null AS nazwa_kont,
    null AS nip,  
    null AS cenaZA,
    null as ilosc2,
    null AS numer2,
    NULL AS nr_fakt_dostawcy
FROM mbiz.pozycja p
LEFT JOIN mbiz.artykul a ON p.art_id = a.art_id
LEFT JOIN mbiz.dokument_sp sp ON p.doksp_id = sp.doksp_id
LEFT JOIN mbiz.pozycja_zrodlo pz ON p.poz_id = pz.poz_id
FULL JOIN mbiz.dokument_mag mg ON p.dokmag_id = mg.dokmag_id

WHERE p.dokmag_id IS NOT NULL and sp.data_wystawienia > '2022-01-01' and sp.data_wystawienia < '2022-12-31' and (sp.numer LIKE 'FA%' or sp.numer LIKE 'PG%' or sp.numer LIKE 'FK%' ) 
ORDER BY indeks;



CREATE temp VIEW ceny2 AS
SELECT DISTINCT ON (pz.poz_id)
    pz.poz_id,
    a.art_id,
    a.prefiks,
    a.indeks,
    a.nazwa,
 --   a.opis,
    a.litraz,
    a.nr_oryginalu,
    a.mp_org,
    null AS cenaSP,
    null AS ilosc1,
    null AS numer1,
	null as data_wystawienia,
    k.skrot AS skrot,
    k.nazwa AS nazwa_kont,
    k.nipx AS nip,
    p.cena AS cenaZA,
    p.ilosc AS ilosc2,
    mg.numer AS numer2,
    mg.nr_fakt_dostawcy AS nr_fakt_dostawcy
FROM mbiz.pozycja p
LEFT JOIN mbiz.artykul a ON p.art_id = a.art_id
LEFT JOIN mbiz.dokument_sp sp ON p.doksp_id = sp.doksp_id
LEFT JOIN mbiz.pozycja_zrodlo pz ON p.poz_id = pz.pz_id
FULL JOIN mbiz.dokument_mag mg ON p.dokmag_id = mg.dokmag_id
LEFT JOIN mbiz.kontrahent k ON k.kontr_id = mg.kontr_id
WHERE p.dokmag_id IS NOT NULL and mg.numer like 'Pz%' and pz.poz_id in (SELECT
p.poz_id
FROM mbiz.pozycja p
LEFT JOIN mbiz.dokument_sp sp ON p.doksp_id = sp.doksp_id
WHERE p.dokmag_id IS NOT NULL and sp.data_wystawienia > '2022-01-01' and sp.data_wystawienia < '2022-12-31' and (sp.numer LIKE 'FA%' or sp.numer LIKE 'PG%' or sp.numer LIKE 'FK%' )
) and pz.pz_id IN (
    SELECT pz_id
    FROM mbiz.pozycja_zrodlo
    WHERE poz_id IN (
        SELECT p.poz_id
        FROM mbiz.pozycja p
        LEFT JOIN mbiz.dokument_sp sp ON p.doksp_id = sp.doksp_id
        WHERE sp.numer LIKE '%' or sp.numer LIKE '%'

    )
);


CREATE TEMP VIEW combined_ceny AS
SELECT
    c1.poz_id AS poz_id,
    c1.prefiks AS prefiks,
    c1.indeks AS indeks,
    c1.nazwa AS nazwa,
    c1.nr_oryginalu AS nr_oryginalu,
    c1.mp_org AS mp_org,
    MAX(c1.cenaSP) AS cena_sprzedazy,
	CASE WHEN c1.numer1 LIKE 'FK%' THEN MAX(c1.ilosc1) * -1 ELSE MAX(c1.ilosc1) END AS ilosc_sprzedana,
    MAX(c1.numer1) AS numer_dok_sprzedazy,
	c1.data_wystawienia as data_wystawienia,
    c2.skrot AS skrot,
    c2.nazwa_kont AS nazwa_kont,
    c2.nip AS nip,
    MAX(c2.cenaZA) AS cena_zakupu,
    MAX(c2.ilosc2) AS ilosc_zakupiona
FROM ceny1 c1
FULL JOIN ceny2 c2 ON c1.poz_id = c2.poz_id
GROUP BY
    c1.poz_id,
    c1.prefiks,
    c1.indeks,
    c1.nazwa,
    c1.nr_oryginalu,
    c1.mp_org,
	c1.numer1,
    c2.skrot,
    c2.nazwa_kont,
	c1.data_wystawienia,
    c2.nip
ORDER BY c1.indeks;



select * from combined_ceny;
