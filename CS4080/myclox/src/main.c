#include <stdio.h>
#include "common.h"
#include "chunk.h"
#include "debug.h"

int main(int argc, const char* argv[]) {
    Chunk chunk;
    initChunk(&chunk);

    for (int i = 0; i < 256; i++) {
        // should all be regular OP_CONSTANT
        writeConstant(&chunk, (Value)i, 1);
    }

    // should be OP_CONSTANT_LONG
        writeConstant(&chunk, 6.7, 2);

    writeChunk(&chunk, OP_RETURN, 123);

    printf("Chunk count: %d\n", chunk.count);
    disassembleChunk(&chunk, "test chunk");
    
    return 0;
}