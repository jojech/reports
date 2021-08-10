SELECT T0.[DocNum] as 'Delivery'
--, T0.[DocStatus]
--, T0.[InvntSttus]
--, T0.[DocDate]
--, T2.[ItemCode]
, T5.[ItmsGrpNam]
, T2.[Dscription]
, T2.[SerialNum]
, T2.[ShipDate]
, T2.[LineStatus] as 'Delivery Status'
--, T2.[LineTotal]
, ISNULL(CAST(T1.[DocNum] AS NVARCHAR(12)),'Not Invoiced') as 'Invoice Number'
--, T1.[DocStatus]
, T1.[DocDate]
, T3.[LineStatus] as 'Invoice Status'
--, T3.[LineTotal]
, T3.[OpenSum] 
FROM ODLN T0 
INNER JOIN DLN1 T2 ON T0.[DocEntry] = T2.[DocEntry]
LEFT JOIN INV1 T3 ON T2.[TrgetEntry] = T3.[DocEntry] AND T2.TargetType = 13 AND T2.LineNum = T3.LineNum
LEFT JOIN OINV T1 ON T1.DocEntry = T3.DocEntry 
INNER JOIN OITM T4 ON T2.[ItemCode] = T4.[ItemCode] 
INNER JOIN OITB T5 ON T4.[ItmsGrpCod] = T5.[ItmsGrpCod]
WHERE T0.[DocNum] = '61453'
AND (T3.OpenSum > 0
    OR T3.DocEntry IS NULL)
AND T5.ItmsGrpCod NOT IN ('107','108','109','110','111','133','114')


-- RITL, DocLine = Doc Row
-- What is the RITL table?