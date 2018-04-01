/*
Copyright (C) - Aleksander B. Birkeland 2018

Very basic HTML generator
TODO(Some way to generate xml instead of html)

Weird quirks:
	- Bodies with a value of only "" and " " are considered and empty body.

*/
import "core:fmt.odin"
import "core:strings.odin"

Document :: struct {
	doctype: string, // <!DOCTYPE <insert variable here> >
	html_attributes: map[string]string,
	head: ^Element,
	body: ^Element,
}

Element :: struct {
	name: string,
	body: string,
	attributes: map[string]string,
	children: [dynamic]^Element,
}

set_lang :: proc(doc: ^Document, lang: string) {
	doc.html_attributes["lang"] = lang;
}

set_id :: proc(using el: ^Element, id: string) {
	attributes["id"] = id;
}

set_class :: proc(using el: ^Element, class: string) {
	attributes["class"] = class;
}

add_charset :: proc(doc: ^Document, charset: string = "UTF-8") -> ^Element {
	el := make_element("meta");
	el.attributes["charset"] = charset;
	add(doc.head, el);
	return el;
}

add_title :: proc(doc: ^Document, title: string) -> ^Element {
	el := make_element("title", title);
	add(doc.head, el);
	return el;
}

add_css :: proc(doc: ^Document, css: string) -> ^Element {
	el := make_element("style", css);
	add(doc.head, el);
	return el;
}

add_css_link :: proc(doc: ^Document, path: string) -> ^Element {
	el := make_element("link");
	el.attributes["rel"] = "stylesheet";
	el.attributes["type"] = "text/css";
	el.attributes["href"] = path;
	add(doc.head, el);
	return el;
}

make_document :: proc(_doctype: string = "html") -> ^Document {
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

make_heading :: proc(text: string, level := 1) -> ^Element {
	#assert(level >= 1 && level <= 6);
	el := new(Element);

	el.name = fmt.aprintf("h%v", level);
	el.body = text;

	return el;
}

make_paragraph :: proc(text: string) -> ^Element {
	el := new(Element);

	el.name = "p";
	el.body = text;

	return el;
}

make_br :: proc() -> ^Element {
	return make_element("br");
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
		li := make_element("li");
		add(li, make_paragraph(str));
		add(el, li);
	}

	return el;
}

make_list :: proc[
	make_list_from_array,
	make_list_from_elements,
];

append_string_to_list :: proc(using list: ^Element, str: string) {
	li := make_element(name = "li");
	add(li, make_paragraph(str));
	add(list, li);
}

append_element_to_list :: proc(using list: ^Element, el: ^Element) {
	li := make_element("li");
	add(li, el);
	add(list, li);
}

append_to_list :: proc[
	append_element_to_list,
	append_string_to_list,
];

make_link :: proc(text: string, link: string) -> ^Element {
	el := new(Element);

	el.name = "a";
	el.attributes["href"] = link;
	el.body = text;

	return el;
}

make_image :: proc(src: string, alt: string = "") -> ^Element {
	el := new(Element);

	el.name = "img";
	el.attributes["src"] = src;
	el.attributes["alt"] = alt;
	el.attributes["title"] = alt;

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
		append_string(out, indent_string);
	}
	append_string(out, text);
}

validate_element :: proc(using el: ^Element) -> bool {
	for r in name {
		if r >= '0' && r <= '9' do continue;
		if r >= 'a' && r <= 'z' do continue;
		if r >= 'A' && r <= 'Z' do continue;

		fmt.printf("Element names should only contain 0-9,a-z,A-Z found '%v'! Element name: '%s'\n", r, name);
		return false;
	}

	// check case-insensitive match with attributes
	// http://w3c.github.io/html-reference/syntax.html#tag-name

	return true;
}

gen_element :: proc(using options: GenOptions, using el: ^Element) -> bool {
	if validate_element(el) == false do return false;

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

	return true;
}

GenOptions :: struct {
	out: ^[dynamic]u8,
	gen_whitespace: bool,
	gen_indentation: bool,
	indent: int = 0,
	indent_string: string,
}

gen :: proc(using doc: ^Document, _gen_whitespace := true, _gen_indentation := true, _indent_string: string = "\t") -> [dynamic]u8 {
	out_buffer: [dynamic]u8;
	using options := GenOptions {
		out = &out_buffer,
		gen_whitespace = _gen_whitespace,
		gen_indentation = _gen_indentation,
		indent_string = _indent_string,
	};

	append_string(out, "<!DOCTYPE ");
	append_string(out, doctype);
	append_string(out, ">");
	if gen_whitespace do append_string(out, "\n");

	append_string(out, "<html");
	for key,value in html_attributes {
		append_string(out, " ");
		append_string(out, key);
		append_string(out, "=\"");
		append_string(out, value);
		append_string(out, "\"");
	}
	append_string(out, ">");
	if gen_whitespace do append_string(out, "\n");

	indent += 1;
	gen_element(options, head);
	gen_element(options, body);
	indent -= 1;

	append_string(out, "</html>");

	return out_buffer;
}