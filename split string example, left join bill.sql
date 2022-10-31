--SELECT * FROM [ivy.sd.fact.bill] WHERE act_date= '2022-08-31'
 
WITH bill AS(
	SELECT shiptoparty, replace(
reverse(PARSENAME(REPLACE(REPLACE(reverse(po_num), '.', ','),'_','.'),1)),
',','.') po_num
,
reverse(PARSENAME(REPLACE(REPLACE(reverse(po_num), '.', ','),'_','.'),2)) po_num2
	, po_type, SUM(gross_amt) gross FROM [ivy.sd.fact.bill] WHERE act_date >= '2022-08-31' and act_date <= '2022-09-15'
	GROUP BY shiptoparty, po_num, po_type
), match2 as(
	SELECT Saty, POtyp, [Sold-to pt], [Name 1], [Doc. Date], Document,
		replace(
reverse(PARSENAME(REPLACE(REPLACE(reverse([PO number]), '.', ','),'_','.'),1)),
',','.') po_num
,
reverse(PARSENAME(REPLACE(REPLACE(reverse([PO number]), '.', ','),'_','.'),2)) po_num2,
		[  Net value], DlBl, Status, Created, [Req.dlv.dt], [SOff.], Plnt,OrdRs, Time, comp, [Created by]
	FROM billmatch2
	)

SELECT * FROM match2 Ti
LEFT JOIN bill as T1
on Ti.[Sold-to pt]=T1.shiptoparty and Ti.po_num=T1.po_num and Ti.POtyp = T1.po_type

