--Report showing open Rental/Lease Invoices to see machines that do not have current PO's
--Created By Jeremy Johnson for Leigh 5/26/21

SELECT T0.DocEntry
,T0.[DocNum] as 'Invoice #'
,T0.[DocDate]
,T0.[NumAtCard] as 'PO #'
, T2.[insID] as 'Equip. ID'
--, T2.[U_InsID]
, T2.[ManufSN]
--, T1.[U_EquipID]
--, T1.[ItemCode]
, T1.[Dscription]
, T0.[CardCode]+' | '+T0.CardName as 'Customer Code | Name'
,T0.[Address2]
,T0.[PayToCode]
,T0.[Address]
--, T1.[VendorNum]
, T1.[AcctCode]
, T1.[Quantity]
, T1.LineTotal 
, CASE T0.DocStatus WHEN 'O' THEN 'Open' WHEN 'C' THEN 'Closed' ELSE T0.DocStatus END as 'Document Status'
, T0.[Comments]
FROM OINV T0 WITH (NOLOCK)
INNER JOIN INV1 T1 WITH (NOLOCK) ON T0.[DocEntry] = T1.[DocEntry]
LEFT JOIN OINS T2 WITH (NOLOCK) ON T2.[insID] = T1.[U_EquipID]
WHERE T0.[CardCode] = '[%0]'
AND T0.DocDate >= [%1] AND T0.DocDate <= [%2]
AND T0.CANCELED <> 'Y'
AND T0.DocStatus = 'O'
ORDER BY T0.DocNum ASC