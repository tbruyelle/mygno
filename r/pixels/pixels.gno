package pixels

import (
	"std"

	"gno.land/r/leon/hor"
)

// TODO
// - list of canvas with the most gas used or most pixels
// - use p/demo/releases for smooth upgrade
// - find a way to optimize gas consuption: for example store each coords a
// a sub avl tree?
// - add a hor upvote button directly in the render?

var (
	admin       = std.Address("g1w3saysjxdlsyczysnyfd55tuvhhz5533nef8y7")
	canvasStore *CanvasStore
)

func init() {
	canvasStore = newCanvasStore()
	hor.Register("Pixels", "r/places subreddit for gno")
}

func UpdateAdmin(address std.Address) {
	caller := std.OriginCaller()
	if caller != admin {
		panic("restricted area")
	}
	admin = address
}

func CreateCanvas(fillColor string) string {
	std.AssertOriginCall()
	return canvasStore.add(std.OriginCaller(), fillColor)
}

func DeleteCanvas(id string) {
	std.AssertOriginCall()
	canvasStore.delete(std.OriginCaller(), id)
}

func AddPixel(id string, x, y int, color string) {
	std.AssertOriginCall()
	canvasStore.addPixel(id, x, y, color)
}
