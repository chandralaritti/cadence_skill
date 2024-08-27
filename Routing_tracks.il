pcDefinePCell(

list(ddGetObj("test_Pcells") "Routing_tracks" "layout")

(
	(bBoxWidth 200)
	(bBoxLength 300)
	(space_tracks_m1_y 0.8)
	(space_tracks_m2_x 0.8)
	(track_m1_size 5)
	(track_m2_size 5)
)

let(()
	
metal1=rodCreateRect(
		?layer list("text" "drawing")
		?width bBoxWidth
		?length bBoxLength
		?subRectArray
		list(
		list(
		?layer list("metal1" "track")
		?width bBoxWidth
		?length track_m1_size
		?spaceY space_tracks_m1_y
)

)
)

metal2=rodCreateRect(
		?layer list("text" "drawing")
		?width bBoxWidth
		?length bBoxLength
		?subRectArray
		list(
		list(
		?layer list("metal2" "track")
		?width track_m2_size
		?length bBoxLength
		?spaceX space_tracks_m2_x
		?spaceY space_tracks_m2_x
)
)
)
))
