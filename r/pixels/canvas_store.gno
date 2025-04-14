package pixels

import (
	"std"

	"gno.land/p/demo/avl"
	"gno.land/p/demo/seqid"
	"gno.land/p/demo/svg"
	"gno.land/p/demo/ufmt"
)

const (
	scale  = 4
	width  = 800
	height = 600
)

type CanvasStore struct {
	seq    seqid.ID
	byID   *avl.Tree
	byAddr *avl.Tree
}

type canvas struct {
	id      seqid.ID
	creator std.Address
	canvas  svg.Canvas
}

func newCanvasStore() *CanvasStore {
	return &CanvasStore{
		byID:   avl.NewTree(),
		byAddr: avl.NewTree(),
	}
}

func (cs *CanvasStore) add(creator std.Address, fillColor string) seqid.ID {
	// TODO use binary or base32 with String()?
	id := canvasStore.seq.Next()
	c := canvas{
		id:      id,
		creator: creator,
		canvas: svg.Canvas{
			Width:  width,
			Height: height,
		},
	}
	if fillColor != "" {
		c.canvas.DrawRectangle(0, 0, width, height, fillColor)
	}
	// add to canvasById
	canvasStore.byID.Set(id.Binary(), c)
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

func (cs *CanvasStore) delete(caller std.Address, id seqid.ID) {
	idsi, ok := canvasStore.byAddr.Get(caller.String())
	if ok {
		ids := idsi.([]seqid.ID)
		for i := range ids {
			if ids[i] == id {
				canvasStore.byID.Remove(id.Binary())
				ids = append(ids[:i], ids[i+1:]...)
				canvasStore.byAddr.Set(caller.String(), ids)
				return
			}
		}
	}
	panic(ufmt.Sprintf("canvas %d not found or not created by %s ", id, caller.String()))
}

func (cs *CanvasStore) get(id seqid.ID) canvas {
	c, ok := canvasStore.byID.Get(id.Binary())
	if !ok {
		panic(ufmt.Sprintf("canvas does not exist for id %d", id))
	}
	return c.(canvas)
}

func (cs *CanvasStore) addPixel(id seqid.ID, x, y int, color string) {
	c := cs.get(id)
	x *= scale
	y *= scale
	if x < 0 || x > c.canvas.Width || y < 0 || y >= c.canvas.Height {
		panic("x or y out of range")
	}
	c.canvas.DrawRectangle(x, y, scale, scale, color)
	canvasStore.byID.Set(id.Binary(), c)
}
