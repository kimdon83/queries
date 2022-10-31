--SELECT * FROM [ivy.sd.fact.bill] WHERE act_date= '2022-08-31'
 
WITH bill0 AS(
SELECT
    shiptoparty,
    replace(
reverse(PARSENAME(REPLACE(REPLACE(reverse(po_num), '.', ','),'_','.'),1)),
',','.') po_num1
,
reverse(PARSENAME(REPLACE(REPLACE(reverse(po_num), '.', ','),'_','.'),2)) po_num2
	, po_type, gross_amt
    FROM [ivy.sd.fact.bill] WHERE act_date >= '2022-08-22' and act_date <= '2022-09-15'
), bill AS(
SELECT
    shiptoparty , po_num1, po_type, SUM(gross_amt) gross
    FROM bill0	GROUP BY shiptoparty, po_num1, po_type
),
match2_0 as(
	SELECT POtyp, [Sold-to pt] shiptoparty,
        replace(
reverse(PARSENAME(REPLACE(REPLACE(reverse([PO number]), '.', ','),'_','.'),1)),
',','.') po_num1
,
reverse(PARSENAME(REPLACE(REPLACE(reverse([PO number]), '.', ','),'_','.'),2)) po_num2,
		[  Net value], comp
	FROM billmatch2
	),    match2 as(
	SELECT POtyp, shiptoparty, po_num1 , SUM([  Net value]) 'NetValue', comp
	FROM match2_0
    GROUP BY shiptoparty, po_num1, POtyp, comp
	)

SELECT POtyp, Ti.shiptoparty, T1.shiptoparty, Ti.po_num1, T1.po_num1, NetValue, gross, comp
 FROM match2 Ti
LEFT JOIN bill as T1
on Ti.po_num1=T1.po_num1 and Ti.POtyp = T1.po_type
