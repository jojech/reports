/* Tech Historical Usage - 12M */
--Requested by Randy
--Created by Jeremy 6/18/21
--Shows Tech Usage over Past 12 with the data split into teams and showing the Tech Name

SELECT Y0.WhsName
, x0.WhsCode
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
, sum(x0.month7) [Month7]
, sum(x0.month8) [Month8]
, sum(x0.month9) [Month9]
, sum(x0.month10) [Month10]
, sum(x0.month11) [Month11]
, sum(x0.month12) [Month12] 

, FORMAT(ISNULL(sum(x0.month1),0) 
+ ISNULL(sum(x0.month2),0) 
+ ISNULL(sum(x0.month3),0) 
+ ISNULL(sum(x0.month4),0) 
+ ISNULL(sum(x0.month5),0) 
+ ISNULL(sum(x0.month6),0) 
+ ISNULL(sum(x0.month7),0) 
+ ISNULL(sum(x0.month8),0) 
+ ISNULL(sum(x0.month9),0) 
+ ISNULL(sum(x0.month10),0)
+ ISNULL(sum(x0.month11),0)
+ ISNULL(sum(x0.month12),0),'n0') as '12M Total Usage' 

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
    ,  CASE WHEN datediff(MM,T0.[DocDate], getdate()) = 6 
            THEN T0.[Quantity]  END as [Month7]
    ,  CASE WHEN datediff(MM,T0.[DocDate], getdate()) = 7 
            THEN T0.[Quantity]  END [Month8]
    ,  CASE WHEN datediff(MM,T0.[DocDate], getdate()) = 8 
            THEN T0.[Quantity]  END [Month9]
    ,  CASE WHEN datediff(MM,T0.[DocDate], getdate()) = 9 
            THEN T0.[Quantity]  END [Month10] 
    ,  CASE WHEN datediff(MM,T0.[DocDate], getdate()) = 10 
            THEN T0.[Quantity]  END [Month11]
    ,  CASE WHEN datediff(MM,T0.[DocDate], getdate()) = 11 
            THEN T0.[Quantity]  END [Month12]
    
    FROM DLN1 T0 WITH (NOLOCK)
    INNER JOIN ODLN T2 WITH (NOLOCK) on t2.[DocEntry]=t0.[DocEntry]  
    WHERE T2.[DocDate] >= dateadd(mm,-11,getdate()) 
        AND LEFT(T0.[WhsCode],1) = 'T' 
    ) x0 
INNER JOIN OITW x1 WITH (NOLOCK) on x1.[ItemCode]=x0.ItemCode 
    AND x1.whscode = x0.whscode 
INNER JOIN OITM x2 WITH (NOLOCK) on x2.[ItemCode]=x0.ItemCode  
INNER JOIN OWHS Y0 WITH (NOLOCK) on x0.whscode = Y0.WhsCode 
INNER JOIN [dbo].[@MWA_SRVC_TECH_STNGS]  Y1 WITH (NOLOCK) ON Y0.WhsCode = Y1.U_MWA_carStock
INNER JOIN OHEM Y2 WITH (NOLOCK) ON Y1.[U_EmployeeId] = Y2.[empID] 

-- WATCH OUT FOR DUPLICATION OF ROWS DUE TO MULTIPLE TEAMS!!!
LEFT JOIN HTM1 Y3 WITH (NOLOCK) ON Y2.[empID] = Y3.[empID] 
LEFT JOIN OHTM Y4 WITH (NOLOCK) ON Y3.[teamID] = Y4.[teamID]
WHERE Y4.name = '[%1]'
AND x2.ItmsGrpCod <> '107'
AND x2.ItemType <> 'L'
GROUP BY Y0.WhsName
        , x0.WhsCode
        , x0.itemcode
        , x2.ItemName
        , x1.OnHand
        , x1.MinStock
        , x1.MaxStock 
ORDER BY x0.WhsCode
        , x0.ItemCode