package pixels

import (
	"std"

	"gno.land/p/demo/seqid"
	"gno.land/r/leon/hor"
)

// TODO
// - list of canvas with the most gas used or most pixels
// - use p/demo/releases for smooth upgrade
// - find a way to optimize gas consuption: for example store each coords a
// a sub avl tree?
// - add some tests
// - use short seqid.ID for rendering and links, or longer String representation?

var (
	admin       = std.Address("g1w3saysjxdlsyczysnyfd55tuvhhz5533nef8y7")
	canvasStore *CanvasStore
)

func init() {
	canvasStore = newCanvasStore()
	hor.Register("Pixels", "A gno implementation of the `r/place` subreddit.")
}

func UpdateAdmin(address std.Address) {
	caller := std.OriginCaller()
	if caller != admin {
		panic("restricted area")
	}
	admin = address
}

func CreateCanvas(fillColor string) seqid.ID {
	std.AssertOriginCall()
	return canvasStore.Add(std.OriginCaller(), fillColor)
}

func DeleteCanvas(id seqid.ID) {
	std.AssertOriginCall()
	canvasStore.Delete(std.OriginCaller(), id)
}

func AddPixel(id seqid.ID, x, y int, color string) {
	std.AssertOriginCall()
	canvasStore.AddPixel(id, x, y, color)
}
