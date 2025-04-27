package pixels

import (
	"strconv"
	"strings"

	"gno.land/p/demo/ufmt"

	"gno.land/p/tom101/svgimg"
)

const (
	canvasSize = 400
	pixelSize  = 100
)

func svgBase64(c Canvas) string {
	// estimate out size
	var svg strings.Builder
	// svg.Grow(canvasSize + pixelSize*len(c.pixels))
	svg.WriteString(ufmt.Sprintf("<svg xmlns='http://www.w3.org/2000/svg' width='%d' height='%d'>", c.width, c.height))
	if c.fillColor != "" {
		svg.WriteString(ufmt.Sprintf("<rect x='0' y='0' width='%d' height='%d' fill='%s' />", c.width, c.height, c.fillColor))
	}
	sscale := strconv.Itoa(scale)
	for _, p := range c.pixels {
		svg.WriteString("<rect x='")
		svg.WriteString(p.x)
		svg.WriteString("' y='")
		svg.WriteString(p.y)
		svg.WriteString("' width='")
		svg.WriteString(sscale)
		svg.WriteString("' height='")
		svg.WriteString(sscale)
		svg.WriteString("' fill='")
		svg.WriteString(p.color)
		svg.WriteString("' />")
	}
	svg.WriteString("</svg>")
	return svgimg.RenderRaw("", svg.String())
}
