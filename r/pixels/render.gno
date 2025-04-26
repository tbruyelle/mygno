package pixels

import (
	"strings"

	"gno.land/p/demo/seqid"
	"gno.land/p/demo/ufmt"
	"gno.land/p/moul/md"
	"gno.land/p/moul/txlink"
	"gno.land/p/tom101/paginate"
	"gno.land/p/tom101/svgimg"
	"gno.land/r/sys/users"
)

func Render(path string) string {
	s := md.H1("Pixels✨")

	s += md.Paragraph("Remember the " +
		md.Link("r/place", "https://www.reddit.com/r/place/") +
		" subreddit ? `r/pixels` is the gno realm equivalent of that.")
	s += md.Blockquote("There is an empty canvas. You may place a pixel upon it. Individually you can create something. Together you can create something more.") + "\n\n"
	s += md.H3("Start now by creating [your own canvas](" + txlink.Call("CreateCanvas", "fillColor", "") + ")")
	s += md.Paragraph("or contribute to the top canvas below by adding new pixels!")
	// NOTE: not working with adena
	// see https://github.com/onbloc/adena-wallet/issues/732
	s += "[Vote for this realm in Hall of Realms](" + txlink.Realm("gno.land/r/leon/hor").Call("Upvote", "pkgpath", "gno.land/r/tom101/pixels") + ")\n\n"
	s += md.HorizontalRule()

	// show top canvas
	// TODO sort by number of pixels
	s += md.H2("Top canvas🥇")
	s += paginate.RenderReverse(canvasStore.byNumPixels, path, 3)

	// show caller canvas
	// NOTE: Not possible to display your canvas until https://github.com/gnolang/gno/issues/4069 is addressed
	/*
		s += md.H2("Your canvas🏠")
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

	return s
}

func RenderCanvas(id seqid.ID) string {
	c, ok := canvasStore.Get(id)
	if !ok {
		return md.Italic("no canvas found for id " + id.String())
	}
	return renderCanvas(c, false)
}

const (
	canvasSize = 400
	pixelSize  = 100
)

func renderCanvas(c Canvas, withTitle bool) string {
	var out strings.Builder
	// estimate out size
	out.Grow(canvasSize + pixelSize*len(c.pixels))
	if withTitle {
		out.WriteString(ufmt.Sprintf("Canvas #%d ", int(c.id)))
		author := c.creator.String()
		user := users.ResolveAddress(c.creator)
		if user != nil {
			author = user.RenderLink("")
		}
		out.WriteString(
			md.Italic(ufmt.Sprintf("-created by %s with %d pixel(s) from %d contributor(s)-",
				author, len(c.pixels), len(c.contributors))),
		)
	}
	out.WriteString(" [[Add a pixel](" + txlink.Call("AddPixel", "id", ufmt.Sprintf("%d", int(c.id)), "x", "", "y", "") + ")]")
	// build svg canvas
	var svg strings.Builder
	svg.WriteString(ufmt.Sprintf("<svg xmlns='http://www.w3.org/2000/svg' width='%d' height='%d'>", c.width, c.height))
	if c.fillColor != "" {
		svg.WriteString(ufmt.Sprintf("<rect x='0' y='0' width='%d' height='%d' fill='%s' />", c.width, c.height, c.fillColor))
	}
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
	out.WriteString(svgimg.RenderRaw(ufmt.Sprintf("canvas#%d", int(c.id)), svg.String()))
	out.WriteString(md.Bold(ufmt.Sprint("size=%d", out.Len())))
	return out.String()
}
