// Draw input image to `/r/tom101/pixels`
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
	"regexp"
	"strconv"
	"strings"

	"golang.org/x/crypto/ssh/terminal"
)

func usage() {
	fmt.Fprintf(os.Stderr, "Usage: draw <id> <image>\n")
}

// gno-logo.png (28x47) dx=80 dy=30
// arm.png      (32x38) dx=50 dy=50
// arm2.png     (32x38) dx=50+32+24=106 dy=50

func main() {
	var (
		fs         = flag.NewFlagSet("draw", flag.ContinueOnError)
		dx         = fs.Int("dx", 0, "x offset")
		dy         = fs.Int("dy", 0, "y offset")
		addr       = fs.String("addr", "g1w3saysjxdlsyczysnyfd55tuvhhz5533nef8y7", "signer address")
		startGas   = fs.Float64("start-gas", 3500000, "gas wanted for first tx")
		startPixel = fs.Int("start-pixel", 0, "send tx after specified pixel")
	)

	if err := fs.Parse(os.Args[1:]); err != nil {
		usage()
		log.Fatalf("flag error: %s", err)
	}
	if fs.NArg() != 2 {
		usage()
		log.Fatalf("invalid args")
	}

	id := fs.Arg(0)
	if _, err := strconv.Atoi(id); err != nil {
		usage()
		log.Fatalf("%s is not an int", fs.Arg(0))
	}
	f, err := os.Open(fs.Arg(1))
	if err != nil {
		log.Fatalf("%s could not be opened", fs.Arg(1))
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
	var (
		pwd       = string(bz)
		gasWanted = *startGas
		totalFee  int64
	)
	for i, p := range pixels {
		if *startPixel > i {
			continue
		}
		// gas-price is 0.001 but a small extra of 0.0001 is needed
		gasFee := int(gasWanted * .0011)
		totalFee += int64(gasFee)
		cmd := exec.Command("gnokey", "maketx", "call",
			"-pkgpath", "gno.land/r/tom101/pixels",
			"-func", "AddPixel",
			"-args", id,
			"-args", fmt.Sprint(p.x+*dx),
			"-args", fmt.Sprint(p.y+*dy),
			"-args", p.color,
			"-insecure-password-stdin=true",
			"-gas-fee", fmt.Sprintf("%dugnot", gasFee),
			"-gas-wanted", fmt.Sprintf("%.f", gasWanted),
			"-broadcast", "-chainid", "dev", "-remote", "tcp://127.0.0.1:26657",
			"-simulate", "skip",
			*addr,
		)
		cmd.Stdin = strings.NewReader(pwd + "\n")
		out, err := cmd.CombinedOutput()
		if err != nil {
			log.Fatalf("error exec cmd %s %+v", string(out), err)
		}
		// parse gas used and apply inc gas factor on this
		gasUsed := parseGasUsed(string(out), gasWanted)
		fmt.Println(string(out))
		fmt.Printf("TX %d passed, Fees consumed %dugnot\n", i, totalFee)

		// inc gasWanted by 5%
		gasWanted = gasUsed * 1.05
	}
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

var re = regexp.MustCompile(`GAS USED:\s+(\d+)`)

func parseGasUsed(s string, def float64) float64 {
	match := re.FindStringSubmatch(s)
	if len(match) > 1 {
		gasUsed, err := strconv.ParseFloat(match[1], 64)
		if err != nil {
			fmt.Println("Error converting GAS USED value to integer:", err)
			return def
		}
		return gasUsed
	}
	fmt.Println("GAS USED value not found")
	return def
}
