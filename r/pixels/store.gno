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
	seq    seqid.ID
	byID   *avl.Tree // *avl.Tree[CanvasID]Canvas
	byAddr *avl.Tree // *avl.Tree[std.Address][]CanvasID
}

type Canvas struct {
	id        seqid.ID
	creator   std.Address
	width     int
	height    int
	fillColor string
	pixels    []pixel
}

type pixel struct {
	x, y  int
	color string
}

func newCanvasStore() *CanvasStore {
	return &CanvasStore{
		byID:   avl.NewTree(),
		byAddr: avl.NewTree(),
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
	// add to canvasById
	canvasStore.byID.Set(id.String(), c)
	// add to canvasBy.Adr
	idsi, ok := canvasStore.byAddr.Get(creator.String())
	if ok {
		ids := idsi.([]seqid.ID)
		ids = append(ids, id)
		canvasStore.byAddr.Set(creator.String(), ids)
	} else {
		canvasStore.byAddr.Set(creator.String(), []seqid.ID{id})
	}
	return id
}

func (cs *CanvasStore) Delete(caller std.Address, id seqid.ID) {
	idsi, ok := canvasStore.byAddr.Get(caller.String())
	if ok {
		ids := idsi.([]seqid.ID)
		for i := range ids {
			if ids[i] == id {
				canvasStore.byID.Remove(id.String())
				ids = append(ids[:i], ids[i+1:]...)
				canvasStore.byAddr.Set(caller.String(), ids)
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
	c.pixels = append(c.pixels, pixel{x, y, color})
	canvasStore.byID.Set(id.String(), c)
}
