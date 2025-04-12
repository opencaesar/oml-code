# OML Code

[![Build Status](https://github.com/opencaesar/oml-code/actions/workflows/ci.yml/badge.svg)](https://github.com/opencaesar//oml-code/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/opencaesar/oml-code?label=Release)](https://github.com/opencaesar//oml-code/releases/latest)

An extension to support [OML](https://opencaesar.github.io/oml) in VSCode-based IDEs.

## Run Locally

Run all commands in the `oml-code` directory.

### Prerequisites

Make sure you have [Node.js](https://nodejs.org/en) v22+ as well as a compatible
JavaScript package manager (i.e., `npm`) installed.

Install the project's dependencies.

```shell
$ npm install
```

### Development

To run the language server, first build the parser and abstract syntax tree
(AST), found in `language/generated/ast.ts`:

```shell
$ npm run langium:generate
```

*Note:* Run this command any time you change the grammar to keep the parser and
AST up to date.

Then build the langauge server:

```shell
$ npm run build
```

*Note:* Run this command any time you change the the language server source
(including the grammar) to keep the server up to date.
