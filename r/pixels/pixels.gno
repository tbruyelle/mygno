package pixels

import (
	"std"

	"gno.land/p/demo/seqid"
	"gno.land/r/leon/hor"
)

// TODO
// - list of canvas with the most gas used or most pixels
// - add some tests (hard to test outside /gno main repo it seems)
// - add canvas contributors
// - add number of pixels & contributors in render
// - replace user link with r/gnoland/users/v1:<user>
// - add link to home in bio user registration

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
	canvasStore.AddPixel(id, x, y, color)
}
