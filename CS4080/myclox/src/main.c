#include <stdio.h>
#include "common.h"
#include "chunk.h"
#include "debug.h"

int main(int argc, const char* argv[]) {
    Chunk chunk;
    initChunk(&chunk);

    int constantIdx = addConstant(&chunk, 1.2);
    writeChunk(&chunk, OP_CONSTANT, 123);
    writeChunk(&chunk, constantIdx, 123);

    writeChunk(&chunk, OP_RETURN, 123);

    printf("Chunk count: %d\n", chunk.count);
    disassembleChunk(&chunk, "test chunk");
    
    return 0;
}