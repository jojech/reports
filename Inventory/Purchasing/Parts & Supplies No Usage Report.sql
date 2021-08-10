/* Parts & Supplies without Usage Report */
-- Created by Jeremy 6/28/21

SELECT Y0.State
, Y0.WhsCode
, Y0.WhsName
, iB.ItmsGrpNam as 'Item Type'
-- , iB.ItmsGrpCod as 'Type #'
, v1.CardName as 'Vendor Name'
, x2.itemcode
, x2.SuppCatNum
, x2.ItemName
, '$'+FORMAT(i1.Price,'n2') as 'Purchase Cost'
, x2.PUomEntry
, '$'+FORMAT(i9.Price,'n2') as 'Purchase Cost UoM'
, i91.UomName as 'Purchase Type'
, FORMAT(x2.NumInBuy,'n0') as 'Items/Unit'
, '$'+FORMAT(i1.Price/x2.NumInBuy,'n2') as 'Purchase Cost/Item'
, FORMAT(x1.MinStock,'n0') as 'Min'
, FORMAT(x1.MaxStock,'n0') as 'Max'
, FORMAT(x1.onhand,'n0') as 'On Hand'
, '$' + FORMAT(i1.Price*x1.onhand,'n2') as 'Current Stock Value (Orig.)'
, '$' + FORMAT((i1.Price/x2.NumInBuy)*x1.onhand,'n2') as 'Current Stock Value Items/Unit'
, '$' + FORMAT(i9.Price*x1.onhand,'n2') as 'Current Stock Value UoM'
, '$' + FORMAT(i1.Price*(x1.onhand + x1.OnOrder - x1.IsCommited),'n2') as 'Adj. Stock Value (incl. Committed + OnOrder)'
, FORMAT(ISNULL(sum(d1.Quantity),0),'n0') as '6M Total Usage'

, FORMAT(x1.OnOrder,'n0') as 'On Order (Incoming)'
, FORMAT(x1.IsCommited,'n0') as 'Committed (Outgoing)'
-- , FORMAT(x1.onhand - x1.IsCommited + x1.OnOrder,'n0') as 'Order Qty'
, FORMAT(ROUND((ISNULL(sum(d1.Quantity),0))/6,2),'n2') as 'AMU'
, CASE 
    WHEN i1.Price < 100 THEN CEILING((ISNULL(sum(d1.Quantity),0))/6)
    WHEN i1.Price > 200 THEN FLOOR((ISNULL(sum(d1.Quantity),0))/6)
    ELSE ROUND((ISNULL(sum(d1.Quantity),0))/6,0)
    END AS 'Suggested Stock'
, FORMAT(CASE WHEN i1.Price < 100 THEN CEILING((ISNULL(sum(d1.Quantity),0))/6)
                    WHEN i1.Price > 200 THEN FLOOR((ISNULL(sum(d1.Quantity),0))/6)
                    ELSE ROUND((ISNULL(sum(d1.Quantity),0))/6,0)
                    END - x1.onHand - x1.OnOrder + x1.IsCommited,'n0') as 'Action: match Suggested Stock'
, '$' + FORMAT((CASE WHEN i1.Price < 100 THEN CEILING((ISNULL(sum(d1.Quantity),0))/6)
                    WHEN i1.Price > 200 THEN FLOOR((ISNULL(sum(d1.Quantity),0))/6)
                    ELSE ROUND((ISNULL(sum(d1.Quantity),0))/6,0)
                    END - x1.onHand - x1.OnOrder + x1.IsCommited)*i1.Price,'n2') as 'Impact'
-- Impact with Items/Unit Accounted for
, '$' + FORMAT((CASE WHEN i1.Price < 100 THEN CEILING((ISNULL(sum(d1.Quantity),0))/6)
                    WHEN i1.Price > 200 THEN FLOOR((ISNULL(sum(d1.Quantity),0))/6)
                    ELSE ROUND((ISNULL(sum(d1.Quantity),0))/6,0)
                    END - x1.onHand - x1.OnOrder + x1.IsCommited)*(i1.Price/x2.NumInBuy),'n2') as 'Impact w/ Items/Unit'

FROM OITM x2 WITH (NOLOCK)
INNER JOIN OITW x1 WITH (NOLOCK) on x1.[ItemCode] = x2.ItemCode   
INNER JOIN OWHS Y0 WITH (NOLOCK) on x1.whscode = Y0.WhsCode
LEFT JOIN DLN1 d1 WITH (NOLOCK) ON d1.ItemCode = x2.ItemCode 
    AND d1.WhsCode = Y0.WhsCode
    AND d1.[DocDate] >= dateadd(mm,-5,getdate()) 
LEFT JOIN ITM1 i1 WITH (NOLOCK) ON x2.ItemCode = i1.ItemCode AND i1.PriceList = 2
LEFT JOIN OCRD v1 WITH (NOLOCK) ON x2.CardCode = v1.CardCode
LEFT JOIN OITB iB WITH (NOLOCK) ON x2.ItmsGrpCod = iB.ItmsGrpCod

LEFT JOIN (
    SELECT TOP 1 i.ItemCode
    , i.UomEntry
    , o.UomName 
    , i.Price
    , i.PriceList
    FROM ITM9 i
    INNER JOIN OUOM o ON i.UomEntry = o.UomEntry
    WHERE i.PriceList = 2
    ORDER BY i.UomEntry ASC
) i9 ON x2.ItemCode = i9.ItemCode -- AND x2.PUoMEntry = i9.UomEntry
LEFT JOIN (
    SELECT i.ItemCode
    , i.UomEntry
    , o.UomName 
    , i.Price
    FROM ITM9 i
    INNER JOIN OUOM o ON i.UomEntry = o.UomEntry
) i91 ON x2.ItemCode = i91.ItemCode AND x2.PUoMEntry = i91.UomEntry

-- LEFT JOIN ITM9 i9 WITH (NOLOCK) ON x2.ItemCode = i9.ItemCode AND i1.PriceList = i9.PriceList
-- LEFT JOIN OUOM u1 WITH (NOLOCK) ON i9.UomEntry = u1.UomEntry
WHERE x2.ItmsGrpCod IN (
                        -- '101',
                        '102',
                        '103'
                        -- ,'132'
                        )
-- AND x2.ItmsGrpCod <> '107'
AND x2.ItemType <> 'L'
AND d1.DocEntry IS NULL
-- Determine if there is ANY value or inventory etc.
AND (
    X1.OnHand > 0
    OR x1.OnOrder > 0
    OR x1.IsCommited > 0
    )
GROUP BY Y0.WhsName
        , Y0.WhsCode
        , x2.itemcode
        , x2.ItemName
        , x1.OnHand
        , x1.MinStock
        , x1.MaxStock 
        , x1.OnOrder
        , x1.IsCommited
        , x2.SuppCatNum
        , Y0.State
        , i1.Price
        , v1.CardName
        , iB.ItmsGrpCod
        , iB.ItmsGrpNam


        , i9.Price
        , x2.NumInBuy
        , x2.NumInCnt
        , x2.PUomEntry
ORDER BY Y0.WhsCode
        , x2.ItemCode