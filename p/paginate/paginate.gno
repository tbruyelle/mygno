// Minimalistic pagination package that only expects the avl.Tree values to
// implement the LineRenderer interface.
// Pagination is handled thanks to query param ?page=<number> where the number
// is 1-based, and defaults to 1 if not provided.
package paginate

import (
	"net/url"
	"strconv"

	"gno.land/p/demo/avl"
	"gno.land/p/demo/ufmt"
	"gno.land/p/moul/md"
)

type LineRenderer interface {
	// RenderLine should return a line of text that will be rendered in the page.
	// No carriage return will be added at the end of this line, it is up to the
	// implementer to add the carriage returns if needed.
	RenderLine() string
}

func Render(t *avl.Tree, path string, limit int) string {
	if len(path) > 0 && path[0] == '?' {
		path = path[1:]
	}
	v, _ := url.ParseQuery(path)
	var page int
	if s := v.Get("page"); s != "" {
		if i, err := strconv.Atoi(s); err == nil {
			page = i
		}
	}
	if page == 0 {
		page = 1
	}
	total := t.Size()
	if limit == 0 || limit > total {
		limit = total
	}
	var (
		offset = (page - 1) * limit
		s      string
	)
	if offset >= total {
		s += md.Italic("No item found")
	} else {
		t.IterateByOffset(offset, limit, func(_ string, v any) bool {
			s += v.(LineRenderer).RenderLine()
			return false
		})
	}
	// Render page links
	s += "\n\nPages "
	if page > 1 {
		s += md.Link("<", ufmt.Sprintf("?page=%d", page-1))
	} else {
		s += "<"
	}
	totalPages := 1
	if limit > 0 {
		totalPages = (total + limit - 1) / limit
	}
	s += " " + strconv.Itoa(page) + "/" + strconv.Itoa(totalPages) + " "
	if page < totalPages {
		s += md.Link(">", ufmt.Sprintf("?page=%d", page+1))
	} else {
		s += ">"
	}
	s += "\n\n"
	return s
}
