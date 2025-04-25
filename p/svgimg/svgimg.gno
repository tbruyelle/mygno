package svgimg

import (
	"encoding/base64"

	"gno.land/p/demo/svg"
	"gno.land/p/moul/dynreplacer"
	"gno.land/p/moul/md"
)

func Render(alt string, c svg.Canvas) string {
	r := dynreplacer.New(
		dynreplacer.Pair{Placeholder: "\"", Callback: func() string { return "'" }},
	)
	escapedSVG := r.Replace(c.String())
	return RenderRaw(alt, escapedSVG)
}

// RenderRaw requires svg to use ' instead of "
func RenderRaw(alt string, svg string) string {
	svg = base64.StdEncoding.EncodeToString([]byte(svg))
	return md.Image(alt, "data:image/svg+xml;base64,"+svg)
}
