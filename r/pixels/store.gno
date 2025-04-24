package pixels

import (
	"std"

	"gno.land/p/demo/avl"
	"gno.land/p/demo/seqid"
	"gno.land/p/demo/ufmt"
)

const (
	scale  = 4
	width  = 800
	height = 600
)

type CanvasStore struct {
	seq         seqid.ID
	byID        *avl.Tree // *avl.Tree[seqid.ID]Canvas
	byAddr      *avl.Tree // *avl.Tree[std.Address][]seqid.ID
	byNumPixels *avl.Tree //*avl.Tree[numPixels:seqid.ID]CanvasID
}

type CanvasID seqid.ID

// RenderLine implements p/tom101/paginate.LineRenderer
func (id CanvasID) RenderLine() string {
	c := canvasStore.MustGet(seqid.ID(id))
	return c.RenderLine()
}

type Canvas struct {
	id        seqid.ID
	creator   std.Address
	width     int
	height    int
	fillColor string
	pixels    []pixel
}

// RenderLine implements p/tom101/paginate.LineRenderer
func (c Canvas) RenderLine() string {
	return renderCanvas(c, true)
}

type pixel struct {
	x, y  int
	color string
}

func newCanvasStore() *CanvasStore {
	return &CanvasStore{
		byID:        avl.NewTree(),
		byAddr:      avl.NewTree(),
		byNumPixels: avl.NewTree(),
	}
}

func (cs *CanvasStore) Add(creator std.Address, fillColor string) seqid.ID {
	id := canvasStore.seq.Next()
	c := Canvas{
		id:        id,
		creator:   creator,
		width:     width,
		height:    height,
		fillColor: fillColor,
		pixels:    []pixel{},
	}
	// add to ByID
	canvasStore.byID.Set(id.String(), c)
	// add to ByAddr
	idsi, ok := canvasStore.byAddr.Get(creator.String())
	if ok {
		ids := idsi.([]seqid.ID)
		ids = append(ids, id)
		canvasStore.byAddr.Set(creator.String(), ids)
	} else {
		canvasStore.byAddr.Set(creator.String(), []seqid.ID{id})
	}
	// add to ByNumPixels
	canvasStore.byNumPixels.Set(getNumPixelsKey(c), CanvasID(id))
	return id
}

func (cs *CanvasStore) Delete(caller std.Address, id seqid.ID) {
	idsi, ok := canvasStore.byAddr.Get(caller.String())
	if ok {
		ids := idsi.([]seqid.ID)
		for i := range ids {
			if ids[i] == id {
				c := cs.MustGet(id)
				canvasStore.byID.Remove(id.String())
				ids = append(ids[:i], ids[i+1:]...)
				canvasStore.byAddr.Set(caller.String(), ids)
				canvasStore.byNumPixels.Remove(getNumPixelsKey(c))
				return
			}
		}
	}
	panic(ufmt.Sprintf("canvas %d not found or not created by %s ", id, caller.String()))
}

func (cs *CanvasStore) Get(id seqid.ID) (Canvas, bool) {
	c, ok := canvasStore.byID.Get(id.String())
	if !ok {
		return Canvas{}, false
	}
	return c.(Canvas), true
}

func (cs *CanvasStore) MustGet(id seqid.ID) Canvas {
	c, ok := canvasStore.Get(id)
	if !ok {
		panic(ufmt.Sprintf("canvas does not exist for id %d", id))
	}
	return c
}

func (cs *CanvasStore) AddPixel(id seqid.ID, x, y int, color string) {
	c := cs.MustGet(id)
	x *= scale
	y *= scale
	if x < 0 || x > c.width || y < 0 || y >= c.height {
		panic("x or y out of range")
	}
	canvasStore.byNumPixels.Remove(getNumPixelsKey(c))
	c.pixels = append(c.pixels, pixel{x, y, color})
	canvasStore.byNumPixels.Set(getNumPixelsKey(c), CanvasID(id))
	canvasStore.byID.Set(id.String(), c)
}

func getNumPixelsKey(c Canvas) string {
	// numPixels := strconv.Itoa(len(c.pixels))
	// paddedNumPixels := strings.Repeat("0", 10-len(numPixels)) + numPixels
	return seqid.ID(len(c.pixels)).String() + ":" + c.id.String()
}
