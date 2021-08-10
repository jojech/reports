-- Gold Report - BP Machine Billing and Contract Information
-- Requested by Leigh for the Sales Reps (specifically for Emory)
-- Created Jeremy
-- Last Updated 6/23/21
SELECT T0.[CardName]
    , T1.[insID]
    , T1.[itemName]
    , T1.[manufSN]
    , T1.[U_MWAI_InstallDate]
    , T3.[ContractID]
    , T1.[U_MrStpCode]
    , T2.[StartDate]
    , T2.[EndDate]
    , T2.[TermDate]
    , T2.[U_NumAtCard]
    , T4.[U_b_icode]
    , T4.[U_BFrequency]
    , T4.[U_p_base]
    , T4.[U_BNxtBllDt]
    , T4.[U_mcode]
    , T4.[U_Frequency]
    , T4.[U_p_click]
    , T4.[U_allow]
    , T4.[U_NxtBllDt] 
    , MAX(T5.[invNum]) as 'Last Billed Invoice'
    , AVG((T5.[cmValue]-T5.[lmValue])/DATEDIFF(dd,lmDate,cmDate)) as 'Avg. Clicks/Day'
    , FORMAT(AVG((T5.[cmValue]-T5.[lmValue])/DATEDIFF(dd,lmDate,cmDate))*365.25,'n0') as 'Est. Annual Usage'
FROM OCRD T0  
    INNER JOIN OINS T1 ON T0.[CardCode] = T1.[customer] 
    LEFT JOIN CTR1 T2 ON T1.[insID] = T2.[InsID] 
    LEFT JOIN OCTR T3 ON T2.[ContractID] = T3.[ContractID]
    LEFT JOIN [dbo].[@MWA_SRVC_CTR_METER]  T4 ON T3.ContractID = T4.U_ContractID AND T1.insID = T4.U_insID
    LEFT JOIN (SELECT oi.DocNum [invNum]
                , oi.DocDate [invDate]
                , m1.U_insID [insID]
                , m1.U_mcode [cmCode]
                , m1.U_mr_date [cmDate]
                , m1.U_mr_type [cmType]
                , m1.U_mr_value [cmValue]
                , m1.U_source [cmSource]
                , s1.U_mr_date [lmDate]
                , s1.U_mr_value [lmValue]
                , m1.U_mr_value-s1.U_mr_value [usage]
                /*, DATEDIFF(dd,s1.U_mr_date,m1.U_mr_date) [daysBW]
                , (m1.U_mr_value-s1.U_mr_value)
                / DATEDIFF(dd,s1.U_mr_date,m1.U_mr_date) [dailyUsage]*/
                FROM INV1 i1 
                INNER JOIN [dbo].[@MWA_METER_READING] m1 ON i1.U_mtrReadID = m1.DocEntry
                INNER JOIN (SELECT i2.U_lmtrReadID
                                , m2.U_mr_date
                                , m2.U_mr_value 
                                FROM INV1 i2 
                                INNER JOIN [@mwa_meter_reading] m2 on m2.DocEntry = i2.U_lmtrReadID
                                ) s1 ON i1.U_lmtrReadID = s1.U_lmtrReadID
                INNER JOIN OINV oi ON i1.DocEntry = oi.DocEntry
                WHERE oi.Canceled <> 'Y'
                AND i1.U_mbillType = 'CPC'
                ) T5 ON T1.insID = T5.insID AND T4.U_mcode = T5.cmCode
    LEFT JOIN (SELECT sc.[callID]
                , sc.[createDate]
                , sc.[closeDate]
                , sc.[insID] 
                FROM OSCL sc WITH (NOLOCK)
                GROUP BY sc.insID
                ) T6 ON T1.insID = T6.insID
WHERE T1.[status] <> 'T'
    AND (T3.[Status] <> 'T' OR  T3.[ContractID] IS NULL)
    AND ISNULL(T2.[TermDate],'12/01/2049') > GETDATE()
    AND ISNULL(T2.[EndDate],'12/01/2049') > GETDATE() 
    AND T0.[CardName] = '[%1]'
GROUP BY T0.[CardName]
    , T1.[insID]
    , T1.[itemName]
    , T1.[manufSN]
    , T1.[U_MWAI_InstallDate]
    , T3.[ContractID]
    , T1.[U_MrStpCode]
    , T2.[StartDate]
    , T2.[EndDate]
    , T2.[TermDate]
    , T2.[U_NumAtCard]
    , T4.[U_b_icode]
    , T4.[U_BFrequency]
    , T4.[U_p_base]
    , T4.[U_BNxtBllDt]
    , T4.[U_mcode]
    , T4.[U_Frequency]
    , T4.[U_p_click]
    , T4.[U_allow]
    , T4.[U_NxtBllDt]
    , T1.[itemCode]
ORDER BY T0.[CardName], T1.[insID], T1.[itemCode], T4.[U_mcode]