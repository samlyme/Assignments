#include <stdio.h>

#include "common.h" // IWYU pragma: keep
#include "compiler.h"
#include "scanner.h"

void compile(const char* source) {
  initScanner(source);
}
