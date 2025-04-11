package home

import (
	"time"

	"gno.land/p/moul/md"
	"gno.land/r/leon/hof"
	"gno.land/r/tom101/pixels"
)

var creation time.Time

func init() {
	creation = time.Now()
	hof.Register("Tom's Home Realm", "")
}

func Render(path string) string {
	content := md.H1("Tom's Home")
	content += md.Paragraph("Hello there, I'm Tom, a blockchain engineer at All-In-Bits. Working on improving our future with decentralization!")
	content += md.H2("Contributions")
	content += md.BulletList(
		[]string{
			md.Link("Emeris", "https://github.com/EmerisHQ"),
			md.Link("Starport/Ignite", "https://github.com/ignite/cli/issues?q=sort:updated-desc+author:tbruyelle"),
			md.Link("Gno", "https://github.com/gnolang/gno/issues?q=sort:updated-desc+author:tbruyelle"),
			md.Link("Decentralists", "https://github.com/decentralists"),
			md.Link("Cosmos-SDK", "https://github.com/cosmos/cosmos-sdk/issues?q=sort:updated-desc+author:tbruyelle"),
			md.Link("Interchain-Security", "https://github.com/cosmos/interchain-security/issues?q=sort:updated-desc+author:tbruyelle"),
			md.Link("IBC-go", "https://github.com/cosmos/ibc-go/issues?q=sort:updated-desc+author:tbruyelle"),
			md.Link("AtomOne", "https://github.com/atomone-hub/atomone/issues?q=sort:updated-desc+author:tbruyelle"),
		})
	content += md.H2("Realms & Packages")
	content += md.BulletList(
		[]string{
			"[`/r/tom101/pixels`](/r/tom101/pixels): A gno implementation of the r/places subreddit.\n\nClick on the following link to contribute: " + pixels.RenderCanvas("1"),
			"[`/p/tom101/svgimg`](/p/tom101/svgimg): A hack to display canvas from `/p/demo/svg` in gnoweb",
		})
	content += md.H2("Contact")
	content += md.BulletList(
		[]string{
			"Gno address: g1w3saysjxdlsyczysnyfd55tuvhhz5533nef8y7",
			md.Link("GitHub", "https://github.com//tbruyelle"),
		})

	return content
}
