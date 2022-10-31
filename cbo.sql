WITH ta
AS (
	SELECT t1.salesorg AS 'Company', CASE 
			WHEN T2.customer_key IS NULL
				THEN T1.shiptoparty
			ELSE T2.customer_key
			END AS 'Customer #', 
			t1.bill_num 'Billing #', t1.po_num 'PO#', '' AS 'Billing Item #', T1.material AS 'Material', '' AS 'SO Item#', 
			t1.qty 'Billing Qty', t1.gross_amt 'Billing Amt.', 
			T3.qty 'Order Qty', t3.gross_amt 'Order Amt.', 
			t4.bo_qty 'BackOrder Qty', CAST(t1.act_date as DATE) 'Billing Date', T1.shiptoparty, 
			T1.po_type, T2.salesperson_div1_text as salesperson_div1, T2.salesperson_div2_text as salesperson_div2
	FROM [ivy.sd.fact.bill] T1
	LEFT JOIN [ivy.mm.dim.shiptoparty] T2 ON T1.shiptoparty = T2.shiptoparty
	LEFT JOIN (
		SELECT sum(gross_amt) AS 'gross_amt', sum(qty) AS qty, shiptoparty, po_num, material
		FROM [ivy.sd.fact.order]
		GROUP BY shiptoparty, po_num, material
		) T3 ON T1.shiptoparty = T3.shiptoparty
		AND T1.po_num = T3.po_num
		AND T1.material = T3.material
	LEFT JOIN (
		SELECT sum(bo_qty) AS 'bo_qty', shiptoparty, po_num, material
		FROM [ivy.sd.fact.bo]
		GROUP BY shiptoparty, po_num, material
		) T4 ON T1.shiptoparty = T4.shiptoparty
		AND T1.po_num = T4.po_num
		AND T1.material = T4.material
	WHERE t1.act_date BETWEEN '2022-08-31'
			AND '2022-09-28'
	)
SELECT *
FROM ta