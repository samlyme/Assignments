#ifndef clox_value_h
#define clox_value_h

#include "common.h"

// Need to forward declare Obj here.
typedef struct Obj Obj;
typedef struct ObjString ObjString;

// Tagged union for typed values.
typedef enum {
  VAL_BOOL,
  VAL_NIL,
  VAL_NUMBER,
  VAL_OBJ,
} ValueType;

typedef struct {
  ValueType type;
  union {
    bool boolean;
    double number;
    Obj* obj;
  } as;
} Value;

#define IS_BOOL(value) ((value).type == VAL_BOOL)
#define IS_NIL(value) ((value).type == VAL_NIL)
#define IS_NUMBER(value) ((value).type == VAL_NUMBER)
#define IS_OBJ(value) ((value).type == VAL_OBJ)

#define AS_BOOL(value) ((value).as.boolean)
#define AS_NUMBER(value) ((value).as.number)
#define AS_OBJ(value) ((value).as.obj)

#define BOOL_VAL(value) ((Value){VAL_BOOL, {.boolean = value}})
#define NIL_VAL ((Value){VAL_NIL, {.number = 0}})
#define NUMBER_VAL(value) ((Value){VAL_NUMBER, {.number = value}})
#define OBJ_VAL(object) ((Value){VAL_OBJ, {.obj = (Obj*)object}})

typedef struct {
  int count;
  int capacity;
  Value* values;
} ValueArray; // atm, this is essentially the same as chunk

bool valuesEqual(Value a, Value b);
// NOTE: The book does NOT have this here, but I just felt like it made sense.
bool isFalsey(Value value);

void initValueArray(ValueArray* array);
void freeValueArray(ValueArray* array);
void writeValueArray(ValueArray* array, Value value);

void printValue(Value value);
/*
There are various places to store "data". In fact, code is data! But, in our
model, we sort of treat "data" and "instructions" as different things. We have
an explicit "constant pool", which are values that are known at compile time.
For reasons, clox decides to put all values in the constant pool, even simple
numerical data.
*/

#endif
