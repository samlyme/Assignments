//> Strings object-c
#include <stdio.h>
#include <string.h>

#include "memory.h"
#include "object.h"
//> Hash Tables object-include-table
#include "table.h"
//< Hash Tables object-include-table
#include "value.h"
#include "vm.h"
//> allocate-obj

#define ALLOCATE_OBJ(type, objectType)                                         \
  (type *)allocateObject(sizeof(type), objectType)
//< allocate-obj
//> allocate-object

static Obj *allocateObject(size_t size, ObjType type) {
  Obj *object = (Obj *)reallocate(NULL, 0, size);
  object->type = type;
  //> Garbage Collection init-is-marked
  object->isMarked = false;
  //< Garbage Collection init-is-marked
  //> add-to-list

  object->next = vm.objects;
  vm.objects = object;
  //< add-to-list
  //> Garbage Collection debug-log-allocate

#ifdef DEBUG_LOG_GC
  printf("%p allocate %zu for %d\n", (void *)object, size, type);
#endif

  //< Garbage Collection debug-log-allocate
  return object;
}
//< allocate-object
//> Methods and Initializers new-bound-method
ObjBoundMethod *newBoundMethod(Value receiver, ObjClosure *method) {
  ObjBoundMethod *bound = ALLOCATE_OBJ(ObjBoundMethod, OBJ_BOUND_METHOD);
  bound->receiver = receiver;
  bound->method = method;
  return bound;
}
//< Methods and Initializers new-bound-method
//> Classes and Instances new-class
ObjClass *newClass(ObjString *name) {
  ObjClass *klass = ALLOCATE_OBJ(ObjClass, OBJ_CLASS);
  klass->name = name; // [klass]
                      //> Methods and Initializers init-methods
  initTable(&klass->methods);
  //< Methods and Initializers init-methods
  return klass;
}
//< Classes and Instances new-class
//> Closures new-closure
ObjClosure *newClosure(ObjFunction *function) {
  //> allocate-upvalue-array
  ObjUpvalue **upvalues = ALLOCATE(ObjUpvalue *, function->upvalueCount);
  for (int i = 0; i < function->upvalueCount; i++) {
    upvalues[i] = NULL;
  }

  //< allocate-upvalue-array
  ObjClosure *closure = ALLOCATE_OBJ(ObjClosure, OBJ_CLOSURE);
  closure->function = function;
  //> init-upvalue-fields
  closure->upvalues = upvalues;
  closure->upvalueCount = function->upvalueCount;
  //< init-upvalue-fields
  return closure;
}
//< Closures new-closure
//> Calls and Functions new-function
ObjFunction *newFunction() {
  ObjFunction *function = ALLOCATE_OBJ(ObjFunction, OBJ_FUNCTION);
  function->arity = 0;
  //> Closures init-upvalue-count
  function->upvalueCount = 0;
  //< Closures init-upvalue-count
  function->name = NULL;
  initChunk(&function->chunk);
  return function;
}
//< Calls and Functions new-function
//> Classes and Instances new-instance
ObjInstance *newInstance(ObjClass *klass) {
  ObjInstance *instance = ALLOCATE_OBJ(ObjInstance, OBJ_INSTANCE);
  instance->klass = klass;
  initTable(&instance->fields);
  return instance;
}
//< Classes and Instances new-instance
//> Calls and Functions new-native
ObjNative *newNative(NativeFn function) {
  ObjNative *native = ALLOCATE_OBJ(ObjNative, OBJ_NATIVE);
  native->function = function;
  return native;
}
//< Calls and Functions new-native

/* Strings allocate-string < Hash Tables allocate-string
static ObjString* allocateString(char* chars, int length) {
*/
//> allocate-string
//> Hash Tables allocate-string
static ObjString *allocateString(char *chars, int length, uint32_t hash) {
  //< Hash Tables allocate-string
  ObjString *string = ALLOCATE_OBJ(ObjString, OBJ_STRING);
  string->length = length;
  string->chars = chars;
  //> Hash Tables allocate-store-hash
  string->hash = hash;
  //< Hash Tables allocate-store-hash
  //> Hash Tables allocate-store-string
  //> Garbage Collection push-string

  push(OBJ_VAL(string));
  //< Garbage Collection push-string
  tableSet(&vm.strings, string, NIL_VAL);
  //> Garbage Collection pop-string
  pop();

  //< Garbage Collection pop-string
  //< Hash Tables allocate-store-string
  return string;
}
//< allocate-string
//> Hash Tables hash-string
static uint32_t hashString(const char *key, int length) {
  uint32_t hash = 2166136261u;
  for (int i = 0; i < length; i++) {
    hash ^= (uint8_t)key[i];
    hash *= 16777619;
  }
  return hash;
}
//< Hash Tables hash-string
//> take-string
ObjString *takeString(char *chars, int length) {
  /* Strings take-string < Hash Tables take-string-hash
    return allocateString(chars, length);
  */
  //> Hash Tables take-string-hash
  uint32_t hash = hashString(chars, length);
  //> take-string-intern
  ObjString *interned = tableFindString(&vm.strings, chars, length, hash);
  if (interned != NULL) {
    FREE_ARRAY(char, chars, length + 1);
    return interned;
  }

  //< take-string-intern
  return allocateString(chars, length, hash);
  //< Hash Tables take-string-hash
}
//< take-string
ObjString *copyString(const char *chars, int length) {
  //> Hash Tables copy-string-hash
  uint32_t hash = hashString(chars, length);
  //> copy-string-intern
  ObjString *interned = tableFindString(&vm.strings, chars, length, hash);
  if (interned != NULL)
    return interned;

  //< copy-string-intern
  //< Hash Tables copy-string-hash
  char *heapChars = ALLOCATE(char, length + 1);
  memcpy(heapChars, chars, length);
  heapChars[length] = '\0';
  /* Strings object-c < Hash Tables copy-string-allocate
    return allocateString(heapChars, length);
  */
  //> Hash Tables copy-string-allocate
  return allocateString(heapChars, length, hash);
  //< Hash Tables copy-string-allocate
}

Value takeStringValue(char *chars, int length) {
  if (length <= SHORT_STRING_MAX) {
    Value value = SHORT_STRING_VAL(chars, length);
    FREE_ARRAY(char, chars, length + 1);
    return value;
  }

  return OBJ_VAL(takeString(chars, length));
}

Value copyStringValue(const char *chars, int length) {
  if (length <= SHORT_STRING_MAX) {
    return SHORT_STRING_VAL(chars, length);
  }

  return OBJ_VAL(copyString(chars, length));
}

int stringValueLength(Value value) {
  if (IS_SHORT_STRING(value))
    return shortStringLength(value);
  return AS_STRING(value)->length;
}

void copyStringValueChars(Value value, char *chars) {
  if (IS_SHORT_STRING(value)) {
    copyShortString(value, chars);
    return;
  }

  ObjString *string = AS_STRING(value);
  memcpy(chars, string->chars, string->length);
}

bool stringValuesEqual(Value a, Value b) {
  int length = stringValueLength(a);
  if (length != stringValueLength(b))
    return false;

  if (!IS_SHORT_STRING(a) && !IS_SHORT_STRING(b)) {
    return AS_STRING(a) == AS_STRING(b);
  }

  if (IS_SHORT_STRING(a)) {
    char aChars[SHORT_STRING_MAX];
    copyShortString(a, aChars);
    if (IS_SHORT_STRING(b)) {
      char bChars[SHORT_STRING_MAX];
      copyShortString(b, bChars);
      return memcmp(aChars, bChars, length) == 0;
    }
    return memcmp(aChars, AS_STRING(b)->chars, length) == 0;
  }

  char chars[SHORT_STRING_MAX];
  copyShortString(b, chars);
  return memcmp(AS_STRING(a)->chars, chars, length) == 0;
}

void printStringValue(Value value) {
  if (IS_SHORT_STRING(value)) {
    char chars[SHORT_STRING_MAX];
    int length = shortStringLength(value);
    copyShortString(value, chars);
    printf("%.*s", length, chars);
    return;
  }

  ObjString *string = AS_STRING(value);
  printf("%.*s", string->length, string->chars);
}
//> Closures new-upvalue
ObjUpvalue *newUpvalue(Value *slot) {
  ObjUpvalue *upvalue = ALLOCATE_OBJ(ObjUpvalue, OBJ_UPVALUE);
  //> init-closed
  upvalue->closed = NIL_VAL;
  //< init-closed
  upvalue->location = slot;
  //> init-next
  upvalue->next = NULL;
  //< init-next
  return upvalue;
}
//< Closures new-upvalue
//> Calls and Functions print-function-helper
static void printFunction(ObjFunction *function) {
  //> print-script
  if (function->name == NULL) {
    printf("<script>");
    return;
  }
  //< print-script
  printf("<fn %s>", function->name->chars);
}
//< Calls and Functions print-function-helper
//> print-object
void printObject(Value value) {
  switch (OBJ_TYPE(value)) {
    //> Methods and Initializers print-bound-method
  case OBJ_BOUND_METHOD:
    printFunction(AS_BOUND_METHOD(value)->method->function);
    break;
    //< Methods and Initializers print-bound-method
    //> Classes and Instances print-class
  case OBJ_CLASS:
    printf("%s", AS_CLASS(value)->name->chars);
    break;
    //< Classes and Instances print-class
    //> Closures print-closure
  case OBJ_CLOSURE:
    printFunction(AS_CLOSURE(value)->function);
    break;
    //< Closures print-closure
    //> Calls and Functions print-function
  case OBJ_FUNCTION:
    printFunction(AS_FUNCTION(value));
    break;
    //< Calls and Functions print-function
    //> Classes and Instances print-instance
  case OBJ_INSTANCE:
    printf("%s instance", AS_INSTANCE(value)->klass->name->chars);
    break;
    //< Classes and Instances print-instance
    //> Calls and Functions print-native
  case OBJ_NATIVE:
    printf("<native fn>");
    break;
    //< Calls and Functions print-native
  case OBJ_STRING:
    printf("%s", AS_CSTRING(value));
    break;
    //> Closures print-upvalue
  case OBJ_UPVALUE:
    printf("upvalue");
    break;
    //< Closures print-upvalue
  }
}
//< print-object
