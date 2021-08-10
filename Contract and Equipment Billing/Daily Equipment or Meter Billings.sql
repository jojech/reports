/* Daily Equipment or Meter Billings
-- Created by Jeremy Johnson
-- Last Checked 6/1/21 */

SELECT T0.[DocNum]
, T0.[CardCode]
, T0.[CardName]
, T2.[manufSN]
, T1.[Dscription]
, T1.[LineTotal]
, ISNULL(T1.[U_ARGNS_TAXTAXT],0) as 'Tax'
, T1.[LineTotal]+ISNULL(T1.[U_ARGNS_TAXTAXT],0) as 'Total'
, T1.[DocEntry] 
FROM OINV T0 WITH (NOLOCK) 
INNER JOIN INV1 T1 WITH (NOLOCK) ON T0.[DocEntry] = T1.[DocEntry] 
LEFT JOIN OINS T2 WITH (NOLOCK) ON T1.[U_EquipID] = T2.[insID] 
WHERE T0.[CANCELED] <> 'Y'
AND T0.[DocDate] = [%1]
AND T1.[LineTotal] <> 0.00 ORDER BY T0.[DocNum] ASC