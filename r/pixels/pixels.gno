package pixels

import (
	"std"

	"gno.land/p/demo/svg"
	"gno.land/p/moul/md"
	"gno.land/p/moul/txlink"
	"gno.land/p/tom101/svgimg"
	"gno.land/r/leon/hor"
	"gno.land/r/sys/users"
)

// TODO
// - list of canvas with the most gas used or most pixels
// - use p/demo/releases for smooth upgrade
// - find a way to optimize gas consuption: for example store each coords a
// a sub avl tree?
// - add a hor upvote button directly in the render?
// - move addPixel to canvasStore
// - add readers to canvasStore

var (
	admin       = std.Address("g1w3saysjxdlsyczysnyfd55tuvhhz5533nef8y7")
	canvasStore *CanvasStore
)

func init() {
	canvasStore = newCanvasStore()
	hor.Register("Pixels", "r/places subreddit for gno")
}

type canvas struct {
	id      string
	creator std.Address
	canvas  svg.Canvas
}

func (c canvas) render(withTitle bool) string {
	var s string
	if withTitle {
		title := "Canvas #" + c.id
		user := users.ResolveAddress(c.creator)
		if user != nil {
			title += " (created by " + md.Link(user.Name(), "/r/"+user.Name()+"/home") + ")"
		} else {
			title += " (created by " + c.creator.String() + ")"
		}
		s += md.H3(title)
	}
	s += "[[Add a pixel](" + txlink.Call("AddPixel", "id", c.id, "x", "", "y", "") + ")]"
	s += svgimg.Render("canvas#"+c.id, c.canvas)
	return s
}

func UpdateAdmin(address std.Address) {
	caller := std.OriginCaller()
	if caller != admin {
		panic("restricted area")
	}
	admin = address
}

const (
	scale  = 4
	width  = 800
	height = 600
)

func CreateCanvas(fillColor string) string {
	std.AssertOriginCall()
	return canvasStore.addCanvas(std.OriginCaller(), fillColor)
}

func DeleteCanvas(id string) {
	std.AssertOriginCall()
	canvasStore.deleteCanvas(std.OriginCaller(), id)
}

func AddPixel(id string, x, y int, color string) {
	std.AssertOriginCall()
	c := getCanvas(id)
	x *= scale
	y *= scale
	if x < 0 || x > c.canvas.Width || y < 0 || y >= c.canvas.Height {
		panic("x or y out of range")
	}
	c.canvas.DrawRectangle(x, y, scale, scale, color)
	canvasStore.byID.Set(id, c)
}

func getCanvas(id string) canvas {
	c, ok := canvasStore.byID.Get(id)
	if !ok {
		panic("canvas does not exist for id: " + id)
	}
	return c.(canvas)
}

func RenderCanvas(id string) string {
	c, ok := canvasStore.byID.Get(id)
	if !ok {
		return md.Italic("no canvas found for id " + id)
	}
	return c.(canvas).render(false)
}

func Render(path string) string {
	s := md.H1("Pixels")
	// WIP not working for now
	s += "[UpVote](" + txlink.Realm("127.0.0.1:8888/r/leon/hor").Call("Upvote", "pkgpath", "/r/tom101/pixels") + ")\n\n"

	s += md.Paragraph("Remember the " +
		md.Link("r/place", "https://www.reddit.com/r/place/") +
		" subreddit ? `r/pixels` is the gno realm equivalent of that.")
	s += md.Blockquote("There is an empty canvas. You may place a pixel upon it. Individually you can create something. Together you can create something more.") + "\n\n"
	s += md.Paragraph("Create your canvas by calling [[CreateCanvas](" + txlink.Call("CreateCanvas", "fillColor", "") + ")].")
	// show caller canvas
	s += md.H2("Your canvas")
	s += md.Blockquote("Not possible to display your canvas until "+md.Link("#4069", "https://github.com/gnolang/gno/issues/4069")+" is addressed") + "\n\n"
	/*
		canvasBy.Adr.Iterate("", "", func(key string, value any) bool {
			ids := value.([]int)
			s += md.Blockquote(key)
			for _, id := range ids {
				s += md.Blockquote(strconv.Itoa(id))
			}
			return false
		})
		cc, ok := canvasBy.Adr.Get(std.OriginCaller().String())
		if ok {
			for _, id := range cc.([]int) {
				sid := strconv.Itoa(id)
				s += renderCanvas(sid, getCanvas(sid))
			}
		} else {
			s += md.Paragraph("You have no canvas yet.")
		}
	*/

	// show top canvas
	s += md.H2("Top canvas")
	if canvasStore.byID.Size() == 0 {
		s += md.Paragraph(md.Italic("No canvas created yet!"))
	} else {
		canvasStore.byID.Iterate("", "", func(_ string, value any) bool {
			s += "\n"
			s += value.(canvas).render(true)
			return false
		})
	}
	return s
}
