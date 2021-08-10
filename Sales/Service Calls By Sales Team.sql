--ALL Service Calls by Sales Team
--Designed for Gary Hinchcliffe
--Jeremy 6/10/21

SELECT T0.[SlpName]
    , T5.[callID]
    , T4.[CardCode]
    , T4.[CardName]
    , T7.[Name] as 'Status'
    , T9.Name as 'Origin'
    , T10.Name as 'Problem Type'
    , T5.[createDate]
    , T8.lastName+', '+T8.firstName as 'Technician'
    , T6.[itemName]
    , T6.[manufSN]
    , T5.subject
    , T5.descrption 
FROM OSLP T0 
    INNER JOIN OHEM T1 ON T0.[SlpCode] = T1.[salesPrson] 
    INNER JOIN HTM1  T2 ON T1.[empID] = T2.[empID] 
    INNER JOIN OHTM T3 ON T2.[teamID] = T3.[teamID] 
    INNER JOIN OCRD T4 WITH (NOLOCK) ON T0.[SlpCode] = T4.[SlpCode] 
    INNER JOIN OSCL T5 WITH (NOLOCK) ON T4.[CardCode] = T5.[customer] 
    INNER JOIN OINS T6 WITH (NOLOCK) ON T5.[insID] = T6.[insID] 
    INNER JOIN OSCS T7 ON T5.[status] = T7.[statusID]
    INNER JOIN OHEM T8 ON T5.[technician] = T8.[empID] 
    LEFT JOIN OSCO T9 ON T9.originID = T5.origin
    LEFT JOIN OSCP T10 ON T10.prblmTypID = T5.problemTyp
WHERE T7.[statusID] <> -1
    AND 
    T7.[statusID] <> 9
    AND
    T3.[name] = '[%0]' 
ORDER BY T0.[SlpName]
    , T5.[createDate]