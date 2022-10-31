WITH  pppbreak AS
    (
        SELECT
            bill.act_date
            ,bill.po_num
            ,mtn.lchdate
            ,bill.plant
 ,(CASE WHEN bom.bom_comp_material IS NOT NULL THEN bom.bom_comp_material ELSE bill.material END) AS material
 ,(CASE WHEN mt.division = 'L6' AND mt.salesdiv = 'div2' THEN 'epu' ELSE mt.pu END) AS 'pu'
        FROM
            [ivy.sd.fact.bill] AS bill
            LEFT JOIN [ivy.mm.dim.bom] AS bom ON bill.material = bom.bom_parent_material
            LEFT JOIN [ivy.mm.dim.mtrl] AS mt ON bill.material = mt.material
            LEFT JOIN [ivy.mm.dim.mtrl_new] AS mtn ON bill.material = mtn.material
            LEFT JOIN [ivy.mm.dim.shiptoparty] AS STP on STP.shiptoparty=bill.shiptoparty
        WHERE bill.shiptoparty NOT IN ('0011008549', '0011002886', '0011011500','0011011419', '0011011147')
            AND mt.ms like '%1'
            AND mt.mg NOT IN ('PP','ZZ','ZX','XG','X1','PPP','BN','IN','PPM','SWB')
            AND mt.ext_code NOT IN ('BAN','TST','PPM','PPP','PPS','SAM')
            AND mt.brand NOT IN ('000','DSN','FKA','FKJ','FKS','FN','HDB','HS','JC','KIS','KKK','KSA','KSK','SLV','TN')
            AND bill.gross_amt != 0 AND bill.qty != 0 AND bill.qty >= mt.ip
            AND STP.cg_key ='TR'
                AND bill.material IN (SELECT
                    bill.material
                FROM
                    [ivy.sd.fact.bill] AS bill LEFT JOIN [ivy.mm.dim.mtrl] AS mtt ON bill.material = mtt.material
                WHERE mtt.pu != 'common'
                GROUP BY bill.material, mtt.pu
                HAVING min(bill.act_date) BETWEEN GETDATE()-90 AND GETDATE())
    )
    ,T1
    AS
    (
        SELECT
            pu
            ,CONVERT(VARCHAR(10), act_date, 111) AS billdate ,material
            ,plant
            ,count(DISTINCT po_num) AS NumberofOrders  ,CONVERT(VARCHAR(10),lchdate, 111) AS sap_lchdate
        FROM
            pppbreak
        WHERE material NOT IN (SELECT
            material
        FROM
            [ivy.mm.dim.lchdate]
        WHERE som_lchdate NOT IN ('none'))
        GROUP BY CONVERT(VARCHAR(10), act_date, 111), material, pu, lchdate, plant
    )
SELECT
    pu
    ,billdate
    ,material
    ,plant
    ,SUM(NumberofOrders) NumberofOrders
    ,sap_lchdate
    ,MIN(billdate) OVER (PARTITION BY material,pu,sap_lchdate,plant) AS first_order
    
    ,NULL AS som_lchdate
FROM
    T1
GROUP BY billdate, pu,material, plant, sap_lchdate
ORDER BY pu, material, plant, billdate ASC