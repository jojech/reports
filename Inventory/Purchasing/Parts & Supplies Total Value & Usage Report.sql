/* Parts & Supplies Total Value & Usage Report */
-- Created by Jeremy 6/28/21
-- Published!

SELECT iB.ItmsGrpNam as 'Item Type'
, v1.CardName as 'Vendor Name'
, x2.itemcode
, x2.SuppCatNum
, x2.ItemName
, '$'+FORMAT(i1.Price,'n2') as 'Purchase Cost'
, FORMAT(sum(x1.MinStock),'n0') as 'Total Mins'
, FORMAT(sum(x1.MaxStock),'n0') as 'Total Maxes'
, FORMAT(sum(x1.onhand),'n0') as 'Total On Hand'
, FORMAT(sum(x1.IsCommited),'n0') as 'Total Committed'
, FORMAT(sum(x1.OnOrder),'n0') as 'Total On Order'
, '$' + FORMAT(i1.Price*sum(x1.onhand),'n2') as 'Current Stock Value'
, '$' + FORMAT(i1.Price*(sum(x1.onhand) + sum(x1.OnOrder) - sum(x1.IsCommited)),'n2') 
        as 'Adjusted Stock Value (incl. Committed + OnOrder)'

, FORMAT(ISNULL(d2.Quantity,0),'n0') as 'NC 6M Usage'
, FORMAT(ISNULL(d3.Quantity,0),'n0') as 'GA 6M Usage'
, FORMAT(ISNULL(d4.Quantity,0),'n0') as 'FL 6M Usage'
, FORMAT(ROUND((ISNULL(d2.Quantity,0))/6,2),'n2') as 'NC AMU'
, FORMAT(ROUND((ISNULL(d3.Quantity,0))/6,2),'n2') as 'GA AMU'
, FORMAT(ROUND((ISNULL(d4.Quantity,0))/6,2),'n2') as 'FL AMU'

, FORMAT(ISNULL(d1.Quantity,0),'n0') as 'TOTAL 6M Usage'
, FORMAT(ROUND((ISNULL(d1.Quantity,0))/6,2),'n2') as 'TOTAL AMU'
, '$' + FORMAT(ROUND((ISNULL(d1.Quantity,0))/6,2)*i1.Price,'n2') as 'AMU Stock Value'
FROM OITM x2 WITH (NOLOCK)
INNER JOIN OITW x1 WITH (NOLOCK) on x1.[ItemCode] = x2.ItemCode 
LEFT JOIN (
    SELECT i.ItemCode
    , sum(d.Quantity) [Quantity]
    FROM OITM i
    INNER JOIN DLN1 d ON i.ItemCode = d.ItemCode
    WHERE DocDate >= dateadd(mm,-5,getdate())
    GROUP BY i.ItemCode
) d1 ON d1.ItemCode = x2.ItemCode 
LEFT JOIN (
    SELECT w.State
    , i.ItemCode
    , sum(d.Quantity) [Quantity]
    FROM OITM i
    INNER JOIN DLN1 d ON i.ItemCode = d.ItemCode
    INNER JOIN OWHS w ON d.WhsCode = w.WhsCode
    WHERE DocDate >= dateadd(mm,-5,getdate())
    AND w.State = 'NC'
    GROUP BY i.ItemCode
    , w.State
) d2 ON d2.ItemCode = x2.ItemCode 
LEFT JOIN (
    SELECT w.State
    , i.ItemCode
    , sum(d.Quantity) [Quantity]
    FROM OITM i
    INNER JOIN DLN1 d ON i.ItemCode = d.ItemCode
    INNER JOIN OWHS w ON d.WhsCode = w.WhsCode
    WHERE DocDate >= dateadd(mm,-5,getdate())
    AND w.State = 'GA'
    GROUP BY i.ItemCode
    , w.State
) d3 ON d3.ItemCode = x2.ItemCode 
LEFT JOIN (
    SELECT w.State
    , i.ItemCode
    , sum(d.Quantity) [Quantity]
    FROM OITM i
    INNER JOIN DLN1 d ON i.ItemCode = d.ItemCode
    INNER JOIN OWHS w ON d.WhsCode = w.WhsCode
    WHERE DocDate >= dateadd(mm,-5,getdate())
    AND w.State = 'FL'
    GROUP BY i.ItemCode
    , w.State
) d4 ON d4.ItemCode = x2.ItemCode 
LEFT JOIN ITM1 i1 WITH (NOLOCK) ON x2.ItemCode = i1.ItemCode AND i1.PriceList = 2
LEFT JOIN OCRD v1 WITH (NOLOCK) ON x2.CardCode = v1.CardCode
LEFT JOIN OITB iB WITH (NOLOCK) ON x2.ItmsGrpCod = iB.ItmsGrpCod
WHERE x2.ItmsGrpCod IN ('102','103')
-- AND x2.ItmsGrpCod <> '107'
AND x2.ItemType <> 'L'
GROUP BY x2.itemcode
        , x2.ItemName
        , x2.SuppCatNum
        , i1.Price
        , v1.CardName
        , iB.ItmsGrpCod
        , iB.ItmsGrpNam
        , d1.Quantity
        , d2.Quantity
        , d3.Quantity
        , d4.Quantity
ORDER BY i1.Price*sum(x1.OnHand) DESC