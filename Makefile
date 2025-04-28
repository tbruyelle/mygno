run:
	gnodev -resolver local=/home/tom/src/mygno/r/pixels/ \
		-resolver local=/home/tom/src/mygno/p/svgimg \
		-resolver local=/home/tom/src/mygno/p/paginate \
		-resolver local=/home/tom/src/mygno/r/home \
		-resolver root=/home/tom/src/gno/examples/

register-user:
	gnokey maketx call -pkgpath "gno.land/r/gnoland/users/v1" -func "Register" -args "tom101" -gas-fee 15000ugnot -gas-wanted 15000000 -broadcast -chainid "dev" -remote "tcp://127.0.0.1:26657" -send 1000000ugnot g1w3saysjxdlsyczysnyfd55tuvhhz5533nef8y7

create-canvas:
	# example color #FDF5E6
	gnokey maketx call -pkgpath "gno.land/r/tom101/pixels" -func "CreateCanvas" -args "$(color)" -gas-fee 8000ugnot -gas-wanted 8000000 -broadcast -chainid "dev" -remote "tcp://127.0.0.1:26657" g1w3saysjxdlsyczysnyfd55tuvhhz5533nef8y7

add-pixel:
	gnokey maketx call -pkgpath "gno.land/r/tom101/pixels" -func "AddPixel" -args "$(id)" -args "$(x)" -args "$(y)" -args "$(color)" -gas-fee 10000ugnot -gas-wanted 10000000 -broadcast -chainid "dev" -remote "tcp://127.0.0.1:26657" g1w3saysjxdlsyczysnyfd55tuvhhz5533nef8y7
