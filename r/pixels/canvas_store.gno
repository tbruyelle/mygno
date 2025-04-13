package pixels

import (
	"std"
	"strconv"

	"gno.land/p/demo/avl"
	"gno.land/p/demo/svg"
)

const (
	scale  = 4
	width  = 800
	height = 600
)

type CanvasStore struct {
	seq    int
	byID   *avl.Tree
	byAddr *avl.Tree
}

type canvas struct {
	id      string
	creator std.Address
	canvas  svg.Canvas
}

func newCanvasStore() *CanvasStore {
	return &CanvasStore{
		seq:    0,
		byID:   avl.NewTree(),
		byAddr: avl.NewTree(),
	}
}

func (cs *CanvasStore) add(creator std.Address, fillColor string) string {
	canvasStore.seq++
	sid := strconv.Itoa(canvasStore.seq)

	c := canvas{
		id:      sid,
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
	canvasStore.byID.Set(sid, c)
	// add to canvasBy.Adr
	idsi, ok := canvasStore.byAddr.Get(creator.String())
	if ok {
		ids := idsi.([]string)
		ids = append(ids, sid)
		canvasStore.byAddr.Set(creator.String(), ids)
	} else {
		canvasStore.byAddr.Set(creator.String(), []string{sid})
	}
	return sid
}

func (cs *CanvasStore) delete(caller std.Address, id string) {
	idsi, ok := canvasStore.byAddr.Get(caller.String())
	if ok {
		ids := idsi.([]string)
		for i := range ids {
			if ids[i] == id {
				canvasStore.byID.Remove(id)
				ids = append(ids[:i], ids[i+1:]...)
				canvasStore.byAddr.Set(caller.String(), ids)
				return
			}
		}
	}
	panic("canvas " + id + "not found or not created by " + caller.String())
}

func (cs *CanvasStore) get(id string) canvas {
	c, ok := canvasStore.byID.Get(id)
	if !ok {
		panic("canvas does not exist for id: " + id)
	}
	return c.(canvas)
}

func (cs *CanvasStore) addPixel(id string, x, y int, color string) {
	c := cs.get(id)
	x *= scale
	y *= scale
	if x < 0 || x > c.canvas.Width || y < 0 || y >= c.canvas.Height {
		panic("x or y out of range")
	}
	c.canvas.DrawRectangle(x, y, scale, scale, color)
	canvasStore.byID.Set(id, c)
}
