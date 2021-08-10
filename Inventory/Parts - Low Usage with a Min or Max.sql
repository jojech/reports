/* Rarely Used Parts w/ a Min or Max */
--Requested by Randy
--Created by Jeremy 6/14/21
--Grabs any parts with less usage in the past 3 months than their respective min value

SELECT x0.WhsCode
, x0.itemcode
, x2.ItemName
, x1.onhand
, x1.MinStock
, x1.MaxStock
, sum(x0.month1) [Month1]
, sum(x0.month2) [Month2]
, sum(x0.month3) [Month3]
, sum(x0.month4) [Month4]
, sum(x0.month5) [Month5]
, sum(x0.month6) [Month6] 

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
    
    FROM DLN1 T0 WITH (NOLOCK)
    INNER JOIN ODLN T2 WITH (NOLOCK) on t2.[DocEntry]=t0.[DocEntry]  
    WHERE T2.[DocDate] >= dateadd(mm,-7,getdate()) 
        AND LEFT(T0.[WhsCode],1) = 'T' 
    ) x0 
INNER JOIN OITW x1 WITH (NOLOCK) on x1.[ItemCode]=x0.ItemCode 
    AND x1.whscode = x0.whscode 
INNER JOIN OITM x2 WITH (NOLOCK) on x2.[ItemCode]=x0.ItemCode  
GROUP BY x0.WhsCode
        , x0.itemcode
        , x2.ItemName
        , x1.OnHand
        , x1.MinStock
        , x1.MaxStock 
HAVING (SUM(x0.month1)+SUM(x0.month2)+SUM(x0.month3)) <= x1.MaxStock
ORDER BY x0.WhsCode
        , x0.ItemCode