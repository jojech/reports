/* Team Usage Report */
-- Created by Jeremy 6/30/21

/* Configuration Notes:
Set up to calculate rounding based on 
-- Round up if cost < 100
-- Round down if cost > 200
-- Round normally otherwise

*/

DECLARE @teamNum INT;
SET @teamNum = (SELECT teamID FROM OHTM WHERE name = '[%1]');

SELECT h0.name
, x0.WhsCode
, Y0.WhsName
, iB.ItmsGrpNam as 'Item Type'
-- , iB.ItmsGrpCod as 'Type #'
, v1.CardName as 'Vendor Name'
, x0.itemcode
, x2.SuppCatNum
, x2.ItemName
, '$'+FORMAT(i1.Price,'n2') as 'Purchase Cost'
, FORMAT(x1.MinStock,'n0') as 'Min'
, FORMAT(x1.MaxStock,'n0') as 'Max'
, FORMAT(x1.onhand,'n0') as 'On Hand'
, '$' + FORMAT(i1.Price*x1.onhand,'n2') as 'Current Stock Value'
, '$' + FORMAT(i1.Price*(x1.onhand + x1.OnOrder - x1.IsCommited),'n2') as 'Adj. Stock Value (incl. Committed + OnOrder)'

, FORMAT(sum(x0.month6),'n0') as 'M6'
, FORMAT(sum(x0.month5),'n0') as 'M5'
, FORMAT(sum(x0.month4),'n0') as 'M4'
, FORMAT(sum(x0.month3),'n0') as 'M3'
, FORMAT(sum(x0.month2),'n0') as 'M2'
, FORMAT(sum(x0.month1),'n0') as 'CURR' 

, FORMAT(ISNULL(sum(x0.total6m),0),'n0') as '6M Total Usage'

, FORMAT(x1.OnOrder,'n0') as 'On Order (Incoming)'
, FORMAT(x1.IsCommited,'n0') as 'Committed (Outgoing)'
-- , FORMAT(x1.onhand - x1.IsCommited + x1.OnOrder,'n0') as 'Order Qty'
, FORMAT(ROUND((ISNULL(sum(x0.total6m),0))/6,2),'n2') as 'AMU'
, CASE 
    WHEN i1.Price < 100 THEN CEILING((ISNULL(sum(x0.total6m),0))/6)
    WHEN i1.Price > 200 THEN FLOOR((ISNULL(sum(x0.total6m),0))/6)
    ELSE ROUND((ISNULL(sum(x0.total6m),0))/6,0)
    END AS 'Suggested Stock'
, FORMAT(CASE WHEN i1.Price < 100 THEN CEILING((ISNULL(sum(x0.total6m),0))/6)
                    WHEN i1.Price > 200 THEN FLOOR((ISNULL(sum(x0.total6m),0))/6)
                    ELSE ROUND((ISNULL(sum(x0.total6m),0))/6,0)
                    END - x1.onHand - x1.OnOrder + x1.IsCommited,'n0') as 'Action: match Suggested Stock'
, '$' + FORMAT((CASE WHEN i1.Price < 100 THEN CEILING((ISNULL(sum(x0.total6m),0))/6)
                    WHEN i1.Price > 200 THEN FLOOR((ISNULL(sum(x0.total6m),0))/6)
                    ELSE ROUND((ISNULL(sum(x0.total6m),0))/6,0)
                    END - x1.onHand - x1.OnOrder + x1.IsCommited)*i1.Price,'n2') as 'Impact'

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
INNER JOIN OITW x1 WITH (NOLOCK) on x1.[ItemCode]=x0.ItemCode 
    AND x1.whscode = x0.whscode 
INNER JOIN OITM x2 WITH (NOLOCK) on x2.[ItemCode] = x0.[ItemCode]  
INNER JOIN OWHS Y0 WITH (NOLOCK) on x0.whscode = Y0.WhsCode 
LEFT JOIN ITM1 i1 WITH (NOLOCK) ON x2.ItemCode = i1.ItemCode AND i1.PriceList = 2
LEFT JOIN OCRD v1 WITH (NOLOCK) ON x2.CardCode = v1.CardCode
LEFT JOIN OITB iB WITH (NOLOCK) ON x2.ItmsGrpCod = iB.ItmsGrpCod


INNER JOIN [dbo].[@MWA_SRVC_TECH_STNGS] st WITH (NOLOCK) ON Y0.WhsCode = st.U_MWA_carStock 
INNER JOIN HTM1 h1 WITH (NOLOCK) ON st.U_EmployeeId = h1.empID
INNER JOIN OHTM h0 WITH (NOLOCK) ON h1.teamID = h0.teamID

WHERE x2.ItmsGrpCod IN ('102','103')
AND x2.ItemType <> 'L'
AND h0.name = @teamNum
GROUP BY h0.name
        , Y0.WhsName
        , x0.WhsCode
        , x0.itemcode
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

UNION ALL

SELECT h0.name
, 'TEAM'
, 'TEAM SUMMARY'
, NULL
-- , iB.ItmsGrpCod as 'Type #'
, NULL
, NULL
, NULL
, NULL
, NULL
, FORMAT(sum(x1.MinStock),'n0') as 'Min'
, FORMAT(sum(x1.MaxStock),'n0') as 'Max'
, FORMAT(sum(x1.onhand),'n0') as 'On Hand'
, '$' + FORMAT(sum(i1.Price*x1.onhand),'n2') as 'Current Stock Value'
, '$' + FORMAT(sum(i1.Price*(x1.onhand + x1.OnOrder - x1.IsCommited)),'n2') as 'Adj. Stock Value (incl. Committed + OnOrder)'

, FORMAT(sum(x0.month6),'n0') as 'M6'
, FORMAT(sum(x0.month5),'n0') as 'M5'
, FORMAT(sum(x0.month4),'n0') as 'M4'
, FORMAT(sum(x0.month3),'n0') as 'M3'
, FORMAT(sum(x0.month2),'n0') as 'M2'
, FORMAT(sum(x0.month1),'n0') as 'CURR' 

, FORMAT(ISNULL(sum(x0.total6m),0),'n0') as '6M Total Usage'

, FORMAT(sum(x1.OnOrder),'n0') as 'On Order (Incoming)'
, FORMAT(sum(x1.IsCommited),'n0') as 'Committed (Outgoing)'
-- , FORMAT(x1.onhand - x1.IsCommited + x1.OnOrder,'n0') as 'Order Qty'
, FORMAT(ROUND((ISNULL(sum(x0.total6m),0))/6,2),'n2') as 'AMU'
, NULL
, NULL
, '$' + FORMAT((sum(i1.Price*(x0.total6m/6))),0) as 'Impact'

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
INNER JOIN OITW x1 WITH (NOLOCK) on x1.[ItemCode]=x0.ItemCode 
    AND x1.whscode = x0.whscode 
INNER JOIN OITM x2 WITH (NOLOCK) on x2.[ItemCode] = x0.[ItemCode]  
INNER JOIN OWHS Y0 WITH (NOLOCK) on x0.whscode = Y0.WhsCode 
LEFT JOIN ITM1 i1 WITH (NOLOCK) ON x2.ItemCode = i1.ItemCode AND i1.PriceList = 2
LEFT JOIN OCRD v1 WITH (NOLOCK) ON x2.CardCode = v1.CardCode
LEFT JOIN OITB iB WITH (NOLOCK) ON x2.ItmsGrpCod = iB.ItmsGrpCod


INNER JOIN [dbo].[@MWA_SRVC_TECH_STNGS] st WITH (NOLOCK) ON Y0.WhsCode = st.U_MWA_carStock 
INNER JOIN HTM1 h1 WITH (NOLOCK) ON st.U_EmployeeId = h1.empID
INNER JOIN OHTM h0 WITH (NOLOCK) ON h1.teamID = h0.teamID

WHERE x2.ItmsGrpCod IN ('102','103')
AND x2.ItemType <> 'L'
AND h0.name = @teamNum
GROUP BY h0.name