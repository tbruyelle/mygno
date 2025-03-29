package home

import (
	"time"

	"gno.land/p/moul/md"
	"gno.land/r/leon/hof"
)

var creation time.Time

func init() {
	creation = time.Now()
	hof.Register("Tom's Home Realm", "")
}

func Render(path string) string {
	content := md.H1("Tom's Home")
	content += md.Paragraph("Hello there, I'm Tom, a blockchain engineer at All-In-Bits.")
	content += md.H3("Contributions")
	content += md.BulletList(
		[]string{
			md.Link("Emeris", "https://github.com/EmerisHQ"),
			md.Link("Starport/Ignite", "https://github.com/ignite/cli"),
			md.Link("Gno", "https://github.com/gnolang/gno/issues?q=sort:updated-desc+author:tbruyelle"),
			md.Link("Decentralists", "https://github.com/decentralists"),
			md.Link("AtomOne", "https://github.com/atomone-hub"),
		})
	content += md.H3("Contact")
	content += md.BulletList(
		[]string{
			md.Link("GitHub", "https://github.com//tbruyelle"),
		})

	return content
}
