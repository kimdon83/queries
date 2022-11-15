WITH T1 as (
    SELECT act_date, material, plant, SUM(qty) qty
    FROM [ivy.sd.fact.bill]
    WHERE act_date BETWEEN  DateADD(MM,-4 ,DATEADD(DD, - DAY(GETDATE()), GETDATE())) AND DateAdd(MM,-3,GETDATE()) 
    and material= 'KPEG03'
    GROUP BY act_date, material, plant
)
    SELECT act_date, material, plant, qty, AVG(qty) OVER (Partition by material, plant ORDER BY act_date) as running_avg
    FROM T1
    ORDER BY plant, act_date, material