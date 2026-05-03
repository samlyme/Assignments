#ifndef clox_vm_h
#define clox_vm_h
// This is where the bytecode gets executed.

#include "chunk.h"

typedef struct {
  Chunk* chunk;
  uint8_t* ip; // instruction pointer
} VM;

typedef enum {
  INTERPRET_OK,
  INTERPRET_COMPILE_ERROR,
  INTERPRET_RUNTIME_ERROR
} InterpretResult;

// We only have one global VM instance.
void initVM();
void freeVM();
InterpretResult interpret(Chunk* chunk);

#endif
