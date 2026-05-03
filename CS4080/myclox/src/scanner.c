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

  return errorToken("Unexpected cahracter.");
}
