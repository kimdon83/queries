WITH origin
AS (
	SELECT cast(bill_num AS VARCHAR) AS bn, gross_amt, qty, (CASE WHEN mt.division IS NULL THEN bl.material WHEN mt.division = 'x1' THEN bl.material ELSE mt.division END) AS division
	FROM [ivy.sd.fact.bill] AS bl
	LEFT JOIN [ivy.mm.dim.mtrl] AS mt ON bl.material = mt.material
	WHERE act_date BETWEEN '2022-09-01'
			AND '2022-09-30'
		AND shiptoparty IN (
			SELECT shiptoparty
			FROM [ivy.mm.dim.shiptoparty]
			WHERE cg_key = 'TR'
			)
	), orin
AS (
	SELECT DISTINCT bn, division, sum(gross_amt) AS sales, sum(qty) AS qtys
	FROM origin
	GROUP BY bn, division
	), newrigin
AS (
	SELECT cast(pbnum AS VARCHAR) AS pbnum, gross_amt, qty, (CASE WHEN mt.division IS NULL THEN blt.material WHEN mt.division = 'x1' THEN blt.material ELSE mt.division END) AS division
	FROM [ivy.sd.fact.bill_test] AS blt
	LEFT JOIN [ivy.mm.dim.mtrl] AS mt ON blt.material = mt.material
	WHERE act_date BETWEEN '2022-09-01'
			AND '2022-09-30'
		AND shiptoparty IN (
			SELECT shiptoparty
			FROM [ivy.mm.dim.shiptoparty]
			WHERE cg_key = 'TR'
			)
	), newrin
AS (
	SELECT DISTINCT pbnum, division, sum(gross_amt) AS sales, sum(qty) AS qtys
	FROM newrigin
	GROUP BY pbnum, division
	)
SELECT oi.division AS oidivision, oi.bn AS oipo, oi.sales AS oisales, oi.qtys AS oiqtys, ni.division AS nidivision, ni.pbnum AS nipo, ni.sales AS nisales, ni.qtys AS niqtys, (cast(ni.sales AS FLOAT) - cast(oi.sales AS FLOAT)) AS diffnewtoold
FROM orin AS oi
FULL OUTER JOIN newrin AS ni ON oi.bn = ni.pbnum
	AND oi.division = ni.division
WHERE oi.bn IS NULL
	OR ni.pbnum IS NULL