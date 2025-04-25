package svgimg

import (
	"encoding/base64"

	"gno.land/p/demo/svg"
	"gno.land/p/moul/dynreplacer"
	"gno.land/p/moul/md"
)

func Render(alt string, c svg.Canvas) string {
	// NOTE: strings.ReplaceAll fails with max allocation
	//	escapedSVG := strings.ReplaceAll(c.String(), "\"", "'")
	r := dynreplacer.New(
		dynreplacer.Pair{"\"", func() string { return "'" }},
	)
	escapedSVG := r.Replace(c.String())
	svg := base64.StdEncoding.EncodeToString([]byte(escapedSVG))
	return md.Image(alt, "data:image/svg+xml;base64,"+svg)
}
