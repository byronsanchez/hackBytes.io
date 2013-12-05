---
title: Markdown Syntax Cheat Sheet
description: false
date: 2013-07-03 12:23:21
category: blog
comments_enabled: true
layout: blog-post
tags: [cheatsheet, markdown, reference, syntax]
---

#### Different video tests

Here is a quick markdown reference. Everything described here holds true
for hackBytes and most markdown-processors unless otherwise stated.

###Literal characters

Escape with backslash.

```
\*       ==      *
\*\*     ==      **
\#       ==      #
\#\#     ==      ##
\\       ==      \
```

###Headers

```
#h1
##h2
###h3
####h4
#####h5
######h6

OR

h1 can be done with 1 or more equal signs on the line below
===========================================================

h2 can be done with 1 or more dashes on the line below
------------------------------------------------------
```

###Emphasis (bold and italic)

For bold AND italic, you can use what is displayed here or combine
```*``` and ```_```.

```
_underlined text_
*italic text*
**bold text**
***bold and italic***

```

###Linking

Titles are optional for all formats.

```
[anchor text goes here](https://www.example.com) "Title"
```

You can also link using references/footnote-style links. The first set
of square brackets defines the anchor text. The second set of square
brackets defines the reference id. You can define the link anywhere in
the document.

<!-- TODO: Update in the future. -->
<div class="highlight text"><pre><code class="text">This is the [anchor text][id] for a link.

Now I'll just define the link at the bottom.

[id]: http://www.example.com/  "Title"</code></pre></div>
<!-- /TODO -->

###Paragraphs and Line Breaks

**Paragraphs**

Single newlines are ignored. Two or more newlines make a new paragraph.

```text
This line is example 1. It is its own paragraph.

This line is example 2. It is its own paragraph.

This set of lines is example 3. The single newlines used in this example
will be ignored. The entire text in this example is treated as if it
were a single paragraph.
```

**Line Breaks**

This one is a little tricky to describe, but it is really easy to use.

Line breaks are newlines *rendered* as ``<br>`` instead of as ``<p>``
tags. With the paragraph rules alone, there would be no way to render
``<br>`` tags. However, markdown *does* let you render them.

Simply add two spaces at the end of the lines you wish to break.
Otherwise, markdown will treat the set of lines as a single paragraph,
as mentioned earlier.

The following example would *not* result in a single paragraph. Instead,
markdown would render two lines separated by a ``<br>`` tag.

```text
This is line 1 for a line break example. This line contains two spaces at the end.  
This is line 2 for a line break example. Without the two spaces on the previous line, these two lines would be treated as a single paragraph and would contain no break.
```

###Horizontal Rules &lt;hr&gt;

Use three or more dashes, underscores or asterisks on a single line.

```
Sample text with hr underneath. Two newlines required here, as single newline conlicts with h2 header rule.

------------------------------

Or like this. A single newline is required, but two will work as well.

_____________________________

Or even this. A single newline is required, but two will work as well.
*****************************
```

###Code

Wrap code with three backticks to render code tags for syntax
highlighting.

{% highlight text %}
```
def syntax_highlight() {
  puts "Hi!"
}
```
{% endhighlight %}

###Blockquotes

```
> Add blockquotes to your pages
> using the greater-than angle bracket
> for each line you want to be part of the quote.

> > Nest quotes with multiple angle brackets.

> You can use any of the other markdown styles within blockquotes.

```

###Tables

Use pipes ``|`` to define tables.

The actual text does not have to line up to look like a nice table.
Whitespacing doesn't really matter (except for newlines).

```
| Table header 1 | Table Header 2 |
|----------------|----------------|
| row1 - column1 | row1 - column2 |
| row2 - column1 | row2 - column2 |

Outer pipes are optional:

 Table header 1 | Table Header 2
----------------|----------------
 row1 - column1 | row1 - column2 
 row2 - column1 | row2 - column2 

You can also define column alignment via the table-header and
table-body separator:

|:---| - left-align
|---:| - right-align
|:--:| - centered
|----| - default (no defined alignment in the rendered html).

```

###Lists

Numbered Lists

```
1. List item 1
2. List item 2
3. List item 3
```

Bulleted Lists

```
* List item 1
* List item 2
* List item 3


- List item 1
- List item 2
- List item 3

+ List item 1
+ List item 2
+ List item 3
```

Nested Lists

```
You can nest lists like this.

1. Level 1
1.1. Level 2

* Level 1
** Level 2

1. Level 1
** Level 2

Or with tabs

1. Level 1
  * Level 2
```

###HTML

{% highlight text %}
Type in some raw HTML...

<div class="test">
  Just like this!
</div>
{% endhighlight %}

###Images

Images are a lot like markdown links prefixed an exclamation mark.

```
![alt-text](/img-path.jpg "Optional title")
```

###Videos (hackBytes-specific)

This is simply a convenience tag for hackBytes and is *not* part of
markdown. It will not work anywhere else unless it is manually
implemented.

```
[video url-here]
[video url-here | style-here]
```

