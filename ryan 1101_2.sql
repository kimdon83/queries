WITH ORGT
AS (
	SELECT t1.*, replace(reverse(PARSENAME(REPLACE(REPLACE(reverse(po_num), '.', ','), '_', '.'), 1)), ',', '.') po_num1
	,CASE	WHEN T2.division is null THEN T1.material
			WHEN T2.division ='X1' THEN T1.material
			else T2.division END  division
	FROM [ivy.sd.fact.bill] T1
	LEFT JOIN [ivy.mm.dim.mtrl] T2 on T1.material=T2.material
	WHERE act_date >= '2022-09-01'
		AND shiptoparty IN (
			SELECT DISTINCT shiptoparty
			FROM [ivy.mm.dim.shiptoparty]
			WHERE cg_key = 'TR'
			)
	), NEWBWT
AS (
	SELECT T1.*, replace(reverse(PARSENAME(REPLACE(REPLACE(reverse(po_num), '.', ','), '_', '.'), 1)), ',', '.') po_num1
	,CASE	WHEN T2.division is null THEN T1.material
			WHEN T2.division ='X1' THEN T1.material
			else T2.division END  division
	FROM [ivy.sd.fact.bill_test] T1
	LEFT JOIN [ivy.mm.dim.mtrl] T2 on T1.material=T2.material
	), ORGT1
AS (
	SELECT sum(gross_amt) gross_amt, CAST(bill_num as varchar) bill_num, division
	FROM ORGT
	GROUP BY bill_num, material,division
	), NEWBWT1
AS (
	SELECT sum(gross_amt) gross_amt, pbnum as bill_num, division
	FROM NEWBWT
	GROUP BY pbnum, division
	)--, Final as (
	SELECT T1.division, T1.bill_num, SUM(T1.gross_amt) gross, T2.division,  T2.bill_num, SUM(T2.gross_amt) gross
	, CASE WHEN T1.division is null THEN 'ORG'
			WHEN T2.division is null THEN 'NEW' 
			ELSE 'BOTH' END as tbl
	FROM NEWBWT1 T1
FULL OUTER JOIN ORGT1 T2 on T1.bill_num=T2.bill_num
GROUP BY T1.division,T2.division, T1.bill_num, T2.bill_num

--SELECT T1.material mtrl1, T2.material mtrl2, T1.gross_amt NEWgross, T2.gross_amt ORGgross, T1.bill_num, T2.bill_num bill_num2
--FROM NEWBWT1 T1
--FULL OUTER JOIN ORGT1 T2 on T1.bill_num=T2.bill_num


--WHERE T1.bill_num is null or T2.bill_num is null
--and (T1.gross_amt!=0 OR T2.gross_amt!=0)

--(abs(T1.gross_amt)>0.00000001 OR abs(T2.gross_amt)>0.00000001)
--)SELECT	CASE WHEN mtrl1 IS NULL then mtrl2 ELSE mtrl1 END material,
--		CASE WHEN mtrl1 IS NULL then ORGgross ELSE NEWgross END gross,
--		CASE WHEN mtrl1 IS NULL then bill_num2 ELSE bill_num END bill_num,
--		CASE WHEN mtrl1 IS NULL then 'ORG' ELSE 'NEW' END tbl
--FROM Final

--ORDER BY material, tbl, gross

