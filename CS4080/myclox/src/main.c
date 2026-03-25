#include <stdio.h>
#include "common.h"
#include "chunk.h"
#include "debug.h"
#include "vm.h"

int main(int argc, const char* argv[]) {
    initVM();

    Chunk chunk;
    initChunk(&chunk);

    // 1 * 2 + 3
    writeChunk(&chunk, OP_CONSTANT, 1);
    writeChunk(&chunk, addConstant(&chunk, 1), 1);

    writeChunk(&chunk, OP_CONSTANT, 1);
    writeChunk(&chunk, addConstant(&chunk, 2), 1);

    writeChunk(&chunk, OP_MULTIPLY, 1);

    writeChunk(&chunk, OP_CONSTANT, 1);
    writeChunk(&chunk, addConstant(&chunk, 3), 1);

    writeChunk(&chunk, OP_ADD, 1);


    // 1 + 2 * 3
    writeChunk(&chunk, OP_CONSTANT, 2);
    writeChunk(&chunk, addConstant(&chunk, 1), 2);

    writeChunk(&chunk, OP_CONSTANT, 2);
    writeChunk(&chunk, addConstant(&chunk, 2), 2);

    writeChunk(&chunk, OP_CONSTANT, 2);
    writeChunk(&chunk, addConstant(&chunk, 3), 2);

    writeChunk(&chunk, OP_MULTIPLY, 2);

    writeChunk(&chunk, OP_ADD, 2);

    // 3 - 2 - 1
    writeChunk(&chunk, OP_CONSTANT, 3);
    writeChunk(&chunk, addConstant(&chunk, 3), 3);

    writeChunk(&chunk, OP_CONSTANT, 3);
    writeChunk(&chunk, addConstant(&chunk, 2), 3);

    writeChunk(&chunk, OP_SUBTRACT, 3);

    writeChunk(&chunk, OP_CONSTANT, 3);
    writeChunk(&chunk, addConstant(&chunk, 1), 3);

    writeChunk(&chunk, OP_SUBTRACT, 3);

    // 1 + 2 * 3 - 4 / -5
    writeChunk(&chunk, OP_CONSTANT, 4);
    writeChunk(&chunk, addConstant(&chunk, 1), 4);

    writeChunk(&chunk, OP_CONSTANT, 4);
    writeChunk(&chunk, addConstant(&chunk, 2), 4);

    writeChunk(&chunk, OP_CONSTANT, 4);
    writeChunk(&chunk, addConstant(&chunk, 3), 4);

    writeChunk(&chunk, OP_MULTIPLY, 4);
    writeChunk(&chunk, OP_ADD, 4);

    writeChunk(&chunk, OP_CONSTANT, 4);
    writeChunk(&chunk, addConstant(&chunk, 4), 4);

    writeChunk(&chunk, OP_CONSTANT, 4);
    writeChunk(&chunk, addConstant(&chunk, 5), 4);
    writeChunk(&chunk, OP_NEGATE, 4);

    writeChunk(&chunk, OP_DIVIDE, 4);
    writeChunk(&chunk, OP_SUBTRACT, 4);

    // 4 - 3 * -2
    // without OP_NEGATE
    writeChunk(&chunk, OP_CONSTANT, 5);
    writeChunk(&chunk, addConstant(&chunk, 4), 5);

    writeChunk(&chunk, OP_CONSTANT, 5);
    writeChunk(&chunk, addConstant(&chunk, 3), 5);

    writeChunk(&chunk, OP_CONSTANT, 5);
    writeChunk(&chunk, addConstant(&chunk, 0), 5);
    writeChunk(&chunk, OP_CONSTANT, 5);
    writeChunk(&chunk, addConstant(&chunk, 2), 5);
    writeChunk(&chunk, OP_SUBTRACT, 5);

    writeChunk(&chunk, OP_MULTIPLY, 5);
    writeChunk(&chunk, OP_SUBTRACT, 5);

    // without OP_SUBTRACT
    writeChunk(&chunk, OP_CONSTANT, 5);
    writeChunk(&chunk, addConstant(&chunk, 4), 5);

    writeChunk(&chunk, OP_CONSTANT, 5);
    writeChunk(&chunk, addConstant(&chunk, 3), 5);
    writeChunk(&chunk, OP_NEGATE, 5);

    writeChunk(&chunk, OP_CONSTANT, 5);
    writeChunk(&chunk, addConstant(&chunk, 2), 5);
    writeChunk(&chunk, OP_NEGATE, 5);

    writeChunk(&chunk, OP_MULTIPLY, 5);
    writeChunk(&chunk, OP_ADD, 5);


    writeChunk(&chunk, OP_RETURN, 123);
    printf("Chunk count: %d\n", chunk.count);
    interpret(&chunk);
    freeVM();
    freeChunk(&chunk);
    return 0;
}