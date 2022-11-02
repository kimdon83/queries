WITH ORGT
AS (
	SELECT t1.*, CASE WHEN T2.division IS NULL THEN T1.material WHEN T2.division = 'X1' THEN T1.material ELSE T2.division END division
	FROM [ivy.sd.fact.bill] T1
	LEFT JOIN [ivy.mm.dim.mtrl] T2 ON T1.material = T2.material
	WHERE act_date >= '2022-09-01'
		AND shiptoparty IN (
			SELECT DISTINCT shiptoparty
			FROM [ivy.mm.dim.shiptoparty]
			WHERE cg_key = 'TR'
			)
	), NEWBWT
AS (
	SELECT T1.*, CASE WHEN T2.division IS NULL THEN T1.material WHEN T2.division = 'X1' THEN T1.material ELSE T2.division END division
	FROM [ivy.sd.fact.bill_test] T1
	LEFT JOIN [ivy.mm.dim.mtrl] T2 ON T1.material = T2.material
	), ORGT1
AS (
	SELECT sum(gross_amt) gross_amt, CAST(bill_num AS VARCHAR) bill_num, division
	FROM ORGT
	GROUP BY bill_num, material, division
	), NEWBWT1
AS (
	SELECT sum(gross_amt) gross_amt, cast(pbnum as varchar) AS bill_num, division
	FROM NEWBWT
	GROUP BY pbnum, division
	), Final as (
SELECT T1.division div_new, T1.bill_num bill_num_new, T1.gross_amt gross_new, T2.division div, T2.bill_num, T2.gross_amt gross, 
CASE WHEN T1.division IS NULL THEN 'ORG' WHEN T2.division IS NULL THEN 'NEW' ELSE 'BOTH' END AS tbl
FROM NEWBWT1 T1
FULL OUTER JOIN ORGT1 T2 ON T1.division=T2.division
)
SELECT div_new, bill_num_new, gross_new, div, bill_num, gross from Final
