pcDefinePCell(

	list(ddGetObj("test_Pcells") "nsub" "layout")

(
	(width 5.0)
	(length 2.0)
	(metalWidth 1.0)
)

let(()

ObjDiff=rodCreateRect(
			?layer "active"
			?length width
			?width length
)
metal1_conn=rodCreateRect(
			?layer "metal1"
			?length width
			?width  metalWidth
			?name "bulk"
			?termName "B"
			?termIOType "input"
			?pin t
			?pinLabel t
			?pinLabelRefHandle "upperCenter"
			?subRectArray
			list(
			list(
			?layer "contact"
			?width 0.065
			?length 0.065
			?lowerLeftOffsetX 0.05
			?lowerLeftOffsetY 0.05
			?upperRightOffsetX -0.05
			?upperRightOffsetY -0.05
			?spaceX 0.075
			?spaceY 0.075		
	))	
	)
rodAlign(
			?alignObj metal1_conn
			?alignHandle "lowerCenter"
			?refObj ObjDiff
			?refHandle "lowerCenter"
)

))
