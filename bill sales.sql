WITH Tsalesman AS (
    SELECT shiptoparty, salesteam_key, salesteam_text, salesperson_key, salesperson_text, 15 as targetSales,
    CASE WHEN salesdiv='div1' THEN 'Ivy Sales' ELSE 'Red Sales' END as Sales_Company 
    FROM [ivy.mm.dim.sales_master]
), bill_man as (
    SELECT cast(salesdate as date) as act_date, sales, T1.Sales_Company,  targetSales, salesteam_key, salesteam_text, salesperson_key, salesperson_text
    FROM [formonitoringreport] T1
    LEFT JOIN Tsalesman T2 on T1.shiptoparty = T2.shiptoparty
    and T1.Sales_Company= T2.Sales_Company

), bill_man_group as(
    SELECT act_date,  Sales_Company, salesteam_text, salesperson_text, round(SUM(sales),2) as Sales, round(SUM(targetSales),2) as TargetSales
    FROM bill_man T3
    LEFT JOIN [ivy.mm.dim.date] T4 on T3.act_date=t4.TheDate
    WHERE salesperson_text is not null
    GROUP BY act_date, salesperson_text, salesteam_text, Sales_Company
--ORDER BY act_date, salesperson_text, salesteam_text, Sales_Company
)
SELECT *
,SUM(sales) OVER (PARTITION BY salesperson_text, salesteam_text, Sales_Company  ORDER BY act_date) as cumSales
,SUM(TargetSales) OVER (PARTITION BY salesperson_text, salesteam_text, Sales_Company  ORDER BY act_date) as cumTargetSales
FROM bill_man_group
ORDER BY salesperson_text, salesteam_text, Sales_Company, act_date