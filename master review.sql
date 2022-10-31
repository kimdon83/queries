WITH
    pppbreak
    AS
    (
        SELECT
            od.act_date
 ,od.po_num
 ,mtn.lchdate
 ,(CASE WHEN bom.bom_comp_material IS NOT NULL THEN bom.bom_comp_material ELSE od.material END) AS material
 ,(CASE WHEN mt.division = 'L6' AND mt.salesdiv = 'div2' THEN 'epu' ELSE mt.pu END) AS 'pu'
        FROM
            [ivy.sd.fact.order] AS od
            LEFT JOIN [ivy.mm.dim.bom] AS bom ON od.material = bom.bom_parent_material 
            LEFT JOIN [ivy.mm.dim.mtrl] AS mt ON od.material = mt.material
            LEFT JOIN [ivy.mm.dim.mtrl_new] AS mtn ON od.material = mtn.material
        WHERE od.material IN (SELECT -- condition for mtrl
                odr.material
            FROM
                [ivy.sd.fact.order] AS odr LEFT JOIN [ivy.mm.dim.mtrl] AS mtt ON odr.material = mtt.material
            WHERE mtt.pu != 'common'
            GROUP BY odr.material, mtt.pu
            HAVING min(odr.act_date) BETWEEN GETDATE()-90 AND GETDATE()) -- order within 3month
            AND od.shiptoparty NOT IN ('0011008549', '0011002886', '0011011500','0011011419', '0011011147')
            AND od.gross_amt != 0 AND od.qty != 0 AND od.qty >= mt.ip --- od.gross_amt != 0 => to exclude ASET or tester
    )
SELECT
    CONVERT(VARCHAR(10), act_date, 111) AS ordate
 ,material
 ,count(DISTINCT po_num) AS NumberofOrders
 ,pu
 ,CONVERT(VARCHAR(10),lchdate, 111) AS lchd
FROM
    pppbreak
WHERE material NOT IN (SELECT
    material
FROM
    [ivy.mm.dim.lchdate]
WHERE som_lchdate NOT IN ('Check', 'none')) -- inspect later는 다시 나옴 
-- #TODO: modify after character is moved from som_lchdate to new column
GROUP BY CONVERT(VARCHAR(10), act_date, 111), material, pu, lchdate
ORDER BY CONVERT(VARCHAR(10), act_date, 111) ASC