#include <stdio.h>
#include "common.h"
#include "chunk.h"
#include "debug.h"

int main(int argc, const char* argv[]) {
    Chunk chunk;
    initChunk(&chunk);

    int constantIdx = addConstant(&chunk, 1.2);
    writeChunk(&chunk, OP_CONSTANT);
    writeChunk(&chunk, constantIdx);

    writeChunk(&chunk, OP_RETURN);

    printf("Chunk count: %d\n", chunk.count);
    disassembleChunk(&chunk, "test chunk");
    
    return 0;
}