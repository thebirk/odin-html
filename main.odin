import "core:fmt.odin"
import "core:os.odin"

import "html.odin"

/*

TODO:
 - Add insert ability, html.insert_after(doc, aftert_element, insert_element)
 - Append to lists, must add <li> around the element (append_string, append_element)
 - Switch to using append instead of add?
 - Return validation bool from html.gen

*/

main :: proc() {
	doc := html.make();

	//html.add(doc, html.make_element("not valid"));

	charset := html.make_element("meta");
	charset.attributes["charset"] = "UTF-8";
	html.add(doc.head, charset);

	html.set_lang(doc, "en");
	html.add_title(doc, "This is a title!");
	html.add_css_link(doc, "./main.css");
	html.add_css(doc, "h1 { color: green; }");

	title := html.make_heading("Hello, world!");
	html.add(doc, title);

	sub_title := html.make_heading("Quiter hello world!", 3);
	html.add(doc, sub_title);

	link := html.make_link("Here", "#");
	html.add(doc, link);

	html.add(doc, html.make_br());

	image := html.make_image("Lenna.png", "ooo alt text");
	html.add(doc, image);

	string_list_array := []string {
		"This",
		"is",
		"a",
		"list",
		"!",
	};
	string_list := html.make_list(string_list_array);
	html.add(doc, string_list);

	html.add(doc, html.make_br());

	element_list_array := []^html.Element {
		html.make_paragraph("This"),
		html.make_paragraph("is"),
		html.make_paragraph("another"),
		image,
		html.make_paragraph("list"),
		html.make_paragraph("!"),
	};
	element_list := html.make_list(element_list_array);
	html.add(doc, element_list);

	data := html.gen(doc);
	os.write_entire_file("test.html", data[..]);
}