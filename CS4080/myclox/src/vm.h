#ifndef clox_vm_h
#define clox_vm_h
// This is where the bytecode gets executed.

#include "chunk.h"

#define STACK_MAX 256

typedef struct {
  Chunk* chunk;
  uint8_t* ip; // instruction pointer

  // Now, the chunk has constant data it got from compile time, but the values
  // produced during runtime are stored on the VM's stack.
  Value stack[STACK_MAX];
  Value* stackTop;
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
void push(Value value);
Value pop();

#endif
