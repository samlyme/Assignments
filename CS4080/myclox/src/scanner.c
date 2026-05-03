#include <stdio.h>
#include <string.h>

#include "common.h"  // IWYU pragma: keep
#include "scanner.h" // IWYU pragma: keep

typedef struct {
  const char* start;
  const char* current;
  int line;
} Scanner;

Scanner scanner;

void initScanner(const char* source) {
  scanner.start = source;
  scanner.current = source;
  scanner.line = 1;
}

static bool isDigit(char c) {
  return c >= '0' && c <= '9';
}

static bool isAtEnd() {
  return *scanner.current == '\0';
}

static char advance() {
  return *scanner.current++;
}

static bool match(char c) {
  if (isAtEnd()) return false; // edge case!

  if (*scanner.current != c) return false;

  scanner.current++;
  return true;
}

static char peek() {
  return *scanner.current;
}

static char peekNext() {
  if (isAtEnd()) return '\0';
  return *(scanner.current + 1);
}

Token makeToken(TokenType type) {
  Token token;

  token.type = type;
  token.start = scanner.start;
  token.length = (int)(scanner.current - scanner.start);
  token.line = scanner.line;

  return token; // straight up return by value. These are pretty cheap.
}

Token errorToken(const char* message) {
  Token token;

  token.type = TOKEN_ERROR;
  token.start = message; // only in c LOL
  token.length = (int)strlen(message);
  token.line = scanner.line;

  return token;
}

static void skipWhitespace() {
  // this function can't consume anything it isnt SURE of, so we use peek(), and
  // peekNext().
  char c;
  for (;;) {
    c = peek();
    switch (c) {
      case ' ':
      case '\r':
      case '\t': advance(); break;
      case '\n':
        scanner.line++;
        advance();
        break;
      case '/': {
        // super evil control flow.
        if (peekNext() == '/') {
          while (peek() != '\n' && !isAtEnd()) advance();
        } else {
          return;
        }
        break;
      }
      default: return;
    }
  } // potentially the most evil switch case i have ever seen. I love it.
}

Token string() {
  while (peek() != '"' && !isAtEnd()) {
    if (peek() == '\n') scanner.line++;
    advance();
  }

  if (isAtEnd()) return errorToken("Unterminated string.");

  advance(); // consume the closing quote.
  return makeToken(TOKEN_STRING);
}

Token number() {
  while (isDigit(peek())) advance();

  if (peek() == '.' && isDigit(peekNext())) {
    advance();
    while (isDigit(peek())) advance();
  }

  return makeToken(TOKEN_NUMBER);
}

Token scanToken() {
  skipWhitespace();
  scanner.start = scanner.current;

  if (isAtEnd()) return makeToken(TOKEN_EOF);

  char c = advance();

  switch (c) {
    // simple 1 char tokens.
    case '(': return makeToken(TOKEN_LEFT_PAREN);
    case ')': return makeToken(TOKEN_RIGHT_PAREN);
    case '{': return makeToken(TOKEN_LEFT_BRACE);
    case '}': return makeToken(TOKEN_RIGHT_BRACE);
    case ';': return makeToken(TOKEN_SEMICOLON);
    case ',': return makeToken(TOKEN_COMMA);
    case '.': return makeToken(TOKEN_DOT);
    case '-': return makeToken(TOKEN_MINUS);
    case '+': return makeToken(TOKEN_PLUS);
    case '/': return makeToken(TOKEN_SLASH);
    case '*': return makeToken(TOKEN_STAR);

    // simple 2 char tokens.
    case '!': return makeToken(match('=') ? TOKEN_BANG_EQUAL : TOKEN_BANG);
    case '=': return makeToken(match('=') ? TOKEN_EQUAL_EQUAL : TOKEN_EQUAL);
    case '<': return makeToken(match('=') ? TOKEN_LESS_EQUAL : TOKEN_LESS);
    case '>':
      return makeToken(match('=') ? TOKEN_GREATER_EQUAL : TOKEN_GREATER);

    // String literal.
    case '"': return string();
  }

  if (isDigit(c)) number();

  return errorToken("Unexpected cahracter.");
}
