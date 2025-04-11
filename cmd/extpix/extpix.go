// Pixel extractor from input image to submit on `/r/tom101/pixels`
package main

import (
	"flag"
	"fmt"
	"image"
	_ "image/jpeg"
	_ "image/png"
	"io"
	"log"
	"os"
	"os/exec"
	"strings"

	"golang.org/x/crypto/ssh/terminal"
)

func main() {
	fs := flag.NewFlagSet("extpix", flag.ContinueOnError)
	if err := fs.Parse(os.Args[1:]); err != nil {
		log.Fatalf("flag error: %s", err)
	}
	f, err := os.Open(fs.Arg(0))
	if err != nil {
		log.Fatalf("%s could not be opened", os.Args[1])
	}
	defer f.Close()

	pixels, err := getPixels(f)
	if err != nil {
		log.Fatalf("getPixels error: %w", err)
	}
	// prompt for password
	fmt.Println("Enter password: ")
	bz, err := terminal.ReadPassword(0)
	if err != nil {
		log.Fatalf("err read password: %v", err)
	}
	pwd := string(bz)

	var (
		id   = "6"
		addr = "g1w3saysjxdlsyczysnyfd55tuvhhz5533nef8y7"
	)
	for i, p := range pixels {
		// if i < 387 {
		// continue
		// }
		cmd := exec.Command("gnokey", "maketx", "call",
			"-pkgpath", "gno.land/r/tom101/pixels",
			"-func", "AddPixel",
			"-args", id,
			"-args", fmt.Sprint(p.x+80),
			"-args", fmt.Sprint(p.y+30),
			"-args", p.color,
			"-insecure-password-stdin=true",
			// "-gas-fee", "1000000ugnot", "-gas-wanted", "5000000", "-broadcast",
			// TODO increase gas-wanted by 0.005% after each call to handle increase canvas size
			"-gas-fee", "2000000ugnot", "-gas-wanted", "100000000", "-broadcast",
			"-chainid", "dev", "-remote", "tcp://127.0.0.1:26657", addr,
		)
		cmd.Stdin = strings.NewReader(pwd + "\n")
		out, err := cmd.CombinedOutput()
		if err != nil {
			log.Fatalf("error exec cmd %s %+v", string(out), err)
		}
		fmt.Println(string(out))
		fmt.Printf("TX %d passed\n", i)
	}
	fmt.Println(len(pixels), "tx passed")
}

// Get the bi-dimensional pixel array
func getPixels(file io.Reader) ([]pixel, error) {
	img, _, err := image.Decode(file)
	if err != nil {
		return nil, err
	}

	bounds := img.Bounds()
	width, height := bounds.Max.X, bounds.Max.Y

	var pixels []pixel
	for y := 0; y < height; y++ {
		for x := 0; x < width; x++ {
			if c := color(img.At(x, y).RGBA()); c != "" {
				pixels = append(pixels, pixel{x: x, y: y, color: c})
			}
		}
	}
	return pixels, nil
}

// img.At(x, y).RGBA() returns four uint32 values; we want a Pixel
func color(r uint32, g uint32, b uint32, a uint32) string {
	if a != 65535 {
		// ignore any transparent pixels
		return ""
	}
	return fmt.Sprintf("rgb(%d,%d,%d)", int(r/257), int(g/257), int(b/257))
}

// pixel struct example
type pixel struct {
	x     int
	y     int
	color string
}
