---
{
    "title": "Why build anything?",
    "date": "2026-01-27"
}
---
# Why build anything?

This blog that I am starting now has been something that I
have been thinking about doing for the longest time, but never taken action to
do. I have researched my options, evaluated things like [Jekyll](https://jekyllrb.com/)
and [Hugo](https://gohugo.io/), but I either end up in a state of analysis
paralysis, trying to make the best choice instead of simply making any choice,
or I end up sidetracked evaluating the pros and cons of using OpenGL or Vulkan
for a project I haven't even started on. In a way this website is a sort of way
to make myself finally do the things I want to do.

So, in the end, did I decide to go with Hugo or Jekyll? The answer is neither and
it's all because of the [recent video](https://www.youtube.com/watch?v=YvnTsiIFXeI)
by gingerBill in which he shows off his newly redesigned website which he built
his own static site generator for. And you know what, he was right, it was not
that hard. I probably spent less time writing this generator from scratch than I
have spent doing pointless "research" over the years. It is not perfect, it is not
robust, it will probably crash if you don't format your posts correctly, there will
probaly be pages generated wrongly and you know what, that is perfectly fine. This
blog is not mission critical, I do not store any user data and I don't plan on
monetizing it. It's just a fun little pet project and nothing more.

Which leads me to the next point of inspiration for this project, which is the [following video](https://www.youtube.com/shorts/cwrA7pPJWU0)
from Jeezy (aka LGUG2Z) where he argues for building the things you want to build
even if the only reason you have for building them is for the satisfaction of
having built something of use for yourself. He has a ton of projects he has written
himself, but his most popular is by far his tiling window manager for Windows 
(and now also Mac) [Komorebi](https://lgug2z.github.io/komorebi/index.html) which
I made [a video](https://youtu.be/0LCbS_gm0RA) showcasing almost 2 years ago and I
was amazingly surprised to see getting a ton of views and is now sitting at 33k views.

For now this website is one huge WIP, but I have everything I need for it to fulfill
its purpose. I am able to easily write my thoughts down in markdown and generate
the whole website at the press of a button in 0.5s (now, it would be 0.05s, but I
am currently copying all of the css that [highlight.js](https://highlightjs.org/) ships with,
while testing out different color schemes for the code blocks).

In case anyone is interested in doing this on their own and wondering how I achieved
this, then it's a very stupid and simple solution. All I've done is create a template
file for the html that looks something like this:

````html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link rel="stylesheet" href="/olge-dev/style.css" />
    <link
      rel="stylesheet"
      href="/olge-dev/js/highlight/styles/atom-one-dark.css"
    />
    <script
      type="text/javascript"
      src="/olge-dev/js/highlight/highlight.min.js"
    ></script>
    <script
      type="text/javascript"
      src="/olge-dev/js/highlight/languages/odin.min.js"
    ></script>
    <script
      type="text/javascript"
      src="/olge-dev/js/highlight/languages/xml.min.js"
    ></script>
    <script type="text/javascript">
      hljs.highlightAll();
    </script>
    <title>{:v}</title>
  </head>
  <body>
    <header>
      <div class="wrapper">
        <h1><a href="/olge-dev/">Olge</a></h1>
      </div>
    </header>
    <main>
      <div class="wrapper">{:v}</div>
    </main>
    <footer>
      <div class="wrapper">
        © 2026 Olge
      </div>
    </footer>
  </body>
</html>
````
I then read this whole file as a string in Odin, which also parses all the markdown
files using [CMark](https://pkg.odin-lang.org/vendor/commonmark/) and some custom
logic for some header information (which currently only is used for setting the
title of the post). The template, the content and the title for the page is then
passed to this function which generates the page:

````odin
generate_html_file :: proc(
	file_path: string,
	content: string,
	template: []u8,
	title: string = "",
) {
	html_path, _ := os2.join_path({BUILD_ROOT, file_path}, context.temp_allocator)
	html_file, _ := os2.open(html_path, {.Write, .Create, .Trunc})
	defer os2.close(html_file)
	html_string_builder := strings.builder_make()
	fmt.sbprintf(&html_string_builder, string(template), title, content)
	os2.write_string(html_file, strings.to_string(html_string_builder))
}
````
This is indeed a very naive solution, will not scale, will not be production ready,
but in around 200 lines of Odin code I now have my own static site generator that
does everything __I__ need it to do. I will continue to work on the design of the 
site, but now I have at least removed one hurdle from speaking my mind. Sometimes
you just have to realize that it's perfectly ok to not overcomplicate things and
sure, it might be jank, but at least it will be your jank.