import "core:fmt.odin"
import "core:os.odin"

import "html.odin"

main :: proc() {
	doc := html.make();

	title := html.make_element(name = "p", body = "Hello, world!");
	html.add(doc, title);

	image := html.make_element("img");
	image.attributes["src"] = "Lenna.png";
	html.add(doc, image);

	list := html.make_element("ul");
	html.add(list, html.make_element(name = "li", body = "This"));
	html.add(list, html.make_element(name = "li", body = "a"));
	html.add(list, html.make_element(name = "li", body = "list"));
	html.add(list, html.make_element(name = "li", body = "!"));
	html.add(doc, list);

	data := html.gen(doc);
	os.write_entire_file("test.html", data[..]);
}