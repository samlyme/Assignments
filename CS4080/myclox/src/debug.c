#include <stdio.h>

#include "debug.h"
#include "value.h"

void disassembleChunk(Chunk* chunk, const char* name) {
    printf("== %s ==\n", name);

    // this should be a while loop lmao
    // The instructions may have different sizes.
    for (int offset = 0; offset < chunk->count;) {
        offset = disassembleInstruction(chunk, offset);
    }
}

// why is this static?
static int simpleInstruction(const char* name, int offset) {
    printf("%s\n", name);
    return offset + 1;
}

static int constantInstruction(const char* name, Chunk* chunk, int offset) {
    uint8_t constant = chunk->code[offset+1];
    printf("%-16s %4d '", name, constant);
    printValue(chunk->constants.values[constant]);
    printf("'\n");
    return offset + 2;
}

static int constantLongInstruction(const char* name, Chunk* chunk, int offset) {
    uint8_t a = chunk->code[offset+1];
    uint8_t b = chunk->code[offset+2];
    uint8_t c = chunk->code[offset+3];

    int constant = (a << 16) + (b << 8) + c;
    printf("%-16s %4d '", name, constant);

    printValue(chunk->constants.values[constant]);
    printf("'\n");
    return offset + 4;
}
int getLine(Chunk* chunk, int offset) {
    int codeIdx = 0;
    int lineIdx = 0;
    while (codeIdx < offset) {
        codeIdx++;
        if (chunk->lines[lineIdx] == 0) {
            lineIdx += 2;
        } else {
            chunk->lines[lineIdx]--;
        }
    }

    return chunk->lines[lineIdx + 1];
}

int disassembleInstruction(Chunk* chunk, int offset) {
    printf("%04d ", offset);
    int prevLine = getLine(chunk, offset -1);
    int line = getLine(chunk, offset); // cursed O(n^2) perf.

    if (offset > 0 && line == prevLine) {
        printf("   | ");
    } else {
        printf("%4d ", line);
    }

    uint8_t instruction = chunk->code[offset];
    switch (instruction) {
        case OP_RETURN:
            return simpleInstruction("OP_RETURN", offset);
        case OP_CONSTANT:
            return constantInstruction("OP_CONSTANT", chunk, offset);
        case OP_CONSTANT_LONG:
            return constantLongInstruction("OP_CONSTANT_LONG", chunk, offset);
        default:
            printf("Unknown opcode %d\n", instruction);
            return offset + 1;
    }
}