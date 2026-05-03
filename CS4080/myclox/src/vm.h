#ifndef clox_vm_h
#define clox_vm_h
// This is where the bytecode gets executed.

#include "chunk.h"

typedef struct {
  Chunk* chunk;
} VM;

// We only have one global VM instance.
void initVM();
void freeVM();

#endif
