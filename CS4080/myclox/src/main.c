#include "common.h" // IWYU pragma: keep
#include "chunk.h"
#include "debug.h"

int main(int argc, const char* argv[]) {
  Chunk chunk;
  initChunk(&chunk);
  writeChunk(&chunk, OP_RETURN);

  int constant = addConstant(&chunk, 1.2);
  writeChunk(&chunk, OP_CONSTANT);
  writeChunk(&chunk, constant); // weird casting :o, but is in book

  disassembleChunk(&chunk, "test chunk");
  freeChunk(&chunk);

  return 0;
}
