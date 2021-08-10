/* Meters Report for CEC */
-- Designed to fill need of Sales reps to see all meters
-- Requested by Melody
-- Created Jeremy 6/16/21

SELECT CEC.custmrName       as 'Customer Name'
, CEC.itemName
, CEC.manufSN
, MR.U_mr_date              as 'Meter Reading Date'
, MR.U_mcode                as 'Meter Code'
, MR.U_mr_value             as 'Meter Reading'
, MR.U_mr_type              as 'Reading Type'
, MR.U_billed               as 'Billed'
, T0.DocNum                 as 'Invoice No.'
, T2.U_mr_value             as 'Previous Meter'
, T2.U_mr_date              as 'Previously Billed Date'
, MR.U_mr_value-T2.U_mr_value as 'Copies Billed'
FROM OINS CEC WITH (NOLOCK)
    INNER JOIN [@MWA_METER_READING] MR WITH (NOLOCK) ON MR.U_insID = CEC.insID
    LEFT JOIN INV1 T1 WITH (NOLOCK) ON MR.DocEntry = T1.U_mtrReadID
    LEFT JOIN OINV T0 WITH (NOLOCK) ON T1.DocEntry = T0.DocEntry
    LEFT JOIN (SELECT  INV1.U_lmtrReadID
                        , M2.U_mr_date
                        , M2.U_mr_value 
                        FROM INV1 
                        INNER JOIN [@MWA_METER_READING] M2 
                        ON M2.DocEntry = INV1.U_lmtrReadID) T2 ON T2.U_lmtrReadID = T1.U_lmtrReadID
WHERE CEC.manufSN = '[%1]'
ORDER BY MR.DocEntry DESC


/*
-- Meters Report for CEC
-- Plugged into the CEC screen as a multi-button under Meter Billing 
-- Designed to fill need of Sales reps to see all meters
-- Requested by Melody
-- Created Jeremy 6/16/21
*/

SELECT CEC.custmrName           as 'Customer Name'
, CEC.itemName
, CEC.manufSN
, MR.U_mr_date                  as 'Meter Reading Date'
, MR.U_mcode                    as 'Meter Code'
, MR.U_mr_value                 as 'Meter Reading'
, MR.U_mr_type                  as 'Reading Type'
, MR.U_billed                   as 'Billed'
, T0.DocNum                     as 'Invoice No.'
, T2.U_mr_value                 as 'Previous Meter'
, T2.U_mr_date                  as 'Previously Billed Date'
, MR.U_mr_value-T2.U_mr_value   as 'Copies Billed'
FROM OINS CEC WITH (NOLOCK)
    INNER JOIN [@MWA_METER_READING] MR WITH (NOLOCK) ON MR.U_insID = CEC.insID
    LEFT JOIN INV1 T1 WITH (NOLOCK) ON MR.DocEntry = T1.U_mtrReadID
                                    AND T1.U_mbillType = 'CPC'
    LEFT JOIN OINV T0 WITH (NOLOCK) ON T1.DocEntry = T0.DocEntry
                                    AND T0.CANCELED <> 'Y'
    LEFT JOIN (SELECT  INV1.U_lmtrReadID
                        , M2.U_mr_date
                        , M2.U_mr_value 
                        FROM INV1 
                        INNER JOIN [@MWA_METER_READING] M2 
                        ON M2.DocEntry = INV1.U_lmtrReadID) T2 ON T2.U_lmtrReadID = T1.U_lmtrReadID
WHERE MR.U_insID IN (SELECT insID FROM OINS WHERE OINS.manufSN=$[$43.0.0])
ORDER BY MR.DocEntry DESC