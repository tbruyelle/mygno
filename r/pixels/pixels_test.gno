package pixels

import "testing"

func TestPixels(t *testing.T) {
	id := CreateCanvas("blue")
	if id!=1{
		t.Errorf("Expected 1, got %d",id)
	}
}
