SELECT DISTINCT
    T3.[Name]+' - '+T1.[SlpName]+' - ('+
    CONVERT(nvarchar(10),( SELECT COUNT(DISTINCT XX.[DocNum]) FROM OINV XX INNER JOIN INV1 XI ON XX.DocEntry = XI.DocEntry WHERE XX.[SlpCode] = T0.[SlpCode] AND XX.DocDate >= [%3]
    AND XX.DocDate <= [%4] AND XX.[CANCELED] = 'N' AND LEFT(XI.ItemCode,3) = 'RTC' ),0)+')' as 'Representative'
    , T3.[Name]
    , T1.SlpName
    , T0.[CardCode]
    , T0.[CardName]
    , T0.DocNum
    , T0.DocDate 
    , T0.DocType
    , T0.DocTotal 
    , ( T0.DocTotal - T0.VatSum) As "Document Total Without VAT"
    , T1.Commission
    , ( ( T0.DocTotal - T0.VatSum)*( T1.Commission/100)) As "Sum_Commissions"
FROM OINV T0 WITH (NOLOCK) 
    LEFT JOIN OSLP T1 WITH (NOLOCK) ON T0.SlpCode = T1.SlpCode 
    LEFT JOIN OHEM T2 WITH (NOLOCK) ON T0.SlpCode = T2.salesPrson
    LEFT JOIN OUBR T3 WITH (NOLOCK) ON T2.branch = T3.Code
    LEFT JOIN UFD1 O1 WITH (NOLOCK) ON ( O1.TableID = 'OINV' AND O1.FieldID = 26 AND O1.FldValue = T0.[U_MWAI_OrderType] )
    INNER JOIN INV1 I1 WITH (NOLOCK) ON ( T0.DocEntry = I1.DocEntry )
WHERE T0.DocDate >= [%3]
    AND T0.DocDate <= [%4]
    AND T0.Canceled = 'N'
    AND LEFT(I1.ItemCode,3) = 'RTC'
    AND 
    (
        T3.[Name] = CASE WHEN [%0] = 'Y' THEN 'FL' ELSE 'NOFL' END 
        OR T3.[Name] = CASE WHEN [%1] = 'Y' THEN 'GA' ELSE 'NOGA' END
        OR T3.[Name] = CASE WHEN [%2] = 'Y' THEN 'NC' ELSE 'NONC' END
    )
    
ORDER BY 1,4,6