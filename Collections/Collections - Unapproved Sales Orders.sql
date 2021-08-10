--Sales Orders on Hold for Credit Alert
--6/17/21 - Updated & optimized-Refitted for Collections after approvals made for Equipment Sales - Jeremy

SELECT   LEFT(T1."U_MWAI_BPBillBranch",2) as 'Branch'
       , T0."DocEntry"
       , T0."DocNum"
       , T0."DocDate"
       , T0."CardCode"
       , T0."CardName"
       , T0."NumAtCard"
       , T0."DocTotalSy"
FROM ORDR AS T0 WITH (NOLOCK)
-- Find the customer, but if they are exempt, then we can ignore ALL checks, so rule out those orders quickly
INNER JOIN OCRD AS T1 WITH (NOLOCK) ON T1."CardCode" = T0."CardCode" AND (T1."U_MWAI_CreditCode" <> 'Exempt' or T1."frozenFor" = 'Y')
INNER JOIN (SELECT GETDATE() AS "CurrDate") AS cd ON 1 = 1
-- Find the oldest due date for any open invoice for the customer, ONLY if they are not already on hold, and have "normal" credit
LEFT JOIN (SELECT "CardCode", MIN("DocDueDate") AS "OldestDocDueDate"
                     FROM OINV WITH (NOLOCK)
                     WHERE "DocStatus" <> 'C'
                        AND "CANCELED" <> 'Y'
                     GROUP BY "CardCode"
                  ) AS T2 ON T1."frozenFor" <> 'Y'
                              AND T1."U_MWAI_CreditCode" = 'Normal'
                              AND T2."CardCode" = T1."CardCode"
-- Note:  DocStatus and CANCELED are a key, so we can find all OPEN orders using that (so keep them first to help the optimizer)
WHERE T0."DocStatus" <> 'C'
  AND T0."CANCELED" <> 'Y'
  AND T0."Confirmed" = 'N'
  AND T0."U_MWAI_OrderType" IN ('03','04','19')
  --AND LEFT(T1."U_MWAI_BPBillBranch",2) = 'NC'
  --AND LEFT(T1."U_MWAI_BPBillBranch",2) = 'GA'
  --AND LEFT(T1."U_MWAI_BPBillBranch",2) = 'FL'
  AND (   T1."frozenFor" = 'Y'
       OR T1."U_MWAI_CreditCode" <> 'Normal'
          OR DATEDIFF(DAY, ISNULL(T2."OldestDocDueDate", cd."CurrDate"), cd."CurrDate") >= 35)