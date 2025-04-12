# OML Code

[![Build Status](https://github.com/opencaesar/oml-code/actions/workflows/ci.yml/badge.svg)](https://github.com/opencaesar//oml-code/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/opencaesar/oml-code?label=Release)](https://github.com/opencaesar//oml-code/releases/latest)

An extension to support [OML](https://opencaesar.github.io/oml) in VSCode-based IDEs.

## Installation

1.Download the latest oml-code-\<version\>.vsix file from the Assets in:
https://github.com/opencaesar/oml-code/releases

Drag the drop the downloaded file to the extension tab of your VS Code.

Open an OML workspace and open *.oml text editor

## Development

Run all commands in the `oml-code` directory.

Make sure you have [Node.js](https://nodejs.org/en) v22+ as well as a compatible
JavaScript package manager (i.e., `npm`) installed.

### Prerequisites

Install the project's dependencies.

```shell
$ npm install
```

### Generate langium code

To run the language server, first build the parser and abstract syntax tree
(AST), found in `language/generated/ast.ts`:

```shell
$ npm run langium:generate
```

*Note:* Run this command any time you change the grammar to keep the parser and
AST up to date.

### Build source code

Then build the sources of the langauge server:

```shell
$ npm run build
```

*Note:* Run this command any time you change the the language server source (including the grammar) to keep the server up to date.
