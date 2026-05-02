#include "memory.h"
#include <stdlib.h>

// the GC code will go here later >:)
void* reallocate(void* pointer, size_t oldSize, size_t newSize) {
  if (newSize == 0) {
    free(pointer);
    return NULL;
  }

  // realloc is actually very useful!
  void* result = realloc(pointer, newSize);
  if (result == NULL) exit(1); // dead
  return result;
}
