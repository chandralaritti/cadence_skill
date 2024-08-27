pcDefinePCell(

list(ddGetObj("test_Pcells") "Inverter" "layout")

(
;Transitor info
	(pwidth 6)
	(plength 1)
	(nwidth 4)
	(nlength 1)
;cell info
	(cellWidth 0.0)
	(cellHeight 20.0)
;pwr and gnd info
	(pwrWidth 1.8)
	(gndWidth 1.8)
;pin Names
	(inputName "in")
	(outputName "out")
	(powerName "vdd")
	(groundName "gnd")
	(metalLayer "metal1")
;Technology values
	(metalMetalSep 1.0)
	(contWidth 0.065)	
	(polyContEnclose 0.005)
	(metalContEnclose 0.5)
	(metalWidth 1)
)

let((tranId_n tranId_p)

tranId_n=dbOpenCellViewByType("test_Pcells" "ntran" "layout")

dbCreateParamInst(
	pcCellView tranId_n "ntran1" (0:0) "R0" 1
	list(
	list("width" "float" nwidth)
	list("length" "float" nlength)
))

dbClose(tranId_n)

tranId_p=dbOpenCellViewByType("test_Pcells" "ptran" "layout")

dbCreateParamInst(
	pcCellView tranId_p "ptran1" (0:0) "R0" 1
	list(
	list("width" "float" pwidth)
	list("length" "float" plength)
))

dbClose(tranId_p)

nTranObj=rodGetObj("ntran1")

nGateObj=rodGetObj("ntran1/gate")

nDrainObj=rodGetObj("ntran1/drain")

nSourceObj=rodGetObj("ntran1/source")

pTranObj=rodGetObj("ptran1")

pGateObj=rodGetObj("ptran1/gate")

pDrainObj=rodGetObj("ptran1/drain")

pSourceObj=rodGetObj("ptran1/source")

;Calculate min height 

minHeight=25

;adjust min height of the cell , if necessary

when(cellHeight < minHeight
	cellHeight=minHeight
)

;Calculate the power and ground connections based on the width of transistor

if(pTranObj~>width >nTranObj~>width
then
cellWidth=if(pTranObj~>width > cellWidth pTranObj~>width cellWidth)
else
cellWidth=if(nTranObj~>width > cellWidth nTranObj~>width cellWidth)
)

;create a power rail

pwrObj=rodCreateRect(
		?name "powerRail"
		?pin t
		?termName powerName
		?layer list("metal1" "drawing")
		?width cellWidth
		?length pwrWidth
)

;create gnd rail

gndObj=rodCreateRect(
		?name "groundRail"
		?pin t
		?termName groundName
		?layer list("metal1" "drawing")
		?width cellWidth
		?length gndWidth
)

;align power and ground rails

pwr_gnd_align=rodAlign(
		?alignObj pwrObj
		?alignHandle "upperCenter"
		?refObj gndObj
		?refHandle "lowerCenter"
		?ySep cellHeight
		?maintain nil
)
;align PMOS with power rail
align_pmos_vdd=rodAlign(
		?alignObj pTranObj
		?alignHandle "upperCenter"
		?refObj pwrObj
		?refHandle "lowerCenter"
		?ySep rodPointY(rodSubPoints(pTranObj~>upperCenter
						pDrainObj~>upperCenter))-metalMetalSep
		?maintain nil
)
;align NMOS with gnd rail
align_nmos_gnd=rodAlign(
		?alignObj nTranObj
		?alignHandle "lowerCenter"
		?refObj gndObj
		?refHandle "upperCenter"
		?ySep rodPointY(rodSubPoints(nTranObj~>lowerCenter nDrainObj~>lowerCenter))+metalMetalSep
)
;create gate connection b/w pmos and nmos transistor
gateConnObj = rodCreatePath(
         ?name "inputConn"
         ?layer list("poly" "drawing")
         ?width plength
         ?pts list(nGateObj~>upperCenter pGateObj~>lowerCenter)
)
;connection to PMOS to VDD transistor
pPowerTieObj=rodCreatePath(
		?termName powerName
		?layer list("metal1" "drawing")
		?width pSourceObj~>width
		?pts
		list(
		pSourceObj~>upperCenter
		rodAddToY(pSourceObj~>upperCenter metalMetalSep)
		)
)
;connection to NMOS to VSS
nGroundTieObj=rodCreatePath(
		?termName groundName
		?layer list("metal1" "drawing")
		?width nSourceObj~>width
		?pts
		list(
		nSourceObj~>lowerCenter
		rodAddToY(nSourceObj~>lowerCenter -metalMetalSep)
		)
)
;create input pin structure
inPinObj = rodCreatePath(
		?name "inputPin"
         ?termName inputName
         ?pin t
         ?termIOType "input"
         ?pinLabel t
         ?layer list("poly" "drawing")
         ?width contWidth + 2.0*polyContEnclose
         ?pts
         list(
            gateConnObj~>centerCenter
            rodPointX(gateConnObj~>centerCenter) -
            contWidth - 2.0*polyContEnclose:rodPointY(gateConnObj~>centerCenter)
         )
         ?encSubPath
         list(
            ;  Create the poly contact.
            list(
               ?layer list("contact" "drawing")
               ?enclosure polyContEnclose
               ?beginOffset -polyContEnclose
               ?endOffset -polyContEnclose
            )
            ;  Create the metal pad.
            list(
               ?layer list(metalLayer "drawing")
               ?enclosure polyContEnclose - metalContEnclose
               ?beginOffset metalContEnclose - polyContEnclose
               ?endOffset metalContEnclose - polyContEnclose
            )
         )
)
;create the connection between drain 
 outputConnObj = rodCreatePath(
         ?name "outputConn"
         ?layer list("metal1" "drawing")
         ?width metalWidth
         ?pts
         list(
            rodAddToX(nDrainObj~>upperRight -metalWidth/2.0)
            rodPointX(nDrainObj~>upperRight) - metalWidth/2.0:
            rodPointY(inPinObj~>centerCenter)
            rodPointX(pDrainObj~>lowerRight) - metalWidth/2.0:
            rodPointY(inPinObj~>centerCenter)
            rodAddToX(pDrainObj~>lowerRight -metalWidth/2.0)
         )
      )
;Create the metal pad for output connection
outPinObj=rodCreateRect(
		?termName outputName
		?pin t
		?termIOType "output"
		?pinLabel t
		?layer list("metal1" "drawing")
		?width contWidth+2.0*metalContEnclose
		?length contWidth+2.0*metalContEnclose
)
;align outPinObj to outputConnObj
rodAlign(
         ?alignObj outPinObj
         ?alignHandle "centerCenter"
         ?refObj outputConnObj
         ?refHandle if(outputConnObj~>numSegments == 1 "centerCenter" "mid1")
         ?maintain nil
      )

))
