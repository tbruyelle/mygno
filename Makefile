run:
	gnodev -resolver local=/home/tom/src/mygno/r/pixels/ \
		-resolver local=/home/tom/src/mygno/p/svgimg \
		-resolver local=/home/tom/src/mygno/r/home \
		-resolver root=/home/tom/src/gno/examples/

register-user:
	gnokey maketx call -pkgpath "gno.land/r/gnoland/users/v1" -func "Register" -args "tom101" -gas-fee 1000000ugnot -gas-wanted 50000000 -broadcast -chainid "dev" -remote "tcp://127.0.0.1:26657" -send 1000000ugnot g1w3saysjxdlsyczysnyfd55tuvhhz5533nef8y7

create-canvas:
	gnokey maketx call -pkgpath "gno.land/r/tom101/pixels" -func "CreateCanvas" -args "#FDF5E6" -gas-fee 1000000ugnot -gas-wanted 5000000 -broadcast -chainid "dev" -remote "tcp://127.0.0.1:26657" g1w3saysjxdlsyczysnyfd55tuvhhz5533nef8y7

add-pixel:
	gnokey maketx call -pkgpath "gno.land/r/tom101/pixels" -func "AddPixel" -args "1" -args "0" -args "0" -args "blue" -gas-fee 1000000ugnot -gas-wanted 5000000 -broadcast -chainid "dev" -remote "tcp://127.0.0.1:26657" g1w3saysjxdlsyczysnyfd55tuvhhz5533nef8y7
