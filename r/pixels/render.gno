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
	return renderDashboard()
}

func renderDashboard() string {
	s := md.H1("Pixels✨")

	s += md.Paragraph("Remember the " +
		md.Link("r/place", "https://www.reddit.com/r/place/") +
		" subreddit ? `r/pixels` is the gno realm equivalent of that.")
	s += md.Blockquote("There is an empty canvas. You may place a pixel upon it. Individually you can create something. Together you can create something more.") + "\n\n"
	s += md.H3("Start now by creating [your own canvas🎨](" + txlink.Call("CreateCanvas", "fillColor", "") + ")")
	s += md.Paragraph("or contribute to the top canvas below by adding new pixels!")
	// NOTE: not working with adena
	// see https://github.com/onbloc/adena-wallet/issues/732
	s += "[Vote for this realm in Hall of Realms](" + txlink.Realm("gno.land/r/leon/hor").Call("Upvote", "pkgpath", "gno.land/r/tom101/pixels") + ")\n\n"
	s += md.HorizontalRule()

	// show caller canvas
	s += md.H2("Your canvas🏠")
	s += md.Paragraph("NOTE: Not possible to display your canvas until [#4069](https://github.com/gnolang/gno/issues/4069) is addressed")
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
	s += md.HorizontalRule()

	// show top canvas
	s += md.H2("Top canvas🥇")
	s += paginate.RenderReverseHead(canvasStore.byNumPixels, 3)
	s += md.Link("See all", ":top")

	return s
}

func RenderCanvas(id seqid.ID) string {
	c, ok := canvasStore.Get(id)
	if !ok {
		return md.Italic("no canvas found for id " + id.String())
	}
	return renderCanvas(c, false)
}

func renderCanvas(c Canvas, withTitle bool) string {
	var s string
	if withTitle {
		s += ufmt.Sprintf("Canvas #%d ", int(c.id))
		author := c.creator.String()
		user := users.ResolveAddress(c.creator)
		if user != nil {
			author = user.RenderLink("")
		}
		s += md.Italic(ufmt.Sprintf("-created by %s with %d pixel(s) from %d contributor(s)-", author, c.numPixels, len(c.contributors)))
	}
	s += " [[Add a pixel🖌](" + txlink.Call("AddPixel", "id", ufmt.Sprintf("%d", int(c.id)), "x", "", "y", "") + ")]"
	// Create the svg
	var svg strings.Builder
	ufmt.Fprintf(&svg,
		"<svg xmlns='http://www.w3.org/2000/svg' width='%d' height='%d' viewBox='0 0 %d %d'>",
		c.width, c.height, c.width/scale, c.height/scale,
	)
	if c.fillColor != "" {
		ufmt.Fprintf(&svg, "<rect width='100%%' height='100%%' fill='%s'/>", c.fillColor)
	}
	for color, path := range c.paths {
		ufmt.Fprintf(&svg, "<path d='%s' fill='%s'/>", path, color)
	}
	svg.WriteString("</svg>")
	s += svgimg.Render(ufmt.Sprintf("canvas#%d", int(c.id)), svg.String())
	return s
}
