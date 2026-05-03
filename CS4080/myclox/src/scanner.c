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

Token scanToken() {
  scanner.start = scanner.current;

  if (isAtEnd()) return makeToken(TOKEN_EOF);

  char c = advance();

  switch (c) {
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
  }

  return errorToken("Unexpected cahracter.");
}
