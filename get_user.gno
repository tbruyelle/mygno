package main

import (
	"std"

	"gno.land/r/sys/users"
)

func main() {
	u := users.ResolveAddress(std.Address("XXX"))
	println(u.Name(), u.Addr())
}
