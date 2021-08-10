/* Clarke County Meter Report */
-- Created by Jeremy to help Libby get meters for billing

SELECT T0.[CardCode]
, T0.[CardName]
, T1.[insID]
, T1.[itemName]
, T1.[manufSN]
, T2.[U_mr_value] as 'BLK Meter Reading'
, T2.[U_mr_date] as 'BLK Meter Date'
, T3.[U_mr_value] as 'CLR Meter Reading'
, T3.[U_mr_date] as 'CLR Meter Date'
, T2.[U_mr_type] as 'BLK Source'
, T3.[U_mr_type] as 'CLR Source' 
FROM OCRD T0 WITH (NOLOCK)
INNER JOIN OINS T1 WITH (NOLOCK) 
ON T0.[CardCode] = T1.[customer]
LEFT JOIN [dbo].[@MWA_METER_READING] T2 ON T1.insID = T2.U_insID AND T2.DocNum = (SELECT TOP 1 M2.DocNum FROM [dbo].[@MWA_METER_READING] M2 WITH (NOLOCK)
WHERE T1.insID = M2.U_insID 
AND M2.U_mcode = 'BLK'
AND M2.U_mr_date <= '05/31/2021' 
ORDER BY M2.U_mr_date DESC)
LEFT JOIN [dbo].[@MWA_METER_READING] T3 ON T1.insID = T3.U_insID AND T3.DocNum = (SELECT TOP 1 M3.DocNum FROM [dbo].[@MWA_METER_READING] M3 WITH (NOLOCK)
WHERE T1.insID = M3.U_insID 
AND M3.U_mcode = 'CLR'
AND M3.U_mr_date <= '05/31/2021' 
ORDER BY M3.U_mr_date DESC)
WHERE T0.CardCode = 'C005661' 
ORDER BY T1.manufSN, T2.[U_mr_date] DESC