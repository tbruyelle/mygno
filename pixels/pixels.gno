package pixels

import (
	"encoding/base64"
	"strings"

	"gno.land/p/demo/svg"
	"gno.land/p/moul/md"
	"gno.land/p/moul/txlink"
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

func Add(x, y int, color string) {
	if x < 0 || x > c.Width || y < 0 || y >= c.Height {
		panic("x or y out of range")
	}
	c.DrawRectangle(x, y, 1, 1, color)
}

func Render(path string) string {
	s := ""
	s += "[[Add a pixel](" + txlink.Call("Add", "100", "100") + ")]\n\n"
	escapedSVG := strings.ReplaceAll(c.String(), "\"", "'")
	svg := base64.StdEncoding.EncodeToString([]byte(escapedSVG))
	s += md.Image("pixelsbase64", "data:image/svg+xml;base64,"+svg) + "\n\n"
	return s
}
