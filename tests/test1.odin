import "core:os.odin"

import "../html.odin"

Post :: struct {
	element: ^html.Element,
	title: ^html.Element,
	author: ^html.Element,
	body: ^html.Element,
}

make_post :: proc(title_text: string, author_text: string, body_text: string) -> Post {
	using post: Post;
	element = html.make_element("div");
	html.set_class(element, "post");

	title = html.make_heading(title_text, 2);
	html.add(element, title);

	author = html.make_heading(author_text, 4);
	html.add(element, author);

	html.add(element, html.make_element("hr"));

	body = html.make_paragraph(body_text);
	html.add(element, body);

	return post;
}

main :: proc() {
	doc := html.make_document();

	html.add_charset(doc);
	html.add_title(doc, "Neat");

	viewport := html.make_element("meta");
	viewport.attributes["name"] = "viewport";
	viewport.attributes["content"] = "width=device-width, initial-scale=1";
	html.add(doc.head, viewport);
	
	html.add_css(doc,
`
html,body {
	background-color: white;
	font-family: "Times New Roman";
}

#title {
	margin-top: 0;
	margin-bottom: 0;
	color: black;
	font-size: 2em;
}

#posts {
	width: 49%;
	overflow: auto;
	float: left;
}

#table {
	float: right;
	width: 49%;
	outline-style: solid;
	outline-width: 1px;
	outline-color: black;
	margin: 5px 5px;
	padding: 2px 2px;
}

.post {
	outline-style: solid;
	outline-width: 1px;
	outline-color: black;
	margin: 5px 5px;
	padding: 2px 2px;
}
`);

	title := html.make_heading("Neat");
	html.set_id(title, "title");
	html.add(doc, title);

	title_line := html.make_element("hr");
	html.add(doc, title_line);

	post_div := html.make_element("div");
	html.add(doc, post_div);
	html.set_id(post_div, "posts");

	html.add(post_div, make_post("We want more", "by internetjerk321", "We want more posts!!").element);
	html.add(post_div, make_post("Here is more", "by niceguy2", "https://goodstuff.com/").element);
	html.add(post_div, make_post("Even more", "by randy", "https://catpics.net/").element);
	html.add(post_div, make_post("Even more", "by randy", "https://catpics.net/").element);
	html.add(post_div, make_post("Even more", "by randy", "https://catpics.net/").element);
	html.add(post_div, make_post("Even more", "by randy", "https://catpics.net/").element);

	table_div := html.make_element("div");
	html.add(doc, table_div);
	html.set_id(table_div, "table");

	html.add(table_div, html.make_paragraph("Text!"));

	data := html.gen(doc);
	os.write_entire_file("test1.html", data[..]);
}