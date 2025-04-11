package svgimg

import (
	"encoding/base64"
	"strings"

	"gno.land/p/demo/svg"
	"gno.land/p/moul/md"
)

func Render(c svg.Canvas) string {
	escapedSVG := strings.ReplaceAll(c.String(), "\"", "'")
	svg := base64.StdEncoding.EncodeToString([]byte(escapedSVG))
	return md.Image("pixelsbase64", "data:image/svg+xml;base64,"+svg)
}
