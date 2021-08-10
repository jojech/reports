/**Fixed Asset Adjusting Journal entry - List of AR invoices created with order type equal to Internal Rental or Rental Supplement**/
/**Created 2/19/2020 DLF**/
/**Updated to include only last 30 days.  3/7/2021 DLF**/
-- Updated to include last 120 days per Lana 6/10/21 Jeremy Johnson
-- Updated to include Serial Number and other specifications per Lana 6/30/21 Jeremy

SELECT DocEntry
    , DocNum
    , createdate
    , DocDate
    , CardCode
    , CardName
    , NumAtCard
from OINV with (NOLOCK)
where CANCELED = 'N'
    and (U_MWAI_OrderType = '06' or U_MWAI_OrderType = '13')
    and CreateDate >= DATEADD(day, -120, getdate())