import "core:fmt.odin"
import "core:os.odin"

import "html.odin"

main :: proc() {
	doc := html.make();

	title := html.make_element(name = "p", body = "Hello, world!");
	html.add(doc, title);

	image := html.make_image("Lenna.png");
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

	element_list_array := []^Element {
		make_paragraph("This"),
		make_paragraph("is"),
		make_paragraph("another"),
		make_paragraph("list"),
		make_paragraph("!"),
	};
	element_list := html.make_list(element_list_array);
	html.add(doc, element_list);

	link := html.make_link("Here", "#");
	html.add(doc, link);

	data := html.gen(doc);
	os.write_entire_file("test.html", data[..]);
}