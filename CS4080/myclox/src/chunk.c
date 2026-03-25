#include <stdlib.h>
#include <stdio.h>

#include "chunk.h"
#include "memory.h"


void initChunk(Chunk* chunk) {
    chunk->count = 0;
    chunk->capacity = 0;
    chunk->code = NULL;

    chunk->lineCount = 0;
    chunk->lineCapacity = 0;
    chunk->lines = NULL;
    initValueArray(&chunk->constants);
}

void writeChunk(Chunk* chunk, uint8_t byte, int line) {
    if (chunk->capacity <= chunk->count) {
        int oldCapacity = chunk->capacity;

        chunk->capacity = GROW_CAPACITY(oldCapacity);

        chunk->code = GROW_ARRAY(uint8_t, chunk->code, oldCapacity, chunk->capacity);
        // chunk->lines = GROW_ARRAY(int, chunk->lines, oldCapacity, chunk->capacity);
    }
    chunk->code[chunk->count] = byte;
    chunk->count++;

    if (chunk->lineCapacity <= chunk->lineCount) {
        int oldCapacity = chunk->lineCapacity;

        chunk->lineCapacity = GROW_CAPACITY(oldCapacity);
        chunk->lines = GROW_ARRAY(int, chunk->lines, oldCapacity, chunk->lineCapacity);
        // printf("grow lines\n");
    }

    // assume that lines is homotopic increasing.
    if (chunk->lineCount == 0) {
        chunk->lines[0] = 1;
        chunk->lines[1] = line;
        chunk->lineCount = 2;
        // printf("init lines\n");
    } else if (line == chunk->lines[chunk->lineCount - 1])  {
        chunk->lines[chunk->lineCount - 2]++;
        // printf("incr lines\n");
    } else {
        chunk->lines[chunk->lineCount] = 1;
        chunk->lines[chunk->lineCount + 1] = line;
        chunk->lineCount += 2;
        // printf("new  lines\n");
    }
}

void freeChunk(Chunk* chunk) {
    FREE_ARRAY(uint8_t, chunk->code, chunk->capacity);
    FREE_ARRAY(int, chunk->lines, chunk->capacity);
    initChunk(chunk);
}

int addConstant(Chunk* chunk, Value value) {
    writeValueArray(&chunk->constants, value);
    return chunk->constants.count - 1;
}