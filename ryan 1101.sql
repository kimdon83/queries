WITH ORGT
AS (
	SELECT t1.*, replace(reverse(PARSENAME(REPLACE(REPLACE(reverse(po_num), '.', ','), '_', '.'), 1)), ',', '.') po_num1
	,T2.division
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
	,T2.division
	FROM [ivy.sd.fact.bill_test] T1
	LEFT JOIN [ivy.mm.dim.mtrl] T2 on T1.material=T2.material
	), ORGT1
AS (
	SELECT material, sum(gross_amt) gross_amt, po_num1
	FROM ORGT
	GROUP BY po_num1, material
	), NEWBWT1
AS (
	SELECT material, sum(gross_amt) gross_amt, po_num1
	FROM NEWBWT
	GROUP BY po_num1, material
	), Final as (
SELECT T1.material mtrl1, T2.material mtrl2, T1.gross_amt NEWgross, T2.gross_amt ORGgross, T1.po_num1 po_num1, T2.po_num1 po_num2
FROM NEWBWT1 T1
FULL OUTER JOIN ORGT1 T2 on T1.po_num1=T2.po_num1
WHERE (T1.material is null or T2.material is null) and (abs(T1.gross_amt)>0.00000001 OR abs(T2.gross_amt)>0.00000001)
)
SELECT	CASE WHEN mtrl1 IS NULL then mtrl2 ELSE mtrl1 END material,
		CASE WHEN mtrl1 IS NULL then ORGgross ELSE NEWgross END gross,
		CASE WHEN mtrl1 IS NULL then po_num2 ELSE po_num1 END po_num1,
		CASE WHEN mtrl1 IS NULL then 'ORG' ELSE 'NEW' END tbl
FROM Final
ORDER BY material, tbl, gross

