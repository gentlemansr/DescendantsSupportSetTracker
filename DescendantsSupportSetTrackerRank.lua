--------------------------------------------------------------------------------
-- ALL FUNCTIONS THAT ARE NEEDED TO EVALUATE THE RANK FOR OUR GUILD DESCENDANTS OF THE DWEMER [PC/EU]
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- CHECK IF LIB SETS IS LOADED
--------------------------------------------------------------------------------
DSST.rankPieces = {}

function DSST.evaluatePieces(iSetId,iPieceId)
	lPieceCountB = 0
	lPieceCountJ = 0
	lPieceCountSt = 0
	lPieceCount1H = 0
	lPieceCountSh = 0
	lOwnBody = 0
	lOwnWeapon = 0 
	if iPieceId >= 3 and <= 7 then
		lPieceCountB = lPieceCountB+1
		else if iPieceId >= 8 and <= 9 then
			lPieceCountJ = lPieceCountJ + 1
			else if iPieceId >= 10 and <= 13 then
				lPieceCount1H = lPieceCount1H + 1
				else if iPieceId >= 18 and <= 21 then
					lPieceCountSt = lPieceCountSt  + 1 
					else if iPieceId = 22 then
						lPieceCountSh = lPieceCountSh  + 1 
					end	
				end	
			end	
		end
	end
	if lPieceCountB + lPieceCountJ > 5 then
		lOwnBody = 1
	end
	if lPieceCountJ + lPieceCountSt > 3 then
		lOwnWeapon = 1
	end
	DSST.rankPieces[iSetID] =  {lOwnBody,lOwnWeapon}
end

function DSST.evaluateRank()
	
end

function DSST.updateRank(iRank)
	d(iRank)
end