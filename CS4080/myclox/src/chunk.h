#ifndef clox_chunk_h
#define clox_chunk_h

#include "common.h"
#include "value.h"
#include <stdint.h>

typedef enum {
  OP_RETURN,
} OpCode;

typedef struct {
  // some magic to make this feel like a dynamic array "object".
  int count;
  int capacity;
  uint8_t* code;

  // constant pool is associated per chunk
  ValueArray constants;
} Chunk;

// The Chunk API is what we will be working with 90% of the time, so it is
// worth abstracting the value array inside of it.
void initChunk(Chunk* chunk);
void freeChunk(Chunk* chunk);
void writeChunk(Chunk* chunk, uint8_t byte);
int addConstant(Chunk* chunk, Value value);

#endif
