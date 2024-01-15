set search_path to mbiz;
do $zrodlo$
DECLARE
  num_rows integer;
  i integer;
  il integer := 1;
  max_il integer := 5;  
  pzid RECORD;
  sumadok INTEGER;
  sprzedano INTEGER;
  zostalo INTEGER;
  pozidid INTEGER;
  pozilosc INTEGER;
  nastanie INTEGER;
  
BEGIN

select count( * ) into num_rows from (
SELECT
    poz.poz_id,
    SUM (poz.ilosc) ilosc,
  a.prefiks_indeks,
  D.numer,
  D.data_wystawienia
FROM
    mbiz.dokument_sp d
LEFT OUTER JOIN kontrahent K ON d.kontr_id = K .kontr_id
JOIN pozycja poz ON d.doksp_id = poz.doksp_id
JOIN s_stawka_vat sv ON poz.nr_stawki_vat = sv.nr_stawki_vat
JOIN artykul A ON poz.art_id = A .art_id
WHERE
    d.RODZAJ in ('F','G','R')
AND d.status = 'W'
-- AND d.filia_id = '3'
AND POZ.STATUS = 'O'
AND (d.znacznik & 32) <> 32
--PS Odkomentowanie linijki wyzej spowodouje nie uwzglednianie dokumentow anulowanych czyli AFA i APG
    AND DATE (d.data_wystawienia) >= CURRENT_DATE-7
    AND DATE (d.data_wystawienia) <= CURRENT_DATE
AND A.RODZAJ <> 'U'
AND ILOSC > 0
GROUP BY
    poz.poz_id, a.prefiks_indeks, d.numer, D.data_wystawienia
EXCEPT
    SELECT
        poz.poz_id,
        SUM (pzr.ilosc) ilosc,
  a.prefiks_indeks,
  d.numer,
  D.data_wystawienia
    FROM
        mbiz.dokument_sp d
    LEFT OUTER JOIN kontrahent K ON d.kontr_id = K .kontr_id
    JOIN pozycja poz ON d.doksp_id = poz.doksp_id
    JOIN s_stawka_vat sv ON poz.nr_stawki_vat = sv.nr_stawki_vat
    JOIN artykul A ON poz.art_id = A .art_id
    LEFT OUTER JOIN POZYCJA_ZRODLO pzr ON POZ.POZ_ID = PZR.POZ_ID
    WHERE
        d.RODZAJ in ('F','G','R')
    AND d.status = 'W'
    -- AND d.filia_id = '3'
    AND POZ.STATUS = 'O'
    AND (d.znacznik & 32) <> 32
    --PS Odkomentowanie linijki wyzej spowodouje nie uwzglednianie dokumentow anulowanych czyli AFA i APG
    AND DATE (d.data_wystawienia) >= CURRENT_DATE-7
    AND DATE (d.data_wystawienia) <= CURRENT_DATE
    GROUP BY
        poz.poz_id,  a.prefiks_indeks, d.numer, D.data_wystawienia
        
        ) x;



CREATE TEMP TABLE temp_poz_id (poz_id INT PRIMARY KEY);

FOR i IN 1..num_rows LOOP


SELECT
    poz.poz_id,
    SUM (poz.ilosc) ilosc,
  a.prefiks,
  a.indeks,
  D.numer,
  D.data_wystawienia
  into
  pozidid,
  pozilosc
FROM
    mbiz.dokument_sp d
LEFT OUTER JOIN kontrahent K ON d.kontr_id = K .kontr_id
JOIN pozycja poz ON d.doksp_id = poz.doksp_id
JOIN s_stawka_vat sv ON poz.nr_stawki_vat = sv.nr_stawki_vat
JOIN artykul A ON poz.art_id = A .art_id
WHERE
    d.RODZAJ in ('F','G','R')
AND d.status = 'W'
-- AND d.filia_id = '3'
AND POZ.STATUS = 'O'
AND (d.znacznik & 32) <> 32
    AND DATE (d.data_wystawienia) >= CURRENT_DATE-7
    AND DATE (d.data_wystawienia) <= CURRENT_DATE
AND A.RODZAJ <> 'U'
AND ILOSC > 0
AND poz_id NOT IN (SELECT poz_id FROM temp_poz_id)
GROUP BY
    poz.poz_id, a.prefiks, a.indeks, d.numer, D.data_wystawienia
EXCEPT
    SELECT
        poz.poz_id,
        SUM (pzr.ilosc) ilosc,
a.prefiks,
  a.indeks,
  d.numer,
  D.data_wystawienia
    FROM
        mbiz.dokument_sp d
    LEFT OUTER JOIN kontrahent K ON d.kontr_id = K .kontr_id
    JOIN pozycja poz ON d.doksp_id = poz.doksp_id
    JOIN s_stawka_vat sv ON poz.nr_stawki_vat = sv.nr_stawki_vat
    JOIN artykul A ON poz.art_id = A .art_id
    LEFT OUTER JOIN POZYCJA_ZRODLO pzr ON POZ.POZ_ID = PZR.POZ_ID
    WHERE
        d.RODZAJ in ('F','G','R')
    AND d.status = 'W'
    -- AND d.filia_id = '3'
    AND POZ.STATUS = 'O'
    AND (d.znacznik & 32) <> 32
    AND DATE (d.data_wystawienia) >= CURRENT_DATE-7
    AND DATE (d.data_wystawienia) <= CURRENT_DATE
    GROUP BY
        poz.poz_id,  a.prefiks, a.indeks, d.numer, D.data_wystawienia limit 1;



  sumadok  := COALESCE((SELECT SUM(ilosc) FROM mbiz.pozycja_zrodlo WHERE poz_id = pozidid), 0);
  sprzedano := COALESCE(pozilosc,0);
  zostalo := sprzedano - sumadok;
  nastanie := (select COALESCE((select sum(ilosc_na_stanie) FROM mbiz.pozycja WHERE art_id = (select art_id from mbiz.pozycja where poz_id = pozidid) and ilosc_na_stanie > 0 and nr_magazynu_poz = (SELECT nr_magazynu_poz FROM pozycja WHERE poz_id = pozidid)),0));

RAISE NOTICE ' sumadok = %', sumadok;
RAISE NOTICE ' sprzedano = %', sprzedano;
RAISE NOTICE ' zostalo = %', zostalo;

RAISE NOTICE ' pozidid = %', pozidid;
RAISE NOTICE ' pozilosc = %', pozilosc;
RAISE NOTICE ' nastanie = %', nastanie;

INSERT INTO temp_poz_id (poz_id) VALUES (pozidid);

 LOOP

    RAISE NOTICE 'loop0 zostalo = %', zostalo;
	RAISE NOTICE 'loop count i = %', i;	
	IF zostalo <= 0 THEN
		RAISE NOTICE 'exit loop zostalo <=0';
		EXIT;
	END IF;
	
 	IF  nastanie - sprzedano < 0 and nastanie <=0 THEN
		RAISE NOTICE 'exit loop ilosc na stanie <=0';	
		EXIT;
	END IF;   	


    FOR pzid IN (SELECT poz_id, COALESCE(ilosc_na_stanie, sprzedano) AS ilosc_na_stanie, art_id, nr_magazynu_poz, data_modyfikacji FROM mbiz.pozycja WHERE nr_magazynu_poz = (SELECT nr_magazynu_poz FROM pozycja WHERE poz_id = pozidid) AND art_id = (SELECT art_id FROM mbiz.pozycja WHERE poz_id = pozidid) AND ilosc_na_stanie > 0 ORDER BY data_modyfikacji ASC)
    LOOP
	--  IF il > max_il THEN
	--	EXIT;
	--  END IF;	
      RAISE NOTICE 'loop1 zostalo = %', zostalo;
	  il := il + 1;
      IF zostalo >= pzid.ilosc_na_stanie AND pzid.ilosc_na_stanie > 0 AND zostalo > 0 THEN
        INSERT INTO mbiz.pozycja_zrodlo (poz_id, pz_id, data_pz, ilosc) VALUES (pozidid, pzid.poz_id, pzid.data_modyfikacji, pzid.ilosc_na_stanie);
        zostalo := zostalo - pzid.ilosc_na_stanie;
        RAISE NOTICE 'loop2 zostalo = %', zostalo;
        UPDATE mbiz.pozycja SET ilosc_na_stanie = 0 WHERE poz_id = pzid.poz_id;
      ELSIF zostalo > 0 THEN
      RAISE NOTICE 'loop3 zostalo = %', zostalo;
        INSERT INTO mbiz.pozycja_zrodlo (poz_id, pz_id, data_pz, ilosc) VALUES (pozidid, pzid.poz_id, pzid.data_modyfikacji, zostalo);
        UPDATE mbiz.pozycja SET ilosc_na_stanie = (ilosc_na_stanie - zostalo) WHERE poz_id = pzid.poz_id;
        zostalo := 0;
      ELSE
      RAISE NOTICE 'loop4 zostalo = %', zostalo;
	  il := 1;
        EXIT; -- exit loop if zostalo is not enough
      END IF;
    END LOOP;
  END LOOP;
END LOOP;
END;
$zrodlo$
