/*
Copyright (C) - Aleksander B. Birkeland 2018

Very basic HTML generator
TODO(Some way to generate xml instead of html)

Closes all tags including empty ones

*/

Document :: struct {
	doctype: string, // <!DOCTYPE <insert variable here> >
	head: ^Element,
	body: ^Element,
}

Element :: struct {
	name: string,
	body: string,
	attributes: map[string]string,
	children: [dynamic]^Element,
}

make :: proc(_doctype: string = "html") -> ^Document {
	using d := new(Document);
	doctype = _doctype;

	head = new(Element);
	head.name = "head";

	body = new(Element);
	body.name = "body";

	return d;
}

make_element :: proc(name: string, body := "") -> ^Element {
	el := new(Element);

	el.name = name;
	el.body = body;

	return el;
}

add_to_document :: proc(using doc: ^Document, child: ^Element) {
	append(&body.children, child);
}

add_to_element :: proc(using parent: ^Element, child: ^Element) {
	append(&parent.children, child);
}

add :: proc[
	add_to_document,
	add_to_element,
];

gen_element :: proc(out: ^[dynamic]u8, using el: ^Element) {
	append_string(out, "<");
	append_string(out, name);
	if len(attributes) > 0 do append_string(out, " ");
	for key,value in attributes {
		append_string(out, key);
		append_string(out, "=\"");
		append_string(out, value);
		append_string(out, "\"");
	}
	append_string(out, ">\n");

	append_string(out, body);

	for i := 0; i < len(children); i += 1 {
		child := children[i];
		gen_element(out, child);
	}

	append_string(out, "\n</");
	append_string(out, name);
	append_string(out, ">\n");
}

gen :: proc(using doc: ^Document, gen_whitespace := true) -> [dynamic]u8 {
	out: [dynamic]u8;

	append_string(&out, "<!DOCTYPE ");
	append_string(&out, doctype);
	append_string(&out, ">\n");

	append_string(&out, "<html>\n");

	gen_element(&out, head);
	gen_element(&out, body);

	append_string(&out, "</html>");

	return out;
}