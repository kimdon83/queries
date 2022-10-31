--SELECT TOP(5) * FROM billmatch1_ivy
--SELECT * FROM billmatch1_ivy 

--SELECT *,  CASE WHEN stpsales in (SELECT stpsales FROM billmatch1) THEN 'match' ELSE 'no' END AS matching FROM billmatch1_ivy

WITH T1 as (
    SELECT * FROM billmatch1 T1 WHERE stpsales in (SELECT stpsales FROM billmatch1_ivy) OR stpsales in (SELECT stpsales FROM billmatch1_ivy)
), ivy_red as (
    SELECT * FROM billmatch1_ivy
    UNION ALL
    SELECT * FROM billmatch1_red
)
SELECT T1.*,T2.[Sales Order], T2.Delivery FROM T1
LEFT JOIN ivy_red T2 on T1.stpsales=T2.stpsales



