SELECT T0.[SlpName]
, T1.[CardCode]
, T1.[CardName]
, T2.[insID]
, T2.[manufSN]
, T3.[ContractID] 
FROM OSLP T0  
INNER JOIN OCRD T1 ON T0.[SlpCode] = T1.[SlpCode] 
INNER JOIN OINS T2 ON T1.[CardCode] = T2.[customer] 
INNER JOIN CTR1 T5 ON T2.insID = T5.InsID
INNER JOIN OCTR T3 ON T5.ContractID = T3.ContractID
INNER JOIN [@MWA_SRVC_CTR_METER] T4 ON T3.ContractID = T4.U_ContractID AND T2.insID = T4.U_insID
INNER JOIN OITM T7 ON T4.U_b_icode = T7.ItemCode
INNER JOIN OITB T6 ON T7.ItmsGrpCod = T6.ItmsGrpCod
WHERE T6.ItmsGrpCod NOT IN ('108','109','110','111','133')
AND T0.[SlpName] = '[%1]'
-- AND T4.U_p_base > 0
AND T3.Status <> 'T'
AND T5.EndDate > GETDATE()
AND ISNULL(T5.TermDate,DATEADD(mm,1,GETDATE())) > GETDATE()
GROUP BY T0.[SlpName]
, T1.[CardCode]
, T1.[CardName]
, T2.[insID]
, T2.[manufSN]
, T3.[ContractID] 