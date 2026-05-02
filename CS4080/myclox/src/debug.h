#ifndef clox_debug_h
#define clox_debug_h

#include "chunk.h"

// Prints the bytecode of a chunk
void disassembleChunk(Chunk* chunk, const char* name);

// Some instructions require multiple bytes, so
// this function goes to that instruction and "consumes" all of the bytes,
// then returns the new offset.
int disassembleInstruction(Chunk* chunk, int offset);

#endif
