package pixels

import (
	"std"
	"strconv"

	"gno.land/p/demo/avl"
	"gno.land/p/demo/svg"
	"gno.land/p/moul/md"
	"gno.land/p/moul/txlink"
	"gno.land/p/tom101/svgimg"
)

// TODO
// - attach user anme to canvas and display name
// - list of canvas with the most gas used or most pixels
// - use p/demo/releases for smooth upgrade

var (
	admin       = std.Address("g1w3saysjxdlsyczysnyfd55tuvhhz5533nef8y7")
	id          int
	canvasByID  avl.Tree
	canvasByAdr avl.Tree
)

func init() {
	canvasByID = avl.Tree{}
	canvasByAdr = avl.Tree{}
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

func CreateCanvas(fillColor string) {
	std.AssertOriginCall()
	c := svg.Canvas{
		Width:  width,
		Height: height,
	}
	if fillColor != "" {
		c.DrawRectangle(0, 0, width, height, fillColor)
	}
	// add to canvasById
	id++
	sid := strconv.Itoa(id)
	canvasByID.Set(sid, c)
	// add to canvasByAdr
	caller := std.OriginCaller().String()
	idsi, ok := canvasByAdr.Get(caller)
	if ok {
		ids := idsi.([]string)
		ids = append(ids, sid)
		canvasByAdr.Set(caller, ids)
	} else {
		canvasByAdr.Set(caller, []string{sid})
	}
}

func AddPixel(id string, x, y int, color string) {
	std.AssertOriginCall()
	c := getCanvas(id)
	x *= scale
	y *= scale
	if x < 0 || x > c.Width || y < 0 || y >= c.Height {
		panic("x or y out of range")
	}
	c.DrawRectangle(x, y, scale, scale, color)
	canvasByID.Set(id, c)
}

func getCanvas(id string) svg.Canvas {
	c, ok := canvasByID.Get(id)
	if !ok {
		panic("canvas does not exist for id: " + id)
	}
	return c.(svg.Canvas)
}

func Render(path string) string {
	s := md.H1("Pixels")
	s += md.Paragraph("Remember the " +
		md.Link("r/places", "https://www.reddit.com/r/place/") +
		" subreddit ? `r/pixels` is the gno realm equivalent of that.")
	s += md.Blockquote("There is an empty canvas. You may place a pixel upon it. Individually you can create something. Together you can create something more.") + "\n\n"
	// show caller canvas
	s += md.H2("Your canvas")
	s += md.Blockquote("Not possible to display your canvas until "+md.Link("#4069", "https://github.com/gnolang/gno/issues/4069")+" is addressed") + "\n\n"
	/*
		canvasByAdr.Iterate("", "", func(key string, value any) bool {
			ids := value.([]int)
			s += md.Blockquote(key)
			for _, id := range ids {
				s += md.Blockquote(strconv.Itoa(id))
			}
			return false
		})
		cc, ok := canvasByAdr.Get(std.OriginCaller().String())
		if ok {
			for _, id := range cc.([]int) {
				sid := strconv.Itoa(id)
				s += renderCanvas(sid, getCanvas(sid))
			}
		} else {
			s += md.Paragraph("You have no canvas yet.")
		}
	*/
	s += md.Paragraph("Add your own canvas by calling [[CreateCanvas](" + txlink.Call("CreateCanvas", "fillColor", "") + ")]")

	// show top canvas
	s += md.H2("Top canvas")
	if canvasByID.Size() == 0 {
		s += md.Paragraph("No canvas created yet!")
	} else {
		canvasByID.Iterate("", "", func(key string, value any) bool {
			s += "\n"
			s += renderCanvas(key, value.(svg.Canvas))
			return false
		})
	}
	return s
}

func renderCanvas(id string, c svg.Canvas) string {
	s := md.H3("Canvas #" + id)
	s += "[[Add a pixel](" + txlink.Call("AddPixel", "id", id, "x", "", "y", "") + ")]"
	s += svgimg.Render(c)
	return s
}
