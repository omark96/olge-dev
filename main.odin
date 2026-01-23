package main

import "base:runtime"
import "core:flags"
import "core:fmt"
import "core:os/os2"
import "core:strings"
import "core:time"
import cm "vendor:commonmark"


opt: Options

Options :: struct {
	format: bool `usage:"Pretty format the generated HTML files"`,
}


main :: proc() {
	start_time := time.now()
	style: flags.Parsing_Style = .Odin
	flags.parse_or_exit(&opt, os2.args, style)
	fmt.println(opt.format)

	os2.make_directory_all("./build/articles/")
	os2.make_directory_all("./build/js/")
	os2.make_directory_all("./build/styles/")
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
	articles, err_articles := os2.read_directory_by_path("articles", 0, context.temp_allocator)
	if err_articles != os2.ERROR_NONE {
		fmt.println("Failed to read directory")
		fmt.printfln("Error: %v", err_articles)
		return
	}

	template, err_template := os2.read_entire_file("template.html", context.temp_allocator)
	if err_template != os2.ERROR_NONE {
		fmt.println("Failed to read template")
		fmt.printfln("Error: %v", err_template)
		return
	}

	os2.copy_file("build/style.css", "style.css")
	os2.copy_file("build/js/highlight.min.js", "js/highlight.min.js")
	os2.copy_file("build/js/odin.min.js", "js/odin.min.js")
	os2.copy_file("build/styles/default.css", "js/styles/default.css")
	os2.copy_file("build/styles/tokyo-night-dark.css", "js/styles/tokyo-night-dark.css")

	generate_articles(articles, template)


	generate_index(articles, template)

	generate_article_index(articles, template)

	generate_article_list(articles)
	if opt.format {
		format_html_files()
	}
	elapsed := time.since(start_time)
	fmt.printfln("Site generated in %s", elapsed)
}

format_html_files :: proc() {
	buf := [2000]u8{}
	stdout := buf[:]
	state: os2.Process_State
	prettier := os2.Process_Desc {
		// command = {"npx", "prettier", "-c", "build", "-w"},
		command = {"powershell", "-Command", "npx", "prettier", "--write", "build/**/*.html"},
	}
	state, stdout, _, _ = os2.process_exec(prettier, context.temp_allocator)
	// for !state.exited {
	// 	time.sleep(10 * time.Millisecond)
	// }
	fmt.println(string(stdout))
}

generate_index :: proc(articles: []os2.File_Info, template: []u8) {
	index_html_path, err_index_html_path := os2.join_path(
		{"build", "index.html"},
		context.temp_allocator,
	)
	index_file, _ := os2.open(index_html_path, {.Write, .Create, .Trunc})
	defer os2.close(index_file)
	if err_index_html_path != os2.ERROR_NONE {
		fmt.println("Failed to create index html path")
		fmt.printfln("Error: %v", err_index_html_path)
		return
	}
	template_split := strings.split(string(template), "{{main}}")
	os2.write_string(index_file, template_split[0])
	os2.write_string(index_file, "\n")
	os2.write_string(index_file, "<h1>Index</h1>\n")
	os2.write_string(index_file, generate_article_list(articles))
	os2.write_string(index_file, template_split[1])
}

generate_article_index :: proc(articles: []os2.File_Info, template: []u8) {
	articles_html_path, err_articles_html_path := os2.join_path(
		{"build", "articles.html"},
		context.temp_allocator,
	)
	index_file, _ := os2.open(articles_html_path, {.Write, .Create, .Trunc})
	defer os2.close(index_file)
	if err_articles_html_path != os2.ERROR_NONE {
		fmt.println("Failed to create article index html path")
		fmt.printfln("Error: %v", err_articles_html_path)
		return
	}
	template_split := strings.split(string(template), "{{main}}")
	os2.write_string(index_file, template_split[0])
	os2.write_string(index_file, "\n")
	os2.write_string(index_file, "<h1>Articles</h1>\n")
	os2.write_string(index_file, generate_article_list(articles))
	os2.write_string(index_file, template_split[1])
}

generate_article_list :: proc(articles: []os2.File_Info) -> string {
	sb := strings.builder_make()
	strings.write_string(&sb, "<ul>\n")
	for article in articles {
		article_name := strings.trim_suffix(article.name, ".md")
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

generate_articles :: proc(articles: []os2.File_Info, template: []u8) {
	for article in articles {
		article_path, err_path := os2.join_path({"articles", article.name}, context.temp_allocator)
		if err_path != os2.ERROR_NONE {
			fmt.println("Failed to join path")
			fmt.printfln("Error: %v", err_path)
			return
		}
		md, err_md := os2.read_entire_file_from_path(article_path, context.temp_allocator)
		if err_md != os2.ERROR_NONE {
			fmt.println("Failed to read article")
			fmt.printfln("Error: %v", err_md)
			return
		}
		root := cm.parse_document(raw_data(md), len(md), {.Unsafe})
		defer cm.node_free(root)
		html := cm.render_html(root, {.Unsafe})
		template_split := strings.split(string(template), "{{main}}")
		article_name := strings.trim_suffix(article.name, ".md")
		article_html_name := fmt.tprintf("%s.html", article_name)
		article_html_path, err_article_html_path := os2.join_path(
			{"build", "articles", article_html_name},
			context.temp_allocator,
		)
		article_file, _ := os2.open(article_html_path, {.Write, .Create, .Trunc})
		defer os2.close(article_file)
		if err_article_html_path != os2.ERROR_NONE {
			fmt.println("Failed to create article html path")
			fmt.printfln("Error: %v", err_article_html_path)
			return
		}
		os2.write_string(article_file, template_split[0])
		os2.write_string(article_file, "\n")
		html_split := strings.split(string(html), "\n")
		for line in html_split {
			os2.write_string(article_file, line)
			os2.write_string(article_file, "\n")
		}
		os2.write_string(article_file, template_split[1])
	}
}
