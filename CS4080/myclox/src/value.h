#ifndef clox_value_h
#define clox_value_h

#include "common.h"

// For now, only support double precision floats.
typedef double Value;

typedef struct {
  int count;
  int capacity;
  Value* values;
} ValueArray; // atm, this is essentially the same as chunk

void initValueArray(ValueArray* array);
void freeValueArray(ValueArray* array);
void writeValueArray(ValueArray* array, Value value);

/*
There are various places to store "data". In fact, code is data! But, in our
model, we sort of treat "data" and "instructions" as different things. We have
an explicit "constant pool", which are values that are known at compile time.
For reasons, clox decides to put all values in the constant pool, even simple
numerical data.
*/

#endif
