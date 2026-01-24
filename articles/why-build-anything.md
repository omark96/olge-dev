---
{
    "title": "Why build anything?"
}
---
# Why build anything?

This blog that I am starting now has been something that I for the longest time 
has been thinking about doing for the longest time, but never taken the time to
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
I made [a video](https://youtu.be/0LCbS_gm0RA) showcasing, almost 2 years ago and I
was amazingly surprised to see getting a ton of views and is now sitting at 33k views.

````html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link rel="stylesheet" href="/olge-dev/style.css" />
    <link rel="stylesheet" href="/olge-dev/styles/tokyo-night-dark.css" />
    <script type="text/javascript" src="/olge-dev/js/highlight.min.js"></script>
    <script type="text/javascript" src="/olge-dev/js/odin.min.js"></script>
    <script type="text/javascript">
      hljs.highlightAll();
    </script>
    <title>{:v}</title>
  </head>
  <body>
    <header>
      <div class="wrapper">
        <h1><a href="/olge-dev/">Olge</a></h1>
        <ul>
          <li><a href="/olge-dev">Home</a></li>
          <li><a href="/olge-dev/articles.html">Articles</a></li>
        </ul>
      </div>
    </header>
    <main>
      <div class="wrapper">{:v}</div>
    </main>
    <footer>
      <div class="wrapper">
        <br />
        © 2026 Olge
      </div>
    </footer>
  </body>
</html>
````