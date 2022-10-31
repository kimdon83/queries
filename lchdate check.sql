WITH
    T1
    AS

    (
        SELECT
            a.material
 ,a.act_date
 ,a.po_num
        FROM
            order_ppp AS a
            LEFT JOIN [ivy.mm.dim.shiptoparty] AS b
            ON a.shiptoparty = b.shiptoparty
        WHERE a.act_date >= '2017-01-01'
            AND a.shiptoparty NOT IN ('0011008549', '0011002886', '0011011500','0011011419', '0011011147')
            AND a.qty > 0
            AND a.gross_amt > 0
            AND a.material IN (SELECT
                DISTINCT
                material

            FROM
                [ivy.mm.dim.lchdate]
 )
            AND b.cg_key = 'TR'
    )
 ,T2
    AS

    (
        SELECT
            T1.material
 ,b.plant
 ,T1.act_date
 ,count(DISTINCT T1.po_num) AS ordercount
        FROM
            T1
            LEFT JOIN [ivy.sd.fact.bill] AS b
            ON T1.po_num = b.po_num
        WHERE b.plant IN ('1100', '1110', '1400', '1410')
        GROUP BY T1.material, b.plant, T1.act_date
    )
 ,T3
    AS

    (
        SELECT
            T2.material
 ,d.ext_mg
 ,d.division
 ,(CASE WHEN d.division = 'L6' AND d.salesdiv = 'div2' THEN 'epu' ELSE d.pu END) AS pu
 ,T2.plant
 ,CONVERT(DATE, c.som_lchdate, 23) AS lchdate
 ,DATENAME(WEEKDAY, c.som_lchdate) AS [weekday]
 ,CONVERT(DATE, T2.act_date, 23) AS act_date
 ,DATEDIFF(day, CONVERT(DATE, c.som_lchdate, 23), CONVERT(DATE, T2.act_date, 23)) AS countdiff
 ,T2.ordercount
        FROM
            T2
            LEFT JOIN [ivy.mm.dim.lchdate] AS c
            ON T2.material = c.material
                AND T2.plant = c.plant
            LEFT JOIN [ivy.mm.dim.mtrl] AS d
            ON T2.material = d.material
        WHERE c.som_lchdate != 'Check'
            AND c.som_lchdate != 'None'
            AND c.som_lchdate != 'Inspect later'
    )
 -- except Check or None or Inspect later case
 ,T4
    AS

    (
        SELECT
            *
        FROM
            (SELECT
                material
 ,pu
 ,division
 ,ext_mg
 ,plant
 ,lchdate
 ,weekday
 ,countdiff
 ,ordercount
            FROM
                T3
            WHERE countdiff BETWEEN -30 AND 180) AS result
PIVOT (max(ordercount) FOR countdiff IN ([-30], [-29], [-28], [-27], [-26], [-25], [-24], [-23], [-22], [-21], [-20], [-19], [-18], [-17], [-16], [-15], [-14], [-13], [-12], [-11], [-10],
[-9], [-8], [-7], [-6], [-5], [-4], [-3], [-2], [-1], [0], [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [24], [25], [26], [27], [28],
[29], [30], [31], [32], [33], [34], [35], [36], [37], [38], [39], [40], [41], [42], [43], [44], [45], [46], [47], [48], [49], [50], [51], [52], [53], [54], [55], [56], [57], [58], [59], [60], [61], [62], [63],
[64], [65], [66], [67], [68], [69], [70], [71], [72], [73], [74], [75], [76], [77], [78], [79], [80], [81], [82], [83], [84], [85], [86], [87], [88], [89], [90], [91], [92], [93], [94], [95], [96], [97], [98],
[99], [100], [101], [102], [103], [104], [105], [106], [107], [108], [109], [110], [111], [112], [113], [114], [115], [116], [117], [118], [119], [120], [121], [122], [123], [124], [125], [126], [127],
[128], [129], [130], [131], [132], [133], [134], [135], [136], [137], [138], [139], [140], [141], [142], [143], [144], [145], [146], [147], [148], [149], [150], [151], [152], [153], [154], [155], [156], [157],
[158], [159], [160], [161], [162], [163], [164], [165], [166], [167], [168], [169], [170], [171], [172], [173], [174], [175], [176], [177], [178], [179], [180])) AS pivot_result
    )
SELECT
    *
FROM
    T4



