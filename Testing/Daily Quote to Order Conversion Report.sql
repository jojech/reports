/* Daily Sales Quote to Sales Order Conversion Report -- Created By Jeremy Johnson 6/1/21 */
-- Passed preliminary tests for 5/27, 5/28, and 5/31
-- 6/7/21 Query currently not pulling any data...

SELECT T0.[CardCode]
, T0.[CardName]
, T0.[DocNum] as 'Sales Order No.'
, T1.[DocNum] as 'Sales Quote No.'
, T0.[DocDate] as 'SO Post Date'
, T1.[DocDate] as 'SQ Post Date'
, DATEDIFF(day,T1.DocDate,T0.DocDate) as 'Days to Conversion'
, CASE T0.[DocStatus] WHEN 'O' THEN 'Open' WHEN 'C' THEN 'Closed' ELSE T0.DocStatus END as 'Doc Status'
, T0.[DocTotal]
, T2.[SlpName]
, T0.U_MWAI_OrderType 
FROM ORDR T0 
LEFT JOIN OQUT T1 ON T1.DocNum = LEFT(RIGHT(T0.Comments,5),4) AND T0.CardCode = T1.CardCode 
LEFT JOIN OSLP T2 ON T0.[SlpCode] = T2.[SlpCode] 
WHERE T0.[DocDate] = [%1]
AND
T0.[CANCELED] <> 'Y'