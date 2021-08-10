/*======================= 
Branch Usage of Parts & Supplies
========================*/
-- Created by Jeremy 6/28/21
SELECT Y0.State
, iB.ItmsGrpNam as 'Item Type'
-- , iB.ItmsGrpCod as 'Type #'
, v1.CardName as 'Vendor Name'
, x2.itemcode
, x2.SuppCatNum
, x2.ItemName
, '$'+FORMAT(i1.Price,'n2') as 'Purchase Cost'
, FORMAT(sum(x1.MinStock),'n0') as 'Total Mins'
, FORMAT(sum(x1.MaxStock),'n0') as 'Total Maxes'
, FORMAT(sum(x1.onhand),'n0') as 'Total On Hand'
, '$' + FORMAT(i1.Price*sum(x1.onhand),'n2') as 'Current Stock Value'
, '$' + FORMAT(i1.Price*(sum(x1.onhand) + sum(x1.OnOrder) - sum(x1.IsCommited)),'n2') 
        as 'Adjusted Stock Value (incl. Committed + OnOrder)'
, FORMAT(sum(x0.month6),'n0') as 'M6'
, FORMAT(sum(x0.month5),'n0') as 'M5'
, FORMAT(sum(x0.month4),'n0') as 'M4'
, FORMAT(sum(x0.month3),'n0') as 'M3'
, FORMAT(sum(x0.month2),'n0') as 'M2'
, FORMAT(sum(x0.month1),'n0') as 'CURR' 
, FORMAT(ISNULL(sum(x0.total6m),0),'n0') as '6M Total Usage'
, FORMAT(sum(x1.OnOrder),'n0') as 'On Order (Incoming)'
, FORMAT(sum(x1.IsCommited),'n0') as 'Committed (Outgoing)'
, FORMAT(ROUND((ISNULL(sum(x0.total6m),0))/6,2),'n2') as 'TOTAL AMU'
FROM ( 
    SELECT  DatePart(YYYY,T0.[DocDate])[Year]
    ,  DatePart(MM,T0.[DocDate])[Month]
    ,  T0.[WhsCode]
    ,  T0.[ItemCode]
    ,  CASE WHEN datediff(MM,T0.[DocDate], getdate()) = 0 
            THEN T0.[Quantity]  END as [Month1]
    ,  CASE WHEN datediff(MM,T0.[DocDate], getdate()) = 1 
            THEN T0.[Quantity]  END [Month2]
    ,  CASE WHEN datediff(MM,T0.[DocDate], getdate()) = 2 
            THEN T0.[Quantity]  END [Month3]
    ,  CASE WHEN datediff(MM,T0.[DocDate], getdate()) = 3 
            THEN T0.[Quantity]  END [Month4]
    ,  CASE WHEN datediff(MM,T0.[DocDate], getdate()) = 4 
            THEN T0.[Quantity]  END [Month5]
    ,  CASE WHEN datediff(MM,T0.[DocDate], getdate()) = 5 
            THEN T0.[Quantity]  END [Month6]
    ,  T0.[Quantity] [total6m]
    FROM DLN1 T0 WITH (NOLOCK)
    INNER JOIN ODLN T2 WITH (NOLOCK) on t2.[DocEntry]=t0.[DocEntry]  
    WHERE T2.[DocDate] >= dateadd(mm,-5,getdate()) 
    ) x0 
INNER JOIN OITW x1 WITH (NOLOCK) on x0.ItemCode = x1.[ItemCode]
    AND  x0.whscode = x1.whscode
INNER JOIN OITM x2 WITH (NOLOCK) on x0.ItemCode  = x2.[ItemCode]
INNER JOIN OWHS Y0 WITH (NOLOCK) on x0.whscode = Y0.WhsCode 
LEFT JOIN ITM1 i1 WITH (NOLOCK) ON x2.ItemCode = i1.ItemCode AND i1.PriceList = 2
LEFT JOIN OCRD v1 WITH (NOLOCK) ON x2.CardCode = v1.CardCode
LEFT JOIN OITB iB WITH (NOLOCK) ON x2.ItmsGrpCod = iB.ItmsGrpCod
WHERE x2.ItmsGrpCod IN ('102','103')
-- AND x2.ItmsGrpCod <> '107'
AND x2.ItemType <> 'L'
GROUP BY x2.itemcode
        , x2.ItemName
        , x2.SuppCatNum
        , Y0.State
        , i1.Price
        , v1.CardName
        , iB.ItmsGrpCod
        , iB.ItmsGrpNam
ORDER BY x2.ItemCode