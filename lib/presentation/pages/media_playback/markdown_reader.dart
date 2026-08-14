import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MarkdownReaderPage extends StatefulWidget {
  const MarkdownReaderPage({super.key});
  @override
  State<MarkdownReaderPage> createState() => _MarkdownReaderPageState();
}

class _MarkdownReaderPageState extends State<MarkdownReaderPage> {
  String data = r'''
# Markdown Test Document

This is a comprehensive test document for markdown rendering.

## Text Formatting

This is **bold text** and this is *italic text*. You can also use ***bold and italic*** together.

This is ~~strikethrough text~~.

We can also use `inline code` for technical terms.

## Paragraphs

This is the first paragraph. It contains multiple sentences to demonstrate how paragraphs are rendered in markdown.

This is the second paragraph. Notice the blank line between them creates separate paragraphs.

## Headings

# Heading 1
## Heading 2
### Heading 3
#### Heading 4
##### Heading 5
###### Heading 6

## Horizontal Rules

Below is a horizontal rule:

---

## Links

[External Link](https://example.com)

[Link with Title](https://example.com "Example Website")

[Reference Link][reference]

[reference]: https://example.com

## Images

![Alt Text](https://example.com/image.jpg "Image Title")

![Local Image](./images/photo.png)

## Blockquotes

> This is a blockquote.
> It can span multiple lines.

> Blockquotes can also contain other markdown:
> - **Bold** and *italic* text
> - `inline code`
> - [Links](https://example.com)

> Nested blockquotes are also possible:
>> Inner quote
>>> Deep nested quote

## Lists

### Unordered Lists

- Item 1
- Item 2
- Item 3
  - Nested item 1
  - Nested item 2
    - Deep nested item
- Item 4

### Ordered Lists

1. First item
2. Second item
3. Third item
   1. Nested ordered item
   2. Another nested item
4. Fourth item

### Mixed Lists

1. Ordered item one
2. Ordered item two
   - Unordered in ordered
   - Another unordered
3. Back to ordered

## Task Lists

- [x] Completed task
- [ ] Incomplete task
- [x] Another completed task
  - [ ] Nested incomplete
  - [x] Nested complete

## Code Blocks

### Inline Code

Use the `console.log()` function to debug.

### Fenced Code Blocks

```javascript
function greet(name) {
  console.log(`Hello, ${name}!`);
  return true;
}

const result = greet("World");
```

```python
def hello_world():
    print("Hello, World!")
    return None

class MyClass:
    def __init__(self):
        self.value = 42
```

```html
<!DOCTYPE html>
<html>
<head>
    <title>Test</title>
</head>
<body>
    <h1>Hello</h1>
</body>
</html>
```

```css
.container {
    display: flex;
    justify-content: center;
    background-color: #f0f0f0;
}
```

```bash
#!/bin/bash
echo "Hello, World!"
```

### Code Block with Line Numbers

```javascript:src/app.js
function calculate(a, b) {
    return a + b;  // line 2
}                  // line 3
```

## Tables

| Header 1 | Header 2 | Header 3 |
|----------|----------|----------|
| Cell 1   | Cell 2   | Cell 3   |
| Cell 4   | Cell 5   | Cell 6   |

| Left Aligned | Center Aligned | Right Aligned |
|:-------------|:---------------:|---------------:|
| Value 1       | Value 2         | Value 3        |
| Value 4       | Value 5         | Value 6        |

## Definition Lists

Term 1
: Definition 1 for term 1

Term 2
: Definition 1 for term 2
: Definition 2 for term 2

## Footnotes

This is text with a footnote[^1].

[^1]: This is the footnote content. It can contain multiple sentences and even **formatting**.

Another reference[^note].

[^note]: More footnote details here.

## Abbreviations

The HTML specification is maintained by W3C.

*[HTML]: Hyper Text Markup Language
*[W3C]: World Wide Web Consortium

## Escaping Characters

\*Not italic\* (escaped asterisks)

\\ Backslash

\` Backtick

\# Hash symbol

\[ Brackets

## Autolinks

https://www.example.com

contact@example.com

## HTML Entities

&amp; ampersand

&lt; less than

&gt; greater than

&quot; quotes

&apos; apostrophe

## Special Characters Test

Trademark: ™

Registered: ®

Copyright: ©

Degree: 90°F

Currency: $100, €50, ¥1000

## Edge Cases

### Empty Elements

[]()

[](#)

### Very Long Lines

This is a very long line that should wrap according to the renderer settings. It contains enough text to demonstrate how the markdown renderer handles long lines and word wrapping behavior in various contexts.

### Special Whitespace

Line with trailing spaces:
Notice the trailing spaces above.

Indented text: (two spaces)
  (four spaces)

### Unicode

Chinese: 你好世界
Japanese: こんにちは世界
Korean: 안녕하세요
Emoji: 🎉 🚀 💻

## Complex Nesting

> **Important Note:**
>
> This blockquote contains:
> 1. **Bold text**
> 2. *Italic text*
> 3. `code`
> 4. [links](https://example.com)
> 5. Lists:
>    - Nested
>    - Items
>
> And code blocks:
> ```python
> print("Hello")
> ```

## Setext Headings

This is Setext Heading
========================

This is Another Setext Heading
-------------------------------

## Conclusion

This test document covers most markdown syntax elements. Use this to verify your renderer is working correctly.

  ''';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Markdown'),
        elevation: 0,
      ),
      body: Markdown(data: data),
    );
  }
}
