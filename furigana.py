#!/usr/bin/env python

from pandocfilters import toJSONFilter, RawInline


def behead(key, value, format, meta):
	if format == 'epub' and key == 'Link' and value[2][0][0] == '-':
		if value[1][0]['t'] == 'Quoted':
			return RawInline('html', "\"<ruby>"+ value[1][0]['c'][1][0]['c'] + "<rp>(</rp><rt>"+value[2][0][1:]+"</rt><rp>)</rp></ruby>\"")
		return RawInline('html',"<ruby>"+ value[1][0]['c'] +"<rp>(</rp><rt>"+value[2][0][1:]+"</rt><rp>)</rp></ruby>")

if __name__ == "__main__":
	toJSONFilter(behead)
