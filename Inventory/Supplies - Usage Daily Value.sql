-- Daily Value of Supplies Used
-- Created By Jeremy

SELECT T0.[DocEntry]
, T2.[DocNum] as 'Delivery'
, T0.[ItemCode]
, T0.[Dscription]
, T0.[Quantity]
-- , T0.[Price] as 'Price (From Delivery)'
, T3.[Price]*T0.[Quantity] as 'Total Purchase Cost'
, T4.[Price]*T0.[Quantity] as 'Total Retail Price'
, T0.[DiscPrcnt], T0.[LineTotal] as 'Actual Billed'
, T0.[U_ARGNS_TAXTAXT]
, T2.[DocDate]
, T2.[CardCode]
, T2.[CardName] 
FROM DLN1 T0 WITH (NOLOCK) 
INNER JOIN OITM T1 WITH (NOLOCK) ON T0.[ItemCode] = T1.[ItemCode] 
INNER JOIN ODLN T2 WITH (NOLOCK) ON T0.[DocEntry] = T2.[DocEntry] 
LEFT JOIN ITM1 T3 WITH (NOLOCK) ON T1.[ItemCode] = T3.[ItemCode] AND T3.[PriceList] = 2 
LEFT JOIN ITM1 T4 WITH (NOLOCK) ON T1.[ItemCode] = T4.[ItemCode] AND T4.[PriceList] = 1 
WHERE T1.[ItmsGrpCod] IN (102)
AND
 T2.[CANCELED] <> 'Y'
AND
 T2.[DocDate] = [%1]