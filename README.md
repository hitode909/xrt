[![Build Status](https://travis-ci.org/hitode909/xrt.svg?branch=master)](https://travis-ci.org/hitode909/xrt)

# XRT

Refactoring Tool for [Text::Xslate](https://metacpan.org/pod/Text::Xslate).
Currently aim to refactor [Syntax::TTerse](https://metacpan.org/pod/Text::Xslate::Syntax::TTerse) templates.

## Installation

```
$ gem install xrt
```

## Commands

`XRT` provides `xrt` command.

### Dump

`xrt dump` command annotates the template with nested levels of control statements.

```
$ xrt dump TARGET_TEMPLATE
```

#### Example

`FOR` locates on nested level 1, and inner `IF` locates on nested level is 2.
Valid templates must end with nested level is 0.

```
% xrt dump templates/sample.html
Dumping templates/sample.html
<html>
  <body>
    0[% FOR item IN items %]1
      1[% IF item.title %]2
        <h1>2[% title %]2</h1>
      2[% END %]1
    1[% END %]0
  </body>
</html>
0
```

### Extract

`xrt extract` extracts the specified block from target template to another new template.

```
$ xrt extract TARGET_TEMPLATE TARGET_BLOCK TEMPLATES_DIRECTORY NEW_TEMPLATE_NAME
```

#### Example

When you want to extract `FOR` block to new template `templates/_items.tt`,

- `TARGET_TEMPLATE` is the path of original template.
- Set `TARGET_BLOCK` like `[% FOR item IN items %]`, `[% FOR item IN` or `[% FOR`. This must match with a beginning of only one block.
- `TEMPLATES_DIRECTORY` is the directory which the template is located. Usually it may be `templates/` or `views/`.
- `NEW_TEMPLATE_NAME` is the new template. This parameter is used to generate new `[% INCLUDE %]` directive. New template will stored in `TEMPLATES_DIRECTORY`.

```
% xrt extract templates/sample.html '[% FOR item IN items %]' templates/ _items.tt
```

The result is below.

```
# tempaltes/sample.html
<html>
  <body>
    [% INCLUDE "_items.tt" %]
  </body>
</html>
```

```
# templates/_items.tt
[% FOR item IN items %]
  [% IF item.title %]
    <h1>[% title %]</h1>
  [% END %]
[% END %]
```
