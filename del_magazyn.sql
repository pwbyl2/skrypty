SELECT current_timestamp;
select count (*) from mbiz.magazyn where nr_magazynu = '10';


DO $dele$
DECLARE
    loop_count INTEGER := 0;
    ile INTEGER := 10000;
    zostalo INTEGER := 0;
    start_time TIMESTAMP;
    end_time TIMESTAMP;
    time_diff INTERVAL; -- Store the interval difference
    formatted_time TEXT;
BEGIN
    start_time := clock_timestamp(); -- Capture the start time

    LOOP
        DELETE FROM mbiz.magazyn AS m
        WHERE m.nr_magazynu = '10' AND m.art_id IN (
            SELECT art_id
            FROM mbiz.magazyn
            WHERE nr_magazynu = '10'
            LIMIT 1
        );

        loop_count := loop_count + 1;
        zostalo := ile - loop_count;

        EXIT WHEN zostalo = 0;
    END LOOP;

    end_time := clock_timestamp(); -- Capture the end time

    time_diff := end_time - start_time; -- Calculate the time difference

    -- Format the time explicitly using TO_CHAR
    formatted_time := TO_CHAR(time_diff, 'HH24:MI:SS.US');

    RAISE NOTICE 'Time taken: %', formatted_time; -- Display the formatted time
END;
$dele$;


select count (*) from mbiz.magazyn where nr_magazynu = '10';

SELECT current_timestamp;
