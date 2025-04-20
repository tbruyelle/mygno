package paginate

import (
	"strconv"
	"testing"

	"gno.land/p/demo/avl"
	"gno.land/p/demo/ufmt"
)

type item struct {
	line string
}

// implements LineRenderer
func (i item) RenderLine() string {
	return i.line
}

func TestRender(t *testing.T) {
	tree := avl.NewTree()
	for i := 0; i < 10; i++ {
		is := strconv.Itoa(i)
		tree.Set(is, &item{is})
	}
	tests := []struct {
		path     string
		limit    int
		expected string
	}{
		{
			path:     "",
			limit:    0,
			expected: "0123456789\n\nPages < 1/1 >\n\n",
		},
		{
			path:     "",
			limit:    5,
			expected: "01234\n\nPages < 1/2 [\\>](?page=2)\n\n",
		},
		{
			path:     "?page=1",
			limit:    5,
			expected: "01234\n\nPages < 1/2 [\\>](?page=2)\n\n",
		},
		{
			path:     "?page=2",
			limit:    5,
			expected: "56789\n\nPages [<](?page=1) 2/2 >\n\n",
		},
		{
			path:     "?page=2",
			limit:    2,
			expected: "23\n\nPages [<](?page=1) 2/5 [\\>](?page=3)\n\n",
		},
		{
			path:     "?page=3",
			limit:    5,
			expected: "*No item found*\n\nPages [<](?page=2) 3/2 >\n\n",
		},
		{
			path:     "?page=1",
			limit:    10,
			expected: "0123456789\n\nPages < 1/1 >\n\n",
		},
		{
			path:     "?page=1",
			limit:    15,
			expected: "0123456789\n\nPages < 1/1 >\n\n",
		},
		{
			path:     "?page=1",
			limit:    8,
			expected: "01234567\n\nPages < 1/2 [\\>](?page=2)\n\n",
		},
	}
	for i, tt := range tests {
		t.Run(ufmt.Sprintf("case %d path=%s limit=%d", i, tt.path, tt.limit), func(t *testing.T) {
			out := Render(tree, tt.path, tt.limit)
			if out != tt.expected {
				t.Errorf("expected %q got %q", tt.expected, out)
			}
		})
	}
}
