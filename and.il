pcDefinePCell(

	list(ddGetObj("test_Pcells") "and" "layout")
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

;open Nand Gate

tranId_nand=dbOpenCellViewByType("test_Pcells" "Nand" "layout")

dbCreateParamInst(
	pcCellView tranId_nand "Nand1" (0:0) "R0" 1
	list(
		list("nwidth" "float" nWidth)
		list("nlength" "float" nLength)
		list("metalWidth" "float" metalWidth)
		list("pwidth" "float" pWidth)
		list("plength" "float" pLength)
		list("cellWidth" "float" cellWidth)
		list("cellHeight" "float" cellHeight)
		list("numberOfInputs" "float" numberOfInputs)
		list("pwrWidth" "float" pwrWidth)
		list("gndWidth" "float" gndWidth)
	)
)
dbClose(tranId_nand)
;open Inverter Gate
tranId_Inv=dbOpenCellViewByType("test_Pcells" "Inverter" "layout")

dbCreateParamInst(
	pcCellView tranId_Inv "Inv1" (0:0) "R0" 1
	list(
		list("nwidth" "float" nWidth)
		list("nlength" "float" nLength)
		list("metalWidth" "float" metalWidth)
		list("pwidth" "float" pWidth)
		list("plength" "float" pLength)
		list("cellWidth" "float" cellWidth)
		list("cellHeight" "float" cellHeight)
		list("numberOfInputs" "float" numberOfInputs)
		list("pwrWidth" "float" pwrWidth)
		list("gndWidth" "float" gndWidth)
	)
)
dbClose(tranId_Inv)
;Get the ROD objects
;NAND
nandTranObj=rodGetObj("Nand1")
nandInputObj=rodGetObj("Nand1/inputPinA")
nandOutputObj=rodGetObj("Nand1/ouputConn")
nandpwrObj=rodGetObj("Nand1/vdd")
nandgndObj=rodGetObj("Nand1/gnd")  
;Inverter
invTranObj=rodGetObj("Inv1")
invInputObj=rodGetObj("Inv1/inputPin")
invOutputObj=rodGetObj("Inv1/ouputConn")
invpwrObj=rodGetObj("Inv1/vdd")
invgndObj=rodGetObj("Inv1/gnd")  
;align inv to nand

align_inv_nand=rodAlign(
		?alignObj invTranObj
		?alignHandle "lowerLeft"
		?refObj nandTranObj
		?refHandle "lowerRight"
)
;Out_Nand to In_Inv
InputConnObj=rodCreatePath(
		?name "InputConn"
		?layer list("metal1" "drawing")
		?width 1
		?pts
		list(
		nandOutputObj~>centerRight invInputObj~>centerLeft)
)
))
