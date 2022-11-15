WITH T1 as (
SELECT distinct division, count(division) OVER (Partition by division) num ,
count(division) OVER (Partition by division)/cast((SELECT count(*) 
FROM [ivy.mm.dim.mtrl]) as float)*100 as ratio FROM [ivy.mm.dim.mtrl]
) 
SELECT * FROM T1
ORDER BY num desc





