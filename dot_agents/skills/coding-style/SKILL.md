---
name: coding-style
description: >-
  Personal coding style and Git commit message conventions.
  Use when writing, modifying, or reviewing code, or drafting Git commit messages.
metadata:
  upstream-title: "Franklin Yu’s Coding styles"
  upstream-url: "https://en.wikipedia.org/wiki/User:Franklin_Yu/Coding_styles"
  upstream-revision: "1373849365"
  upstream-revision-url: "https://en.wikipedia.org/w/index.php?title=User:Franklin_Yu/Coding_styles&oldid=1373849365"
  upstream-edited-on: "2026-09-08"
  synced-on: "2026-11-07"
---

# Coding styles

Unspecified details default to [Google style](https://google.github.io/styleguide/); fall back to [GitHub style](https://styleguide.github.com).

- Use [Shebang](https://en.wikipedia.org/wiki/Shebang_(Unix)) for executable scripts; remove file-type suffix.

- Many languages provide a special pointer called `this` or `self`, including C++, C#, Java, and Swift/Objective-C. Although not explicitly mentioned in most style guides, it is typically omitted when the compiler understands it correctly (basically everywhere except in constructors). However, it’s usually useful to recognize instance variables without the help of an IDE, so several style guides developed a convention to use some prefix or suffix to distinguish (most commonly an underscore). This sounds [Hungarian notation](https://en.wikipedia.org/wiki/Hungarian_notation), repeating what `this` was for. Decision:

  - For languages with a clear owner (such as Apple for Objective-C, and Microsoft for C#), if the owner decides to use a prefix or suffix, follow the owner. This means that the pointer is redundant, and should be omitted. Note that for C#, [.NET foundation](https://github.com/dotnet/runtime/blob/master/docs/coding-guidelines/coding-style.md) is considered de facto owner in addition to Microsoft.

  - For languages without a clear owner (notably C++), or if the owner doesn’t require such a prefix or suffix (notably Java), use the pointer instead of a prefix or suffix.

- For C/C++, shell scripts (POSIX, Bash, Zsh), Swift, CSS, and HTML: indent with tabs and align with spaces.[^1][^2]

- For C/C++, the main function return with macros [`EXIT_SUCCESS` or `EXIT_FAILURE`](https://en.cppreference.com/w/c/program/EXIT_status).

- For structs and unions in C, use the style `struct message_body` instead of `Message` as `typedef`, for same reason as in the Linux kernel style.[^3] Note that this rule doesn’t apply to C++.

- For Python, fall back to [PEP 8](https://www.python.org/dev/peps/pep-0008/).

- For [systemd](https://en.wikipedia.org/wiki/Systemd) unit files, keep a space around the equal sign for readability.

- When creating command-line flags, use kebab-case like `--my-variable=3` and `--refresh-after-build=false`. If kebab-case is forbidden, prefer `snake_case` over `mixedCase` (a.k.a. lower camel-case).

## Git commit message

Follow the Vim specification: first line is the summary, no longer than 50 characters; leave the second line empty; limit to 72 characters for other lines (except for long URL). More rules:

- Use “Sentence case” for the summary, as if writing a sentence, but omit the period mark. Use an imperative sentence, such as “Delete foo”, instead of “Deleting foo” or “Deletes foo”.

- If the change is trivial (re-format, fix typo, etc.), add a `Minor-commit: true` trailer to the message. I used to prefix `[m]` to the summary line, inspired by how MediaWiki presents [meta:Help:Minor edit](https://meta.wikimedia.org/wiki/Help:Minor%20edit); however, the trailer way makes use of existing tools,[^4] allows extensibility, and saves four (out of only 50!) characters for the summary line.

- Use some Markdown in the body, but make sure it reads good as plain text.

## Java

- Google prefers no delimiter for package names,[^5] but in reality this makes words hard-to-read like `multiplewords`. Some projects work around this by creating redundant (and non-semantic) package levels, like `google.app.engine` with no other packages in the prefix `google.app`. Since underscore in package names (like `google.app_engine` has negligible compatibility issue, I prefer underscore.

- Google prefers to group all non-static imports together. When there are more than 10 non-static imports, I find it cleaner to separate the ones for [JDK](https://en.wikipedia.org/wiki/Java_Development_Kit) from the ones for other dependencies (like [Spring Framework](https://en.wikipedia.org/wiki/Spring_Framework)).

## JavaScript/TypeScript

- For plain JavaScript that are highly unlikely to go into Google, use [StandardJS](https://standardjs.com) instead of Google style. Use Google style for all TypeScript.

- Avoid built-in `window.prompt()`, `window.confirm()` and `window.alert()`.[^6][^7]

## Makefile

- [implicit rules](https://www.gnu.org/software/make/manual/html_node/Implicit-Rules.html)

- [auto-dependency generation](https://make.mad-scientist.net/papers/advanced-auto-dependency-generation/)

- Avoid `@` suppressing [recipe echoing](https://www.gnu.org/software/make/manual/html_node/Echoing.html). Echoing provides valuable debugging information, such as variable expansion. It should typically be up to the user to decide whether to suppress the echoing (with `-s`/`--silent`). A common pattern is to replace all echoing within a target with a manual `@echo`; this pattern can be better achieved with [`--debug=basic`](https://www.gnu.org/software/make/manual/html_node/Options-Summary.html#index-_002d_002ddebug).

## Ruby

- Use the Robocop style for [Ruby](https://github.com/rubocop-hq/ruby-style-guide) and [Rails](https://github.com/rubocop-hq/rails-style-guide); fall back to Google, then GitHub style.

- [RSpec guides](https://www.betterspecs.org)

- Fix major version of gems in `Gemfile` (with `~>`).

## shell scripts

- For statements below, “all shells” means Bash, Zsh, [Dash](https://en.wikipedia.org/wiki/Almquist_shell#dash), and [BusyBox](https://en.wikipedia.org/wiki/BusyBox); they cover most cases, so should be good enough.

- [override] Omit unnecessary braces for parameter expansion, such as `echo "value=$var"` and `PATH="$PATH:/my/path"`, instead of `echo "value=${var}"` and `PATH="${PATH}:/my/path"`.

- For [`set`](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#set) builtin, use the `-o` version with long names instead of short names like `-e`. Recommended options are `errexit` and `nounset`. Non-POSIX [`pipefail`](https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html) is also recommended when in Bash/Zsh.

- Use [kebab-case](https://en.wikipedia.org/wiki/Kebab-case) for aliases. This is not POSIX, but it’s supported in all shells. Kebab-cases are more readable and easier to type (one less `⇧ Shift`).

- [override] Use kebab-case for functions in Bash/Zsh. They are not supported in Dash or BusyBox.

- When a command provides multiple versions of the same option (such as `-q`/`--brief` in GNU [Diff](https://en.wikipedia.org/wiki/Diff)), avoid the single-letter one. Optimize for readers, instead of authors; short form is good for interactive sessions.

- Prefer `--key=value` over `--key value`, since the former makes the binding relationship more obvious (the latter might be a Boolean flag and a positional argument). For long flags, prefer double dash like `--flag` over single dash like `-flag`; reserve single dash for short forms (when long form isn’t available, or for interactive usage).

- Keep a single space before, but not after, the [I/O redirection](https://en.wikipedia.org/wiki/Redirection_(computing)) operator (i.e. `<` and `>`). Rationale: the operator binds closer to the word after it (i.e. the file path); compare `command < file1 > file2` and `command <file1 >file2`.

- [override] For Zsh, do not quote a single variable like `$var` into `"$var"`, since Zsh doesn’t expand them like Bash does.

### wrapping long commands

The Google style guide recommend wrapping long commands with backslashes (escaping character `\`), like

```bash
command1 \
  | command2 \
  | command3 \
  | command4
```

I prefer avoiding backslashes as much as possible, making use of the fact that a pipe won’t end a command:

```bash
command1 | command2 | command3 | command4 |
  command5 |
  command6 --with --many=flags "and arguments" |
  command7 --config=/usr/share/some-config.yaml \
    --input="$HOME/.local/share/some-data.json"
  command8
```

Explanation of the example above: `command1` to `command4` are on the same line because they fit within the width limit. The first few words of `command6` actually fits in the `command5` line, but not the entire command, so it is put in a new line to avoid the backslash. The backslash in `command7` cannot be avoided, so we use an additional level of indentation to emphasize that.

Note that logical operators `&&` and `||` (for “and-or list”[^8]) also won’t end a command, so the same trick applies. Common example:

```bash
apt-get update &&
  apt-get install --assume-yes foo bar baz
```

### use shell features instead of helper commands

Avoid [UUoC](https://en.wikipedia.org/wiki/Cat_(Unix)#Useless_use_of_cat). When in Bash/Zsh, also avoid useless `echo` like:

```bash
echo 'input text' | foobar
```

Use [here strings](https://www.gnu.org/software/bash/manual/html_node/Redirections.html#Here-Strings) instead, like:

```bash
foobar <<<'input text'
```

### define functions

If POSIX-compatibility isn’t needed, define a function with `function` keyword, to avoid the function name being accidentally replaced with an alias.[^9] So don’t do this:

```bash
foo() {
  # body
}
```

Even better, omit the optional pair of parentheses. In other programming languages they actually wrap the list of parameters, so `()` means an empty list; this isn’t the case in Bash or Zsh. Therefore, the preferred syntax is

```bash
function foo {
  # body
}
```

Note that Google style recommends the redundant pairs of parentheses “for consistency”. I don’t see the value here, since Bash is very inconsistent with the other languages anyway.

## References

[^1]: ["Tab versus space indentation in C#"](https://web.archive.org/web/20150514132049/https://stackoverflow.com/questions/268538/tab-versus-space-indentation-in-c-sharp#8769873). *[Stack Overflow](https://en.wikipedia.org/wiki/Stack_Overflow)*. Archived on 2015-05-14.

[^2]: ["Why tabs are clearly superior"](https://lea.verou.me/2012/01/why-tabs-are-clearly-superior/). *[Lea Verou](https://en.wikipedia.org/wiki/Lea_Verou)*. 2012-01-17.

[^3]: ["Linux kernel coding style"](https://www.kernel.org/doc/html/latest/process/coding-style.html#typedefs).

[^4]: ["Git git-interpret-trailers Documentation"](https://git-scm.com/docs/git-interpret-trailers/2.32.0).

[^5]: [section “Package names”](https://google.github.io/styleguide/javaguide.html#s5.2.1-package-names)

[^6]: ["JavaScript's prompt, confirm and alert considered "old-fashioned""](https://softwareengineering.stackexchange.com/questions/106031/javascripts-prompt-confirm-and-alert-considered-old-fashioned). *[Stack Exchange](https://en.wikipedia.org/wiki/Stack_Exchange) - Software Engineering*.

[^7]: ["Disallow Use of Alert (no-alert)"](https://eslint.org/docs/rules/no-alert.html). *[ESLint](https://en.wikipedia.org/wiki/ESLint)*.

[^8]: ["2.9.3 Lists"](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_09_03). *POSIX.1-2017*.

[^9]: ["How the shell aliases affect shell functions: two pitfalls"](https://dev.to/franklinyu/how-the-shell-aliases-affect-shell-functions-two-pitfalls-2ao9).
