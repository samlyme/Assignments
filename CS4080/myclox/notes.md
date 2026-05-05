# Chapter 21 - Global Variables

Global variables in Lox are **late bound**, so

```
fun showVariable() {
  print global;
}

var global = "after";
showVariable();
```

Is valid Lox code. This is different from how local variables are handled, so
we have a different implementation for each.

## Statements

In variables are **declared** using a statement. Remember that **declarations**
typically "bind a thing to a name", and **statements** "do something". Thus,
we can't have declarations directly inside of a piece of control flow.

```
if (true) var lmao = "hi"; // NOT VALID, COMPILE ERROR.
```

Thus, we define a separate rule for what *can* go inside of control flows.
```
statement      → exprStmt
               | forStmt
               | ifStmt
               | printStmt
               | returnStmt
               | whileStmt
               | block ;
declaration    → classDecl
               | funDecl
               | varDecl
               | statement ;
```

For now, we define a subset of these rules:
```
statement      → exprStmt
               | printStmt ;

declaration    → varDecl
               | statement ;
```
