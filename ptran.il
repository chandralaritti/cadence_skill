pcDefinePCell(

	list(ddGetObj("test_Pcells") "ptran" "layout")

(
	(width 5)
	(length 1)
	(metalWidth 1)
)

let(()

	ObjDiff=rodCreateRect(
			?layer "active"
			?length width
			?width length+2*2
	)

	ObjPoly=rodCreateRect(
			?name "gate"
			?termName "G"
			?pin t
			?layer "poly"
			?length width+2
			?width length
			
	)

	align_diff_poly=rodAlign(
			?alignObj ObjPoly
			?alignHandle "centerCenter"
			?refObj ObjDiff
			?refHandle "centerCenter"
	)

	wellObj=rodCreateRect(
			?layer "nwell"
			?fromObj ObjDiff
			?size 1.5
	)

	metal1_source=rodCreateRect(
			?layer "metal1"
			?length width
			?width  metalWidth
			?name "source"
			?termName "S"
			?termIOType "input"
			?pin t
			?pinLabel t
			?pinLabelRefHandle "upperCenter"
			?subRectArray
			list(
			list(
			?layer "contact"
			?width 0.05
			?length 0.05		
			?lowerLeftOffsetX 0.1
			?lowerLeftOffsetY 0.1
			?upperRightOffsetX -0.1
			?upperRightOffsetY -0.1		
	))	
	)
	align_m1s_diff=rodAlign(
			?alignObj metal1_source
			?alignHandle "lowerLeft"
			?refObj ObjDiff
			?refHandle "lowerLeft"
	)

	metal1_drain=rodCreateRect(
			?layer "metal1"
			?length width
			?width metalWidth
			?name "drain"
			?termName "D"
			?pin t
			?subRectArray
			list(
			list(
			?layer "contact"
			?width 0.05
			?length 0.05
			?lowerLeftOffsetX 0.1
			?lowerLeftOffsetY 0.1
			?upperRightOffsetX -0.1
			?upperRightOffsetY -0.1	
	))
	)

	align_m1d_diff=rodAlign(
			?alignObj metal1_drain
			?alignHandle "lowerRight"
			?refObj ObjDiff
			?refHandle "lowerRight"
	)

)
)
