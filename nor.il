pcDefinePCell(
	
	list(ddGetObj("test_Pcells") "Nor" "layout")

(
;Details of the cell
	(cellWidth 0.0)
	(cellHeight 20.0)
	(pWidth 6.0)
	(pLength 1)
	(nWidth 3.0)
	(nLength 1)
	(numberOfInputs 2)
	(nwell_enclosure 1)
;pwr and gnd info
	(pwrWidth 1.8)
	(gndWidth 1.8)
;pinNames
	(inputName "in")
	(outputName "out")
	(powerName "vdd")
	(gndName "gnd")
;DRC values
	(metalMetalSep 1.0)
	(contWidth 0.065)	
	(polyContEnclose 0.005)
	(metalContEnclose 0.5)
	(metalWidth 1)
)
let(()

;open NmosA transitor

tranId_nA=dbOpenCellViewByType("test_Pcells" "ntran" "layout")

dbCreateParamInst(
	pcCellView tranId_nA "ntran_A" (0:0) "R180" 1
	list(
		list("width" "float" nWidth)
		list("length" "float" nLength)
		list("metalWidth" "float" metalWidth)
	)
)
dbClose(tranId_nA)
;open NmosB transistor
tranId_nB=dbOpenCellViewByType("test_Pcells" "ntran" "layout")

dbCreateParamInst(
	pcCellView tranId_nB "ntran_B" (0:0) "R0" 1
	list(
		list("width" "float" nWidth)
		list("length" "float" nLength)
		list("metalWidth" "float" metalWidth)
	)
)
dbClose(tranId_nB)
;open PmosA transistor
tranId_pA=dbOpenCellViewByType("test_Pcells" "ptran" "layout")

dbCreateParamInst(
	pcCellView tranId_pA "ptran_A" (0:0) "R0" 1
	list(
		list("width" "float" pWidth)
		list("length" "float" pLength)
		list("metalWidth" "float" metalWidth)
	)
)
dbClose(tranId_pA)
;open PmosB transistor
tranId_pB=dbOpenCellViewByType("test_Pcells" "ptran" "layout")

dbCreateParamInst(
	pcCellView tranId_pB "ptran_B" (0:0) "R0" 1
	list(
		list("width" "float" pWidth)
		list("length" "float" pLength)
		list("metalWidth" "float" metalWidth)
	)
)
dbClose(tranId_pB)
;Get the ROD objects
;NMOSA
nATranObj=rodGetObj("ntran_A")
nAGateObj=rodGetObj("ntran_A/gate")
nADrainObj=rodGetObj("ntran_A/drain")
nASourceObj=rodGetObj("ntran_A/source")
;NMOSB
nBTranObj=rodGetObj("ntran_B")
nBGateObj=rodGetObj("ntran_B/gate")
nBDrainObj=rodGetObj("ntran_B/drain")
nBSourceObj=rodGetObj("ntran_B/source")
;PMOSA
pATranObj=rodGetObj("ptran_A")
pAGateObj=rodGetObj("ptran_A/gate")
pADrainObj=rodGetObj("ptran_A/drain")
pASourceObj=rodGetObj("ptran_A/source")
;PMOSB
pBTranObj=rodGetObj("ptran_B")
pBGateObj=rodGetObj("ptran_B/gate")
pBDrainObj=rodGetObj("ptran_B/drain")
pBSourceObj=rodGetObj("ptran_B/source")

;calculate minimum Height
minHeight=25

when(cellHeight<minHeight
	cellHeight=minHeight
)

;calculate the width of the power and gnd connections 
;based on the widest transistor
if(pATranObj~>width>nATranObj~>width
then
	cellWidth=if(pATranObj~>width >cellWidth pATranObj~>width cellWidth)
else
	cellWidth=if(nATranObj~>width >cellWidth nATranObj~>width cellWidth)
)
;create the boundary
text_bnd=rodCreateRect(
	?layer list("text" "drawing")
	?length cellHeight
	?width cellWidth*numberOfInputs
)
;create the vdd rail
pwrObj=rodCreateRect(
	?name "powerRail"
	?pin t
	?termName powerName
	?layer list("metal1" "drawing")
	?width numberOfInputs*cellWidth
	?length pwrWidth
)
;create the gnd rail
gndObj=rodCreateRect(
	?name "groundRail"
	?pin t
	?termName gndName
	?layer list("metal1" "drawing")
	?width numberOfInputs*cellWidth
	?length gndWidth
)
;align_pwr_gnd rail
rodAlign(
         ?alignObj pwrObj
         ?alignHandle "upperCenter"
         ?refObj gndObj
         ?refHandle "lowerCenter"
         ?ySep cellHeight
         ?maintain nil
)
;align PMOSA-S to PMOSB-D
align_PMOSAB=rodAlign(
	?alignObj pASourceObj
	?alignHandle "upperLeft"
	?refObj pBDrainObj
	?refHandle "upperLeft"
)
;align PMOS to vdd rail
rodAlign(
         ?alignObj align_PMOSAB
         ?alignHandle "upperCenter"
         ?refObj pwrObj
         ?refHandle "lowerCenter"
         ?ySep rodPointY(rodSubPoints(align_PMOSAB~>upperCenter
                                      pBSourceObj~>upperCenter)) - metalMetalSep
         ?maintain nil
)
;align NMOSA-D to NMOSB-D
align_NMOSAB=rodAlign(
	?alignObj nADrainObj
	?alignHandle "upperLeft"
	?refObj nBDrainObj
	?refHandle "upperLeft"
)
;align nmos to vss rail
rodAlign(
        ?alignObj align_NMOSAB
        ?alignHandle "lowerCenter"
        ?refObj gndObj
        ?refHandle "upperCenter"
        ?ySep rodPointY(rodSubPoints(align_NMOSAB~>lowerCenter
                                      nBDrainObj~>lowerCenter)) + metalMetalSep
        ?maintain nil
)
;Gate connection for B
gateConnObjB=rodCreatePath(
		?name "inputConn_B"
		?layer list("poly" "drawing")
		?width nBGateObj~>width
		?pts list(nBGateObj~>upperCenter pBGateObj~>lowerCenter)
)
;Gate connection for A
gateConnObjA=rodCreatePath(
		?name "inputConn_A"
		?layer list("poly" "drawing")
		?width nBGateObj~>width
		?pts list(nAGateObj~>upperCenter pAGateObj~>lowerCenter)
)
;PMOSB source to vdd rail
pPowerTieObjB=rodCreatePath(
		?termName powerName
		?layer list("metal1" "drawing")
		?width pBSourceObj~>width
		?pts
		list(
			pBSourceObj~>upperCenter
			rodAddToY(pBSourceObj~>upperCenter metalMetalSep)
		)
)
;NMOSB source to vss rail
nGroundTieObj_B=rodCreatePath(
		?termName gndName
		?layer list("metal1" "drawing")
		?width nBSourceObj~>width
		?pts
		list(
			nBSourceObj~>lowerCenter
			rodAddToY(nBSourceObj~>lowerCenter -metalMetalSep)
		)
)
;NMOSA source to vss rail
nGroundTieObj_B=rodCreatePath(
		?termName gndName
		?layer list("metal1" "drawing")
		?width nASourceObj~>width
		?pts
		list(
			nASourceObj~>lowerCenter
			rodAddToY(nASourceObj~>lowerCenter -metalMetalSep)
		)
)
;input connection for B
inPinObjB = rodCreatePath(
         ?name "inputPinB"
         ?termName inputName
         ?pin t
         ?termIOType "input"
         ?pinLabel t
         ?layer list("poly" "drawing")
         ?width contWidth + 2.0*polyContEnclose
         ?pts
         list(
            gateConnObjB~>upperCenter
            rodPointX(gateConnObjB~>upperCenter) -
            contWidth - 2.0*polyContEnclose:rodPointY(gateConnObjB~>upperCenter)
         )
         ?encSubPath
         list(
            ;  Create the central contact.
            list(
               ?layer list("contact" "drawing")
               ?enclosure polyContEnclose
               ?beginOffset -polyContEnclose
               ?endOffset -polyContEnclose
            )
            ;  Create the metal pad.
            list(
               ?layer list("metal1" "drawing")
               ?enclosure polyContEnclose - metalContEnclose
               ?beginOffset metalContEnclose - polyContEnclose
               ?endOffset metalContEnclose - polyContEnclose
            )
         )
);input connection for A
inPinObjA = rodCreatePath(
         ?name "inputPinA"
         ?termName inputName
         ?pin t
         ?termIOType "input"
         ?pinLabel t
         ?layer list("poly" "drawing")
         ?width contWidth + 2.0*polyContEnclose
         ?pts
         list(
            gateConnObjA~>upperCenter
            rodPointX(gateConnObjA~>upperCenter) -
            contWidth - 2.0*polyContEnclose:rodPointY(gateConnObjA~>upperCenter)
         )
         ?encSubPath
         list(
            ;  Create the central contact.
            list(
               ?layer list("contact" "drawing")
               ?enclosure polyContEnclose
               ?beginOffset -polyContEnclose
               ?endOffset -polyContEnclose
            )
            ;  Create the metal pad.
            list(
               ?layer list("metal1" "drawing")
               ?enclosure polyContEnclose - metalContEnclose
               ?beginOffset metalContEnclose - polyContEnclose
               ?endOffset metalContEnclose - polyContEnclose
            )
         )
)
CenterHeight=cellHeight-pwrWidth-gndWidth-pATranObj~>width-nATranObj~>width+2.0
;ouput connection from PMOS to center
outputConnPtoC=rodCreatePath(
		?name "outputConnPtoC"
		?layer list("metal1" "drawing")
		?width pADrainObj~>width
		?pts
		list(
		pADrainObj~>lowerCenter
		rodAddToY(pADrainObj~>lowerCenter -CenterHeight/2.0)
		)
)
;ouput connection from NMOS to center
outputConnNtoC=rodCreatePath(
		?name "outputConnNtoC"
		?layer list("metal1" "drawing")
		?width nADrainObj~>width
		?pts
		list(
		nADrainObj~>upperCenter
		rodAddToY(nADrainObj~>upperCenter CenterHeight/2.0)
		)
)
;output connection
outputConnObj=rodCreatePath(
		?name "ouputConn"
		?layer list("metal1" "drawing")
		?width outputConnNtoC~>width
		?pts
		list(
		outputConnNtoC~>upperLeft outputConnPtoC~>lowerRight)
)
;metal pad for output conn
outPinObj=rodCreateRect(
		?termName outputName
		?pin t
		?termIOType "output"
		?pinLabel t
		?layer list("metal1" "drawing")
		?width contWidth+2.0*metalContEnclose
		?length contWidth+2.0*metalContEnclose
)
;create a metal jog at output pin
rodAlign(
	?alignObj outPinObj
	?alignHandle "centerCenter"
	?refObj outputConnObj
	?refHandle if(outputConnObj~>numSegments ==1 "centerCenter" "mid1")
)
))
