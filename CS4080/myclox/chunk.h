#ifndef clox_chunk_h
#define clox_chunk_h

#include "common.h"

// A "chunk" is a sequence of bytecode.

// Each instruction has a one-byte OpCode.
// This enum is just a representation for that.
typedef enum {
    OP_RETURN,
} OpCode;

// Since we don’t know how big the array needs to be before we start compiling 
// a chunk, it must be dynamic. (Just trust it.j)
typedef struct {
    int count;
    int capacity;
    uint8_t* code; // dynamic array (cache friendly) of opcodes.
} Chunk;

void initChunk(Chunk* chunk);
void writeChunk(Chunk* chunk, uint8_t byte);

#endif