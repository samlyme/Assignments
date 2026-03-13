package com.mylox.lox;

import java.util.List;
import java.util.Map;

class LoxClass implements LoxCallable{
    final String name;
    private final Map<String, LoxFunction> methods;

    LoxClass(String name, Map<String, LoxFunction> methods) {
        this.methods = methods;
        this.name = name;
    }

    public LoxFunction findMethod(String name) {
        return methods.getOrDefault(name, null);
    }

    @Override
    public Object call(Interpreter interpreter, List<Object> arguments) {
        LoxInstance instance = new LoxInstance(this);
        return instance;
    }

    @Override
    public int arity() {
        return 0;
    }

    @Override
    public String toString() {
        return name;
    }
}
