package pixels

import (
	"std"

	"gno.land/p/demo/seqid"
	"gno.land/r/leon/hor"
)

// TODO
// - add some tests (hard to test outside /gno main repo it seems)
// - add link to home in bio user registration
// - list contributors somewhere? Need a single page display
// - add title to canvas?
// - perf: store pixel x,y and canvas width/height as strings
// - perf: improve render
// - doc: mention canvas size somewhere

var (
	admin       = std.Address("g1w3saysjxdlsyczysnyfd55tuvhhz5533nef8y7")
	canvasStore *CanvasStore
)

func init() {
	canvasStore = newCanvasStore()
	// TODO make gnoverse/gnopls works with cross
	cross(hor.Register)("Pixels", "A gno implementation of the `r/place` subreddit.")
}

func UpdateAdmin(address std.Address) {
	crossing()
	caller := std.OriginCaller()
	if caller != admin {
		panic("restricted area")
	}
	admin = address
}

func CreateCanvas(fillColor string) seqid.ID {
	crossing()
	std.AssertOriginCall()
	return canvasStore.Add(std.OriginCaller(), fillColor)
}

func DeleteCanvas(id seqid.ID) {
	crossing()
	std.AssertOriginCall()
	canvasStore.Delete(std.OriginCaller(), id)
}

func AddPixel(id seqid.ID, x, y int, color string) {
	crossing()
	std.AssertOriginCall()
	canvasStore.AddPixel(std.OriginCaller(), id, x, y, color)
}
