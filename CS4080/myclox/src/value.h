//> Chunks of Bytecode value-h
#ifndef clox_value_h
#define clox_value_h
//> Optimization include-string

#include <string.h>
//< Optimization include-string

#include "common.h"

//> Strings forward-declare-obj
typedef struct Obj Obj;
//> forward-declare-obj-string
typedef struct ObjString ObjString;
//< forward-declare-obj-string

//< Strings forward-declare-obj
#define SHORT_STRING_MAX 5

//> Optimization nan-boxing
#ifdef NAN_BOXING
//> qnan

//> sign-bit
#define SIGN_BIT ((uint64_t)0x8000000000000000)
//< sign-bit
#define QNAN     ((uint64_t)0x7ffc000000000000)
//< qnan
//> tags

#define TAG_NIL   1 // 01.
#define TAG_FALSE 2 // 10.
#define TAG_TRUE  3 // 11.
#define TAG_SHORT_STRING 4 // 100.
//< tags

typedef uint64_t Value;
//> is-number

//> is-bool
#define IS_BOOL(value)      (((value) | 1) == TRUE_VAL)
//< is-bool
//> is-nil
#define IS_NIL(value)       ((value) == NIL_VAL)
//< is-nil
#define IS_NUMBER(value)    (((value) & QNAN) != QNAN)
//< is-number
//> is-short-string
#define IS_SHORT_STRING(value) \
    (((value) & (SIGN_BIT | QNAN | 0x7)) == (QNAN | TAG_SHORT_STRING))
//< is-short-string
//> is-obj
#define IS_OBJ(value) \
    (((value) & (QNAN | SIGN_BIT)) == (QNAN | SIGN_BIT))
//< is-obj
//> as-number

//> as-bool
#define AS_BOOL(value)      ((value) == TRUE_VAL)
//< as-bool
#define AS_NUMBER(value)    valueToNum(value)
//< as-number
//> as-obj
#define AS_OBJ(value) \
    ((Obj*)(uintptr_t)((value) & ~(SIGN_BIT | QNAN)))
//< as-obj
//> number-val

//> bool-val
#define BOOL_VAL(b)     ((b) ? TRUE_VAL : FALSE_VAL)
//< bool-val
//> false-true-vals
#define FALSE_VAL       ((Value)(uint64_t)(QNAN | TAG_FALSE))
#define TRUE_VAL        ((Value)(uint64_t)(QNAN | TAG_TRUE))
//< false-true-vals
//> nil-val
#define NIL_VAL         ((Value)(uint64_t)(QNAN | TAG_NIL))
//< nil-val
#define NUMBER_VAL(num) numToValue(num)
//< number-val
//> short-string-val
#define SHORT_STRING_VAL(chars, length) shortStringVal(chars, length)
//< short-string-val
//> obj-val
#define OBJ_VAL(obj) \
    (Value)(SIGN_BIT | QNAN | (uint64_t)(uintptr_t)(obj))
//< obj-val
//> value-to-num

static inline double valueToNum(Value value) {
  double num;
  memcpy(&num, &value, sizeof(Value));
  return num;
}
//< value-to-num
//> num-to-value

static inline Value numToValue(double num) {
  Value value;
  memcpy(&value, &num, sizeof(double));
  return value;
}
//< num-to-value
//> short-string-helpers

static inline int shortStringLength(Value value) {
  return (int)((value >> 3) & 0x7);
}

static inline Value shortStringVal(const char* chars, int length) {
  Value value = QNAN | TAG_SHORT_STRING | ((uint64_t)length << 3);
  for (int i = 0; i < length; i++) {
    value |= (uint64_t)(uint8_t)chars[i] << (6 + i * 8);
  }
  return value;
}

static inline void copyShortString(Value value, char* chars) {
  int length = shortStringLength(value);
  for (int i = 0; i < length; i++) {
    chars[i] = (char)((value >> (6 + i * 8)) & 0xff);
  }
}
//< short-string-helpers

#else

//< Optimization nan-boxing
//> Types of Values value-type
typedef enum {
  VAL_BOOL,
  VAL_NIL, // [user-types]
  VAL_NUMBER,
  VAL_SHORT_STRING,
//> Strings val-obj
  VAL_OBJ
//< Strings val-obj
} ValueType;

//< Types of Values value-type
/* Chunks of Bytecode value-h < Types of Values value
typedef double Value;
*/
//> Types of Values value
typedef struct {
  ValueType type;
  union {
    bool boolean;
    double number;
    struct {
      int length;
      char chars[SHORT_STRING_MAX];
    } string;
//> Strings union-object
    Obj* obj;
//< Strings union-object
  } as; // [as]
} Value;
//< Types of Values value
//> Types of Values is-macros

#define IS_BOOL(value)    ((value).type == VAL_BOOL)
#define IS_NIL(value)     ((value).type == VAL_NIL)
#define IS_NUMBER(value)  ((value).type == VAL_NUMBER)
#define IS_SHORT_STRING(value) ((value).type == VAL_SHORT_STRING)
//> Strings is-obj
#define IS_OBJ(value)     ((value).type == VAL_OBJ)
//< Strings is-obj
//< Types of Values is-macros
//> Types of Values as-macros

//> Strings as-obj
#define AS_OBJ(value)     ((value).as.obj)
//< Strings as-obj
#define AS_BOOL(value)    ((value).as.boolean)
#define AS_NUMBER(value)  ((value).as.number)
//< Types of Values as-macros
//> Types of Values value-macros

#define BOOL_VAL(value)   ((Value){VAL_BOOL, {.boolean = value}})
#define NIL_VAL           ((Value){VAL_NIL, {.number = 0}})
#define NUMBER_VAL(value) ((Value){VAL_NUMBER, {.number = value}})
#define SHORT_STRING_VAL(chars, length) shortStringVal(chars, length)
//> Strings obj-val
#define OBJ_VAL(object)   ((Value){VAL_OBJ, {.obj = (Obj*)object}})
//< Strings obj-val
//< Types of Values value-macros
static inline int shortStringLength(Value value) {
  return value.as.string.length;
}

static inline Value shortStringVal(const char* chars, int length) {
  Value value;
  value.type = VAL_SHORT_STRING;
  value.as.string.length = length;
  memcpy(value.as.string.chars, chars, length);
  return value;
}

static inline void copyShortString(Value value, char* chars) {
  memcpy(chars, value.as.string.chars, value.as.string.length);
}
//> Optimization end-if-nan-boxing

#endif
//< Optimization end-if-nan-boxing
//> value-array

typedef struct {
  int capacity;
  int count;
  Value* values;
} ValueArray;
//< value-array
//> array-fns-h

//> Types of Values values-equal-h
bool valuesEqual(Value a, Value b);
//< Types of Values values-equal-h
void initValueArray(ValueArray* array);
void writeValueArray(ValueArray* array, Value value);
void freeValueArray(ValueArray* array);
//< array-fns-h
//> print-value-h
void printValue(Value value);
//< print-value-h

#endif
