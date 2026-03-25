#ifndef clox_chunk_h
#define clox_chunk_h

#include "common.h"
#include "value.h"

// A "chunk" is a sequence of bytecode.

// Each instruction has a one-byte OpCode.
// This enum is just a representation for that.
typedef enum {
    OP_RETURN,
    OP_CONSTANT,
} OpCode;

// Since we don’t know how big the array needs to be before we start compiling 
// a chunk, it must be dynamic. (Just trust it.j)
// The reason `code` isn't of type OpCode* is because it can also include data. 
typedef struct {
    int count;
    int capacity;
    uint8_t* code; // dynamic array (cache friendly) of opcodes.
    int* lines; // maps back to the line in the source code.
                // each byte in code has a corresponding int in lines. yikes!
    ValueArray constants;
} Chunk;

void initChunk(Chunk* chunk);
void writeChunk(Chunk* chunk, uint8_t byte, int line);
void freeChunk(Chunk* chunk);

int addConstant(Chunk* chunk, Value value);

#endif