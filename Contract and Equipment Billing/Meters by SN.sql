/* Meters by S/N# */
--Created to circumnavigate the Meter Readings Button (grayed out for Sales)
--Jeremy Johnson 6/10/21
--Still working on getting the Meter Readings button to display for sales

SELECT T3.[customer] as 'BP'
, T3.[custmrName] as 'Customer Name'
, T3.[itemName]
, T3.[manufSN]
, T2.[DocNum] as 'Invoice No.'
, T1.[U_mcode] as 'Meter Code'
, T1.[U_mr_type] as 'Meter Reading Type'
, T1.[U_mr_value] as 'Current Meter'
, T12.[U_mr_value] as 'Previous Meter'
, T1.[U_mr_value]-T12.[U_mr_value] as 'Meters Billed' 
, T2.taxdate as 'Invoice Date'
, T1.[U_mr_date] as 'Billed Meter Date'
, T12.[U_mr_date] as 'Previous Meter Date'
FROM INV1 T0 WITH (NOLOCK)
INNER JOIN [@MWA_METER_READING]  T1 WITH (NOLOCK) ON T1.DocEntry = T0.U_mtrReadID 
INNER JOIN OINV T2 WITH (NOLOCK) ON T0.[DocEntry] = T2.[DocEntry]
INNER JOIN (SELECT INV1.U_lmtrReadID, M2.U_mr_date, M2.U_mr_value FROM INV1 INNER JOIN [@MWA_METER_READING] M2 ON M2.DocEntry = INV1.U_lmtrReadID) T12 ON T12.U_lmtrReadID = T0.U_lMtrReadID 
INNER JOIN OINS T3 ON T1.[U_insID] = T3.[insID] 
WHERE ((RIGHT(T3.[manufSN],6) = [%1])) 
AND T2.CANCELED <> 'Y'
AND T0.U_mbillType = 'CPC'
ORDER BY T3.[insID], T0.[DocEntry], T2.[DocNum]