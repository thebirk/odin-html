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

	head = make_element("head", " ");
	body = make_element("body", " ");

	return d;
}

make_element :: proc(name: string, body := "") -> ^Element {
	el := new(Element);

	el.name = name;
	el.body = body;

	return el;
}

make_paragraph :: proc(text: string) -> ^Element {
	el := new(Element);

	el.name = "p";
	el.body = text;

	return el;
}

_br_element := Element{name = "br"};
br :: proc() -> ^Element {
	return &_br_element;
}

make_list_from_elements :: proc(data: []^Element) -> ^Element {
	el := new(Element);

	el.name = "ul";
	for child in data {
		item := make_element("li");
		add(item, child);
		add(el, item);
	}

	return el;
}

make_list_from_array :: proc(data: []string) -> ^Element {
	el := new(Element);

	el.name = "ul";
	for str in data {
		add(el, make_element(name = "li", body = str));
	}

	return el;
}

make_list :: proc[
	make_list_from_array,
	make_list_from_elements,
];

make_link :: proc(text: string, link: string) -> ^Element {
	el := new(Element);

	el.name = "a";
	el.attributes["href"] = link;
	el.body = text;

	return el;
}

make_image :: proc(src: string) -> ^Element {
	el := new(Element);

	el.name = "img";
	el.attributes["src"] = src;

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

append_string_indented :: proc(using options: GenOptions, text: string) {
	if gen_indentation do for i in 0..indent {
		append_string(out, "\t");
	}
	append_string(out, text);
}

gen_element :: proc(using options: GenOptions, using el: ^Element) {
	append_string_indented(options, "<");
	append_string(out, name);
	for key,value in attributes {
		append_string(out, " ");
		append_string(out, key);
		append_string(out, "=\"");
		append_string(out, value);
		append_string(out, "\"");
	}

	if (body == "" || body == " ") && len(children) == 0 {
		append_string(out, "/>");
		if gen_whitespace do append_string(out, "\n");
	} else {
		append_string(out, ">");
		if gen_whitespace do append_string(out, "\n");
		
		indent += 1;
		if body != "" && body != " " {
			append_string_indented(options, body);
			if gen_whitespace do append_string(out, "\n");
		}

		if len(children) > 0 {
			for i := 0; i < len(children); i += 1 {
				child := children[i];
				gen_element(options, child);
			}
		}
		indent -= 1;

		append_string_indented(options, "</");
		append_string(out, name);
		append_string(out, ">");
		if gen_whitespace do append_string(out, "\n");
	}
}

GenOptions :: struct {
	out: ^[dynamic]u8,
	gen_whitespace: bool,
	gen_indentation: bool,
	indent: int = 0,
}

gen :: proc(using doc: ^Document, _gen_whitespace := true, _gen_indentation := true) -> [dynamic]u8 {
	out_buffer: [dynamic]u8;
	using options := GenOptions {
		out = &out_buffer,
		gen_whitespace = _gen_whitespace,
		gen_indentation = _gen_indentation,
	};

	append_string(out, "<!DOCTYPE ");
	append_string(out, doctype);
	append_string(out, ">");
	if gen_whitespace do append_string(out, "\n");

	append_string(out, "<html>");
	if gen_whitespace do append_string(out, "\n");

	indent += 1;
	gen_element(options, head);
	gen_element(options, body);
	indent -= 1;

	append_string(out, "</html>");

	return out_buffer;
}