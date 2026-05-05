#ifndef clox_chunk_h
#define clox_chunk_h

#include "common.h"
#include "value.h"
#include <stdint.h>

typedef enum {
  OP_CONSTANT,
  OP_NIL,
  OP_TRUE,
  OP_FALSE,
  OP_POP,
  OP_GET_LOCAL,
  OP_SET_LOCAL,
  OP_GET_GLOBAL,
  OP_SET_GLOBAL,
  OP_DEFINE_GLOBAL,
  OP_EQUAL,
  OP_GREATER,
  OP_LESS,
  OP_ADD,
  OP_SUBTRACT,
  OP_MULTIPLY,
  OP_DIVIDE,
  OP_NOT,
  OP_NEGATE,
  OP_PRINT,
  OP_JUMP,
  OP_JUMP_IF_FALSE,
  OP_LOOP,
  OP_RETURN,
} OpCode;
// We need to know when to "produce" values from the constant pool.
// Remember, the VM is a stack machine, so it needs to have all the data
// it needs on the stack. There will be some more magic later.

typedef struct {
  // some magic to make this feel like a dynamic array "object".
  int count;
  int capacity;
  uint8_t* code;
  int* lines; // associate each byte of code to a line from our src code.
  ValueArray constants; // constant pool is associated per chunk
} Chunk;

// The Chunk API is what we will be working with 90% of the time, so it is
// worth abstracting the value array inside of it.
void initChunk(Chunk* chunk);
void freeChunk(Chunk* chunk);
void writeChunk(Chunk* chunk, uint8_t byte, int line);
int addConstant(Chunk* chunk, Value value);

#endif
