# HelloDag

This demonstrate how to uses Dagger Elixir SDK with the Phoenix application.

## Before start

You need Dagger 0.11.6+ or higher. And the knowledge of Elixir programming language.

## Getting Started

### Directory layout

The Dagger module code living inside `dagger` directory. In that directory, it has
2 Elixir projects:

- `dagger_sdk` The Dagger SDK.
- `hello_dag` The Dagger module for `hello_dag` application.

### Running

On the root of this repository, you can run `dagger call test --source=.:default` to
run unit tests suite in the Phoenix project. The module will spin up the database and 
configure it for you.


