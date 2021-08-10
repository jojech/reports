-- Lana's Requested Changes to the Inventory - Current Quantities Query
-- Jeremy Johnson 6/8/21

SELECT IT.ItemCode														 AS 'Item Code'
	, ISNULL(IT.ItemName		, '')									 AS 'Item Name'
	, CASE IT.ItemType
	WHEN 'I' THEN 'Item'
	WHEN 'F' THEN 'Fixed Assets'
	WHEN 'L' THEN 'Labor'
	WHEN 'T' THEN 'Travel'
	ELSE ''	 END													 AS 'Item Type'
	, IG.ItmsGrpNam													 AS 'Item Group'
	, FR.FirmName														 AS 'Manufacturer'
	, CASE ISNULL(SN.AbsEntry	,   0 )	WHEN 0 THEN 'N'
	ELSE 'S'									END						 AS 'Managed By'
	, IW.WhsCode														 AS 'Warehouse'
	, ISNULL(BN.BinCode	, ''		)								 AS 'BIN Code'	
	, ISNULL(SQ.Quantity	, ISNULL(SB.OnHandQty 	, ISNULL(IB.OnHandQty	, IW.OnHand)))	AS 'In Stock'
	, CASE 
	WHEN IT.ManSerNum	 = 'Y' THEN SN.CostTotal
	ELSE 
	CASE CD.PriceSys	WHEN 'N' THEN IT.AvgPrice ELSE IW.AvgPrice  END
	END																 AS 'Item Cost'
	, ISNULL(SQ.Quantity	, ISNULL(SB.OnHandQty	, ISNULL(IB.OnHandQty	, IW.OnHand)))
	* CASE 
	WHEN IT.ManSerNum	 = 'Y' THEN SN.CostTotal
	ELSE 
	CASE CD.PriceSys	WHEN 'N' THEN IT.AvgPrice ELSE IW.AvgPrice  END
	END																 AS 'Stock Value'
	, ISNULL(SN.DistNumber		, '' )	 								 AS 'Equipment ID'
	, ISNULL(SN.MnfSerial		, '' )	 								 AS 'Manufacturer Serial'

--				 , ISNULL(TL.ApplyType		, IM.TransType	)						 AS 'Entry Type'
	, CASE ISNULL(TL.ApplyType	, IM.TransType)
	WHEN		  -1 THEN ''
	WHEN		   0 THEN ''
	WHEN		  13 THEN 'A/R Invoice'
	WHEN		  15 THEN 'Delivery'
	WHEN		 163 THEN 'A/P Correction Invoice'
	WHEN		 164 THEN 'A/P Correction Invoice Reversal'
	WHEN		 165 THEN 'A/R Correction Invoice'
	WHEN		 166 THEN 'A/R Correction Invoice Reversal'
	WHEN		  16 THEN 'Returns'
	WHEN		  17 THEN 'Sales Order'
	WHEN		  18 THEN 'A/P Invoice'
	WHEN		 202 THEN 'Production Order'
	WHEN		 203 THEN 'A/R Down Payment'
	WHEN		 204 THEN 'A/P Down Payment'
	WHEN		  20 THEN 'Goods Receipt PO'
	WHEN		  21 THEN 'Goods Return'
	WHEN		  22 THEN 'Purchase Order'
	WHEN		  23 THEN 'Sales'
	WHEN 	10000071 THEN 'Inventory Posting'
	WHEN		  67 THEN 'Inventory Transfer'
	WHEN		  59 THEN 'Goods Receipt'
	ELSE				  'Inv. Transfer'			 END				 AS 'Document Type'
	, ISNULL(TL.AppDocNum		, IM.BASE_REF	)						 AS 'Document Number' 
--				 , ISNULL(TL.DocLine		, IM.DocLineNum							 AS 'Document Line'
	, FORMAT(ISNULL(TL.DocDate	, IM.DocDate)	, 'MM/dd/yyyy')			 AS 'Document Date' 
	
FROM OADM CD (NOLOCK) 
			, OITM IT (NOLOCK) 												-- Items 
INNER JOIN OITW IW (NOLOCK) ON IW.ItemCode	= IT.ItemCode					-- Items Warehouse
INNER JOIN OWHS WH (NOLOCK) ON WH.WhsCode	= IW.WhsCode					-- Warehouses
INNER JOIN OMRC FR (NOLOCK) ON FR.FirmCode	= IT.FirmCode					-- Manufacturer
INNER JOIN OITB IG (NOLOCK) ON IG.ItmsGrpCod	= IT.ItmsGrpCod				-- Item Group
LEFT  JOIN OSRQ SQ (NOLOCK) ON SQ.WhsCode	= IW.WhsCode	AND SQ.ItemCode	= IW.ItemCode	AND SQ.Quantity  > 0	AND IT.ManSerNum	= 'Y'	-- Serial Quantities
LEFT  JOIN OSBQ SB (NOLOCK) ON SB.WhsCode	= SQ.WhsCode	AND SB.SnBMDAbs	= SQ.MdAbsEntry	AND SB.OnHandQty > 0	AND IT.ManSerNum	= 'Y'	-- Serial BIN Accumulator
LEFT  JOIN OSRN SN (NOLOCK) ON SN.ItemCode	= SQ.ItemCode	AND SN.AbsEntry	= SQ.MdAbsEntry							AND IT.ManSerNum	= 'Y'	-- Serial Master Data
LEFT  JOIN OIBQ IB (NOLOCK) ON IB.WhsCode	= IW.WhsCode	AND IB.ItemCode	= IW.ItemCode	AND IB.OnHandQty > 0								-- WHS    BIN Accumulator
					AND IB.BinAbs		= ISNULL( SB.BinAbs , IB.BinAbs )  --ISNULL( BB.BinAbs , IB.BinAbs ) )
LEFT  JOIN OBIN BN (NOLOCK) ON BN.AbsEntry	= CASE IT.ManSerNum	 WHEN 'Y' THEN SB.BinAbs														-- BIN Location
											ELSE CASE WH.BinActivat WHEN 'Y' THEN IB.BinAbs  ELSE 0	 END	 END
OUTER APPLY (	SELECT MAX(TL.LogEntry) AS 'LogEntry'
					FROM OITL TL (NOLOCK) 
			INNER JOIN ITL1 L1 (NOLOCK) ON L1.LogEntry	= TL.LogEntry	AND L1.ItemCode		= TL.ItemCode  
					WHERE TL.ItemCode		 = SN.ItemCode
					AND L1.SysNumber		 = SN.SysNumber   
					--AND TL.LocCode		 = IW.WhsCode
					AND TL.AllocatEnt	 = -1
--						   AND IT.ManSerNum		 = 'Y'
					AND TL.ApplyType		NOT IN (67) -- IN (163 , 164 , 16 , 18 , 202 , 204 , 20 , 21 , 22, 59, 10000071)
				) LE  
LEFT  JOIN ITL1 L1 (NOLOCK) ON L1.ItemCode	= SN.ItemCode	AND L1.SysNumber	= SN.SysNumber   AND L1.LogEntry	= LE.LogEntry 
LEFT  JOIN OITL TL (NOLOCK) ON TL.LogEntry	= L1.LogEntry	AND TL.ItemCode		= L1.ItemCode

OUTER APPLY (	SELECT MAX(IM.TransSeq) AS 'TransSeq'
					FROM OINM IM (NOLOCK)
			LEFT  JOIN OACT AC (NOLOCK) ON AC.AcctCode	= IM.InvntAct
					WHERE IM.ItemCode		 = IT.ItemCode	
--						   AND IM.Warehouse		 = WH.WhsCode
					AND IM.TransType		NOT IN (67) -- IN (163 , 164 , 16 , 18 , 202 , 204 , 20 , 21 , 22, 59, 10000071)
--						   AND AC.FatherNum		 = '1020'
--						   AND ISNULL(AC.AcctCode,'')	NOT IN ('130998','130999')
					AND IM.InQty			  > 0
			) MT
LEFT  JOIN OINM IM (NOLOCK) ON IM.TransSeq	= MT.TransSeq	--AND IT.ManSerNum	 = 'N'

WHERE IW.OnHand		 > 0 
	-- AND IT.ManSerNum		 = 'Y'
	-- AND (LEFT(IW.WhsCode,1) <> 'T' OR LEFT(IW.WhsCode,3) = 'TAM')
	AND WH.State = '[%1]'

ORDER BY 13, 3, 4, 5, 1, 7, 8