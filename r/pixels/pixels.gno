package pixels

import (
	"gno.land/p/demo/svg"
	"gno.land/p/demo/ufmt"
	"gno.land/p/moul/md"
	"gno.land/p/moul/txlink"
	"gno.land/p/tom101/svgimg"
)

var c svg.Canvas

func init() {
	c = svg.Canvas{
		Width:  800,
		Height: 600,
	}
	for i := 0; i < 100; i++ {
		Add(i, 0, "red")
	}
}

const scale = 4

func Add(x, y int, color string) {
	// std.AssertOriginCall()
	x *= scale
	y *= scale
	if x < 0 || x > c.Width || y < 0 || y >= c.Height {
		panic("x or y out of range")
	}
	c.DrawRectangle(x, y, scale, scale, color)
}

func Render(path string) string {
	s := md.H1(ufmt.Sprintf("Pixels (%d)", len(c.Elems)))
	s += "[[Add a pixel](" + txlink.Call("Add", "100", "100") + ")]\n\n"
	s += svgimg.Render(c)
	return s
}
