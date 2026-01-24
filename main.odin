package main

import "base:runtime"
import "core:flags"
import "core:fmt"
import "core:os/os2"
import "core:strings"
import "core:time"
import cm "vendor:commonmark"

BUILD_ROOT :: "build/olge-dev"

Article :: struct {
	title:   string,
	content: string,
}

articles: ^[dynamic]Article

Options :: struct {
	format: bool `usage:"Pretty format the generated HTML files"`,
}

opt: Options

main :: proc() {
	start_time := time.now()
	style: flags.Parsing_Style = .Odin
	flags.parse_or_exit(&opt, os2.args, style)
	fmt.println(opt)

	os2.make_directory_all("./build/olge-dev/articles/")
	os2.make_directory_all("./build/olge-dev/js/")
	os2.make_directory_all("./build/olge-dev/styles/")
	// str := "# Title\nHello from *Odin*!"
	// root := cm.parse_document(raw_data(str), len(str), cm.DEFAULT_OPTIONS)
	// html := cm.render_html(root, cm.DEFAULT_OPTIONS)
	// fmt.println(html)
	// article, err := os2.read_entire_file("articles/first.md", context.temp_allocator)
	// if err != os2.ERROR_NONE {
	// 	fmt.println("Failed to read file")
	// 	fmt.printfln("Error: %v", err)
	// 	return
	// }
	// root := cm.parse_document(raw_data(article), len(article), cm.DEFAULT_OPTIONS)
	// html := cm.render_html(root, cm.DEFAULT_OPTIONS)
	// fmt.println(html)
	articles_files, err_articles := os2.read_directory_by_path(
		"articles",
		0,
		context.temp_allocator,
	)
	if err_articles != os2.ERROR_NONE {
		fmt.println("Failed to read directory")
		fmt.printfln("Error: %v", err_articles)
		return
	}
	// generate_articles(articles_files, articles)

	template, err_template := os2.read_entire_file("template.html", context.temp_allocator)
	if err_template != os2.ERROR_NONE {
		fmt.println("Failed to read template")
		fmt.printfln("Error: %v", err_template)
		return
	}

	os2.copy_file("build/olge-dev/style.css", "style.css")
	os2.copy_file("build/olge-dev/js/highlight.min.js", "js/highlight.min.js")
	os2.copy_file("build/olge-dev/js/odin.min.js", "js/odin.min.js")
	os2.copy_file("build/olge-dev/styles/default.css", "js/styles/default.css")
	os2.copy_file("build/olge-dev/styles/tokyo-night-dark.css", "js/styles/tokyo-night-dark.css")
	load_articles(articles_files)

	generate_articles(template)
	generate_index(template)
	generate_article_index(template)

	// generate_article_index(articles, template)

	// generate_article_list(articles)
	if opt.format {
		format_html_files()
	}
	elapsed := time.since(start_time)
	fmt.printfln("Site generated in %s", elapsed)
}

generate_html_file :: proc(file_path: string, content: string, template: []u8) {
	html_path, err_html_path := os2.join_path({BUILD_ROOT, file_path}, context.temp_allocator)
	html_file, _ := os2.open(html_path, {.Write, .Create, .Trunc})
	defer os2.close(html_file)
	if err_html_path != os2.ERROR_NONE {
		fmt.println("Failed to create html path")
		fmt.printfln("Error: %v", err_html_path)
		return
	}
	html_string_builder := strings.builder_make()
	fmt.sbprintf(&html_string_builder, string(template), content)
	os2.write_string(html_file, strings.to_string(html_string_builder))
}

generate_index :: proc(template: []u8) {
	content_string_builder := strings.builder_make()
	strings.write_string(&content_string_builder, "<h1>Index</h1>")
	strings.write_string(&content_string_builder, generate_article_list())
	generate_html_file("index.html", strings.to_string(content_string_builder), template)
}

generate_article_index :: proc(template: []u8) {
	content_string_builder := strings.builder_make()
	strings.write_string(&content_string_builder, "<h1>Articles</h1>")
	strings.write_string(&content_string_builder, generate_article_list())
	generate_html_file("articles.html", strings.to_string(content_string_builder), template)
}

load_articles :: proc(articles_files: []os2.File_Info) {
	if articles == nil {
		articles = new([dynamic]Article)
	}
	for article in articles_files {
		article_path, err_path := os2.join_path({"articles", article.name}, context.temp_allocator)
		if err_path != os2.ERROR_NONE {
			fmt.println("Failed to join path")
			fmt.printfln("Error: %v", err_path)
			continue
		}
		md, err_md := os2.read_entire_file_from_path(article_path, context.temp_allocator)
		if err_md != os2.ERROR_NONE {
			fmt.println("Failed to read article")
			fmt.printfln("Error: %v", err_md)
			continue
		}
		root := cm.parse_document(raw_data(md), len(md), {.Unsafe})
		defer cm.node_free(root)
		html := cm.render_html(root, {.Unsafe})
		article_name := strings.trim_suffix(article.name, ".md")
		append(articles, Article{title = article_name, content = string(html)})
		// article_html_name := fmt.tprintf("%s.html", article_name)
		// article_html_path, err_article_html_path := os2.join_path(
		// 	{BUILD_ROOT, "articles", article_html_name},
		// 	context.temp_allocator,
		// )
		// article_file, _ := os2.open(article_html_path, {.Write, .Create, .Trunc})
		// defer os2.close(article_file)
		// if err_article_html_path != os2.ERROR_NONE {
		// 	fmt.println("Failed to create article html path")
		// 	fmt.printfln("Error: %v", err_article_html_path)
		// 	continue
		// }
		// os2.write_string(article_file, "\n")
		// html_split := strings.split(string(html), "\n")
		// for line in html_split {
		// 	os2.write_string(article_file, line)
		// 	os2.write_string(article_file, "\n")
		// }
	}
}

generate_articles :: proc(template: []u8) {
	for article in articles {
		article_name := article.title
		article_html_name := fmt.tprintf("%s.html", article_name)
		generate_html_file(
			fmt.tprintf("articles/%s", article_html_name),
			article.content,
			template,
		)
	}

}

generate_article_list :: proc() -> string {
	sb := strings.builder_make()
	strings.write_string(&sb, "<ul>\n")
	for article in articles {
		article_name := article.title
		article_html_name := fmt.tprintf("%s.html", article_name)
		strings.write_string(
			&sb,
			fmt.tprintf(
				"<li><a href=\"articles/%s\">%s</a></li>\n",
				article_html_name,
				article_name,
			),
		)
	}
	strings.write_string(&sb, "</ul>\n")
	return strings.to_string(sb)
}

format_html_files :: proc() {
	buf := [2000]u8{}
	stdout := buf[:]
	state: os2.Process_State
	prettier := os2.Process_Desc {
		// command = {"npx", "prettier", "-c", "build", "-w"},
		command = {
			"powershell",
			"-Command",
			"npx",
			"prettier",
			"--ignore-path",
			"--write",
			"build/**/*.html",
		},
	}
	state, stdout, _, _ = os2.process_exec(prettier, context.temp_allocator)
	for !state.exited {
		time.sleep(10 * time.Millisecond)
	}
	fmt.println(string(stdout))
}
