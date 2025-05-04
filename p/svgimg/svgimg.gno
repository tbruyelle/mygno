package svgimg

import (
	"encoding/base64"

	"gno.land/p/moul/md"
)

func Render(alt string, svg string) string {
	svg = base64.StdEncoding.EncodeToString([]byte(svg))
	return md.Image(alt, "data:image/svg+xml;base64,"+svg)
}
