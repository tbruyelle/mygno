package bmp

import (
	"bytes"
	"encoding/base64"
	"io"
)

type Pixel [3]uint8

// writeUint16 writes a 16-bit unsigned integer to the file in little-endian format.
func writeUint16(w io.Writer, value uint16) error {
	_, err := w.Write([]byte{byte(value), byte(value >> 8)})
	return err
}

// writeUint32 writes a 32-bit unsigned integer to the file in little-endian format.
func writeUint32(w io.Writer, value uint32) error {
	_, err := w.Write([]byte{byte(value), byte(value >> 8), byte(value >> 16), byte(value >> 24)})
	return err
}

// writeInt32 writes a 32-bit signed integer to the file in little-endian format.
func writeInt32(w io.Writer, value int32) error {
	_, err := w.Write([]byte{byte(value), byte(value >> 8), byte(value >> 16), byte(value >> 24)})
	return err
}

// EncodeBMP encodes a 2D slice of pixels into a BMP file.
func Render(width, height int, pixels [][]Pixel) string {
	if width <= 0 || height <= 0 {
		panic("width and height must be positive")
	}

	// Calculate the size of the image data
	imageSize := uint32(width) * uint32(height) * 3
	fileSize := imageSize + 54 // 54 bytes for the header

	var out bytes.Buffer
	if err := writeUint32(&out, fileSize); err != nil {
		panic(err)
	}
	if err := writeUint32(&out, 0); err != nil { // Reserved
		panic(err)
	}
	if err := writeUint32(&out, 54); err != nil { // Data offset
		panic(err)
	}

	// Write the BMP info header
	if err := writeUint32(&out, 40); err != nil { // Header size
		panic(err)
	}
	if err := writeInt32(&out, int32(width)); err != nil {
		panic(err)
	}
	if err := writeInt32(&out, int32(height)); err != nil {
		panic(err)
	}
	if err := writeUint16(&out, 1); err != nil { // Planes
		panic(err)
	}
	if err := writeUint16(&out, 24); err != nil { // Bit count
		panic(err)
	}
	if err := writeUint32(&out, 0); err != nil { // Compression
		panic(err)
	}
	if err := writeUint32(&out, imageSize); err != nil { // Image size
		panic(err)
	}
	if err := writeInt32(&out, 2835); err != nil { // X pixels per meter
		panic(err)
	}
	if err := writeInt32(&out, 2835); err != nil { // Y pixels per meter
		panic(err)
	}
	if err := writeUint32(&out, 0); err != nil { // Colors used
		panic(err)
	}
	if err := writeUint32(&out, 0); err != nil { // Colors important
		panic(err)
	}

	// Write the pixel data
	padding := (4 - (width*3)%4) % 4
	for row := height - 1; row >= 0; row-- {
		for col := 0; col < width; col++ {
			pixel := pixels[row][col]
			if _, err := out.Write(pixel[:]); err != nil {
				panic(err)
			}
		}
		if padding > 0 {
			paddingBytes := make([]byte, padding)
			if _, err := out.Write(paddingBytes); err != nil {
				panic(err)
			}
		}
	}
	return base64.StdEncoding.EncodeToString(out.Bytes())
}
