package pixels

import (
	"gno.land/p/demo/seqid"
	"gno.land/p/demo/ufmt"
	"gno.land/p/moul/md"
	"gno.land/p/moul/txlink"
	"gno.land/p/tom101/paginate"
	"gno.land/p/tom101/svgimg"
	"gno.land/r/sys/users"
)

func Render(path string) string {
	s := md.H1("Pixels")

	s += md.Paragraph("Remember the " +
		md.Link("r/place", "https://www.reddit.com/r/place/") +
		" subreddit ? `r/pixels` is the gno realm equivalent of that.")
	s += md.Blockquote("There is an empty canvas. You may place a pixel upon it. Individually you can create something. Together you can create something more.") + "\n\n"
	s += md.Paragraph("Create your canvas by calling [[CreateCanvas](" + txlink.Call("CreateCanvas", "fillColor", "") + ")].")
	// show caller canvas
	s += md.H2("Your canvas")
	s += md.Blockquote("Not possible to display your canvas until "+md.Link("#4069", "https://github.com/gnolang/gno/issues/4069")+" is addressed") + "\n\n"
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

	// show top canvas
	s += md.H2("Top canvas")
	s += paginate.Render(canvasStore.byID, path, 3)
	// NOTE: not working with adena see https://github.com/onbloc/adena-wallet/issues/732
	s += "[Vote for this realm in Hall of Realms](" + txlink.Realm("gno.land/r/leon/hor").Call("Upvote", "pkgpath", "gno.land/r/tom101/pixels") + ")\n\n"
	return s
}

func (c Canvas) RenderLine() string {
	return renderCanvas(c, true)
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
		user := users.ResolveAddress(c.creator)
		if user != nil {
			s += md.Italic("(created by " + md.Link(user.Name(), "/r/"+user.Name()+"/home") + ")")
		} else {
			s += md.Italic("(created by " + c.creator.String() + ")")
		}
	}
	s += " [[Add a pixel](" + txlink.Call("AddPixel", "id", ufmt.Sprintf("%d", int(c.id)), "x", "", "y", "") + ")]"
	s += svgimg.Render(ufmt.Sprintf("canvas#%d", int(c.id)), c.canvas)
	return s
}
