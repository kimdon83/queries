DECLARE @pastNmth as int = 17, @futureNmth as int = 15, @pastNmth2 as int = 11;
DECLARE @TheFirstpastNmth as date = ( dateadd(M,-@pastNmth,dateadd(DD,-DAY(   getdate())+1,   getdate())  ) );
DECLARE @TheFirstpastNmth2 as date = ( dateadd(M,-@pastNmth2,dateadd(DD,-DAY(   getdate())+1,   getdate())  ) );
DECLARE @Rankcut as int = 100;
-- DECLARE @mtrlNum as int;
-- SELECT @TheFirstpastNmth2
WITH ppp AS(
    SELECT material, T3.TheFirstOfMonth as act_date, SUM(T1.gross_amt) as gross_amt
    FROM [ivy.sd.fact.bill_ppp] T1
    LEFT JOIN [ivy.mm.dim.shiptoparty] T2 on T1.shiptoparty= T2.shiptoparty
    LEFT JOIN [ivy.mm.dim.date] T3 on T1.act_date = T3.TheDate
    WHERE act_date>=@TheFirstpastNmth and ordsqc>1 and T2.cg_key='TR'
    GROUP BY material,T3.TheFirstOfMonth
), bo as (
    SELECT material, T3.TheFirstOfMonth as act_date, SUM(T1.bo_amt) as bo_amt 
    FROM [ivy.sd.fact.bo] T1
    LEFT JOIN [ivy.mm.dim.shiptoparty] T2 on T1.shiptoparty= T2.shiptoparty
    LEFT JOIN [ivy.mm.dim.date] T3 on T1.act_date = T3.TheDate
    WHERE act_date>=@TheFirstpastNmth and T2.cg_key='TR'
    GROUP BY material,T3.TheFirstOfMonth
), pppbo as (
    SELECT T1.material, T1.act_date, gross_amt, bo_amt, 
    AVG(gross_amt+0.5*COALESCE(bo_amt,0) ) over (partition by T1.material order by T1.act_date ROWS BETWEEN 6 PRECEDING and 1 PRECEDING ) as mean6M
    FROM ppp T1
    LEFT JOIN bo T2 on T1.material = T2.material and T2.act_date = T1.act_date
)
, pppboRank as (
    SELECT material, act_date, gross_amt, bo_amt, mean6M, 
    ROW_NUMBER() over(partition by act_date order by mean6M DESC) as 'RANKING' FROM pppbo
    WHERE act_date >=@TheFirstpastNmth2
), pppboRank2 as (
    SELECT *,
    SUM(mean6M) over (partition by act_date order by mean6M DESC) as cumsum,
    SUM(mean6M) over (partition by act_date ) as totalsum,
    max(RANKING) over (partition by act_date) as maxRanking
    FROM pppboRank  
)
, pppboRank3 as (
SELECT *, cumsum/totalsum as ratio, cast(RANKING as float)/ cast(maxRanking as float) as RankRatio  FROM pppboRank2
)
, pppboRank4 as (
SELECT *, 
--   CASE WHEN  ratio<=0.4 THEN 'A' WHEN ratio <=0.6 THEN 'B' WHEN ratio <=0.80 THEN 'C' WHEN ratio <=0.9 THEN 'D' ELSE 'E' END as Grade 
-- , CASE WHEN  ratio<=0.4 THEN 5 WHEN ratio <=0.6 THEN 4 WHEN ratio <=0.80 THEN 3 WHEN ratio <=0.9 THEN 2 ELSE 1 END as Score
  CASE WHEN  RankRatio<=0.05 THEN 'A' WHEN RankRatio <=0.15 THEN 'B' WHEN RankRatio <=0.25 THEN 'C' WHEN RankRatio <=0.35 THEN 'D' ELSE 'E' END as Grade 
, CASE WHEN  RankRatio<=0.05 THEN 5 WHEN RankRatio <=0.15 THEN 4 WHEN RankRatio <=0.25 THEN 3 WHEN RankRatio <=0.35 THEN 2 ELSE 1 END as Score
FROM pppboRank3
)
,regressionData AS (
    select material, 
    DATEDIFF(Month, MIN(act_date) OVER (PARTITION BY material), act_date) AS x, act_date,
    Score AS y
    FROM pppboRank4
)

,regressionData2 AS (
    SELECT  material,   
        x, AVG(cast(x as float)) OVER (partition by material) as x_bar,
        y, AVG(cast(y as float)) OVER (partition by material) as y_bar,act_date
        ,count(act_date) over (PARTITION BY material) as cnt
    FROM regressionData
)

,regression1 AS ( 
    SELECT 
        material, cnt,
        SUM( (x - x_bar) * (y-y_bar)) / SUM( (x-x_bar) * (x-x_bar)) AS slope
        -- AVG(y) - SUM(x * y) / SUM(x * x) * AVG(x) AS intercept
        ,MAX(y_bar) as y_bar, MAX(x_bar) as x_bar
    FROM regressionData2
    WHERE cnt <>1
    GROUP BY material, cnt
)
-- SELECT * FROM regression1
, regression2 as (
    SELECT material, cnt, slope
    , y_bar- x_bar* slope as intercept
    FROM regression1
)
SELECT T1.*,  DATEDIFF(Month, MIN(act_date) OVER (PARTITION BY T1.material), act_date) * T2.slope + T2.intercept as trend_line
, slope, intercept
FROM pppboRank4 T1
LEFT JOIN regression2 T2 on T1.material=T2.material
WHERE T1.material not in ('DISCOUNT','Master box','REWARD')