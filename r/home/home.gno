package home

import (
	"std"
	"time"

	"gno.land/p/moul/md"
	"gno.land/r/leon/hor"
	"gno.land/r/tom101/pixels"
)

var (
	admin               = std.Address("g1w3saysjxdlsyczysnyfd55tuvhhz5533nef8y7")
	creation            time.Time
	additionGnoContribs []string
)

func init() {
	creation = time.Now()
	hor.Register("Tom's Home Realm", "")
}

func AddGnoContrib(gnoContrib string) {
	if std.OriginCaller() != admin {
		panic("restricted area")
	}
	additionGnoContribs = append(additionGnoContribs, gnoContrib)
}

// TODO put each section in store, fill them in init and add tx to update them
func Render(path string) string {
	s := md.H1("Tom's Home")
	s += md.Paragraph("Hello there, I'm Tom, a blockchain engineer at All-In-Bits. Working on improving our future with decentralization!")
	s += md.H2("Some contributions")
	s += md.BulletList(
		[]string{
			md.Link("AtomOne", "https://github.com/atomone-hub/atomone/issues?q=sort:updated-desc+author:tbruyelle"),
			md.Link("Gno", "https://github.com/gnolang/gno/issues?q=sort:updated-desc+author:tbruyelle"),
			md.Link("Cosmos-SDK", "https://github.com/cosmos/cosmos-sdk/issues?q=sort:updated-desc+author:tbruyelle"),
			md.Link("Interchain-Security", "https://github.com/cosmos/interchain-security/issues?q=sort:updated-desc+author:tbruyelle"),
			md.Link("IBC-go", "https://github.com/cosmos/ibc-go/issues?q=sort:updated-desc+author:tbruyelle"),
			md.Link("Starport/Ignite", "https://github.com/ignite/cli/issues?q=sort:updated-desc+author:tbruyelle"),
		})
	s += md.H2("Realms & Packages")
	s += md.BulletList(
		append(
			[]string{
				"[`/r/tom101/pixels`](/r/tom101/pixels): A gno implementation of the [r/place](https://reddit.com/r/place) subreddit.\n\nDont hesitate to contribue! " + pixels.RenderCanvas(1),
				"[`/p/tom101/svgimg`](/p/tom101/svgimg): A hack to display canvas from `/p/demo/svg` in gnoweb.",
			},
			additionGnoContribs...),
	)
	s += md.H2("Contact")
	s += md.BulletList(
		[]string{
			"Gno address: " + admin.String(),
			md.Link("GitHub", "https://github.com//tbruyelle"),
		})

	return s
}
