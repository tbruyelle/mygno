package main

import (
	"std"

	"gno.land/r/sys/users"
)

// gnokey maketx run -gas-fee 1000000ugnot -gas-wanted 90000000 -broadcast -chainid "staging" -remote "https://rpc.gno.land" XXX get_user.gno
func main() {
	u := users.ResolveAddress(std.Address("XXX"))
	println(u.Name(), u.Addr())
}
