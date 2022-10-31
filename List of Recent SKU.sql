SELECT
    CONVERT(VARCHAR(10), min(od.act_date), 111) AS mind
 ,od.material
 ,mt.pu
 ,CONVERT(VARCHAR(10), mtn.lchdate, 111) AS lchd
FROM
    [ivy.sd.fact.order] AS od
    LEFT JOIN [ivy.mm.dim.mtrl] AS mt ON od.material = mt.material
    LEFT JOIN [ivy.mm.dim.mtrl_new] AS mtn ON od.material = mtn.material
WHERE mt.pu != 'common' AND od.gross_amt != 0 AND od.qty != 0
    AND shiptoparty NOT IN ('0011008549', '0011002886', '0011011500','0011011419', '0011011147')
GROUP BY od.material, mt.pu, mtn.lchdate
HAVING min(od.act_date) BETWEEN GETDATE()-90 AND GETDATE()
ORDER BY min(od.act_date)