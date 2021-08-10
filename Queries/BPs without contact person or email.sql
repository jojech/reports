/* BP ERROR: All Emails are empty for every contact AND no BP Email */
-- Created by Jeremy 6/22/21
-- Requested to aid Collections find customers with no contact information
SELECT T0.[CardCode]
, T0.[CardName]
, T0.[E_Mail] as 'BP Email'
, T0.Phone1
, COUNT(T1.[Name]) as 'No. of Contacts'
, COUNT(T1.[Tel1]) as 'Contacts w/ Phone #s'
FROM OCRD T0
LEFT JOIN (SELECT CardCode, Name, E_MailL, U_BOY_85_ECAT, Tel1 FROM OCPR) T1 ON T0.[CardCode] = T1.[CardCode] 
WHERE T0.[E_Mail] IS NULL
GROUP BY T0.[CardCode]
, T0.[CardName]
, T0.[E_Mail]
, T0.Phone1
HAVING COUNT(T1.[E_MailL]) = 0
ORDER BY LEFT(T0.CardCode,1), T0.Phone1, COUNT(T1.Tel1), T0.CardName ASC

/* BP ERROR - All BPs without an email or any contacts */
-- Created by Jeremy 6/22/21
-- Requested to aid Collections gather contact information
SELECT T0.[CardCode]
, T0.[CardName]
, T0.[E_Mail] as 'BP Email'
, T0.[CntctPrsn]
, T0.[Phone1]
, T0.[Fax]
FROM OCRD T0  with (NOLOCK)
LEFT JOIN OCPR T1 with (NOLOCK) ON T0.[CardCode] = T1.[CardCode]
WHERE T0.[E_Mail] IS NULL
AND T1.Name IS NULL
ORDER BY LEFT(T0.CardCode,1), T0.Phone1, T0.CardName ASC