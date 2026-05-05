#ifndef clox_vm_h
#define clox_vm_h
// This is where the bytecode gets executed.

#include "chunk.h"
#include "object.h"
#include "table.h"

#define FRAMES_MAX 64
#define STACK_MAX (FRAMES_MAX * UINT8_COUNT)

typedef struct {
  ObjFunction* function;
  uint8_t* ip;
  Value* slots;
} CallFrame;

typedef struct {
  CallFrame frames[FRAMES_MAX];
  int frameCount;

  // Now, the chunk has constant data it got from compile time, but the values
  // produced during runtime are stored on the VM's stack.
  Value stack[STACK_MAX];
  Value* stackTop;

  Table strings; // string interning
  Table globals;
  Obj* objtects;
} VM;

typedef enum {
  INTERPRET_OK,
  INTERPRET_COMPILE_ERROR,
  INTERPRET_RUNTIME_ERROR
} InterpretResult;

extern VM vm; // evil evil evil evil evil

// We only have one global VM instance.
void initVM();
void freeVM();
InterpretResult interpret(const char* source);
void push(Value value);
Value pop();

#endif
