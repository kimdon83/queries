WITH Tmonth AS (
    SELECT distinct format(theDate,'yyyyMM') YM FROM [ivy.mm.dim.date] WHERE YEAR(TheDate)=2021
), Tmtrl as ( 
    SELECT material FROM [ivy.mm.dim.mtrl] WHERE material in ('2462','2464N','2464V')
), YMmtrl AS (
    SELECT * FROM Tmonth    CROSS JOIN Tmtrl
),YMorderT as (
    SELECT material, SUM(gross_amt) gross, format(act_date,'yyyyMM') YM FROM [ivy.sd.fact.order]
    WHERE material in ('2462','2464N','2464V')
    and year(act_date)=2021
    GROUP BY material, format(act_date,'yyyyMM')
), yearTotalT AS( 
    SELECT SUM(gross_amt) yearTotal, T1.material, mg
    FROM [ivy.sd.fact.order] T1
    LEFT JOIN [ivy.mm.dim.mtrl] T2 on T1.material= T2.material
    WHERE year(act_date)=2021
    and T1.material in ('2462','2464N','2464V')
    GROUP BY T1.material, T2.mg
),TotalGrossT AS (
    SELECT SUM(gross_amt) total , mg FROM [ivy.sd.fact.order] T1 
	LEFT JOIN [ivy.mm.dim.mtrl] T2 on T1.material= T2.material
	WHERE YEAR(act_date)=2021 and mg is not null
	GROUP BY mg
), mgT0 AS ( 
	SELECT SUM(gross_amt) gross, T2.mg, format(act_date,'yyyyMM') YM FROM [ivy.sd.fact.order] T1
	LEFT JOIN [ivy.mm.dim.mtrl] T2 on T1.material= T2.material
	WHERE YEAR(act_date)=2021
	GROUP BY T2.mg, format(act_date,'yyyyMM')
), mgT as (
    SELECT CASE WHEN total =0 then 0 ELSE gross/total END gross_ratio_mg, T1.mg, T1.YM FROM mgT0 T1
    LEFT JOIN TotalGrossT T2 on T1.mg=T2.mg
)
)
SELECT T1.YM, T1.material, gross/yearTotal ratio0, gross_ratio_mg,
    CASE WHEN (SELECT count(material) FROM YMorderT)=12 THEN gross/yearTotal ELSE gross_ratio_mg END ratio
FROM YMmtrl T1
LEFT JOIN YMorderT T2 on T1.material=T2.material and T1.YM=T2.YM
LEFT JOIN yearTotalT T3 on T1.material= T3.material
LEFT JOIN mgT T4 on T3.mg=T4.mg and T4.YM=T1.YM
ORDER BY material, YM



