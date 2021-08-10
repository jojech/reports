-- Equipment sold by Rep (USING SALES ORDERS TO QUERY FROM) IN A CERTAIN TIME PERIOD
-- Created by Jeremy 6/18/21 for Lin Cashwell
SELECT T2.[SlpName]
, T0.[CardCode]
, T0.[CardName]
, T0.[DocDate]
, CASE T0.[DocStatus] 
    WHEN 'O' THEN 'Open' 
    WHEN 'C' THEN 'Closed' 
    END as 'Status'
, T0.[DocTotal]
, CASE T0.[U_MWAI_OrderType] 
    WHEN '01' THEN 'Equipment Sale'
    WHEN '02' THEN 'Equipment Lease'
    WHEN '03' THEN 'Supply Order'
    WHEN '04' THEN 'Service Call'
    WHEN '19' THEN 'Supply DropShip'
    WHEN '08' THEN 'InterTerritorial'
    WHEN '06' THEN 'Internal Rental'
    WHEN '16' THEN 'Service Loan'
    WHEN '18' THEN 'Equipment Exchange'
    WHEN '15' THEN 'Sales Trial'
    WHEN '22' THEN 'Internal ITT'
    ELSE T0.[U_MWAI_OrderType]
    END AS 'Order Type'
FROM ORDR T0 WITH (NOLOCK) 
INNER JOIN OSLP T2 
ON T0.[SlpCode] = T2.[SlpCode] 
WHERE T2.[SlpName] = '[%1]'
    AND T0.[DocDate] >= '[%2]'
    AND T0.[DocDate] < '[%3]'
    AND T0.[CANCELED] <> 'Y'
    AND T0.[U_MWAI_OrderType] NOT IN ('03','04','19') 
ORDER BY T0.[DocDate] ASC




-- The # and Revenue of different Order Types by Rep
        -- CONCLUSIONS:
        -- Reps are included on a sales order even for supplies (Good?/Bad?)
SELECT T0.U_MWAI_OrderType
, T1.SlpName
, SUM(T0.DocTotal) as 'Total $'
, MAX(T0.DocNum) as 'Order No.'
, COUNT(T0.DocNum) as '#ofDocs' 
FROM ORDR T0 WITH (NOLOCK) 
    INNER JOIN OSLP T1 ON T0.SlpCode = T1.SlpCode
WHERE T0.CANCELED <> 'Y' 
    AND T1.Active = 'Y' 
GROUP BY T0.U_MWAI_OrderType, T1.SlpName 
ORDER BY COUNT(T0.DocNum) 