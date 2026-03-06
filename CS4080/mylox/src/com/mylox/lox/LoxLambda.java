package com.mylox.lox;

import java.util.List;

class LoxLambda implements LoxCallable {
    private final Environment closure;
    private final List<Stmt> body;
    private final List<Token> params;

    public LoxLambda(List<Token> params, List<Stmt> body, Environment closure) {
        this.closure = closure;
        this.body = body;
        this.params = params;
    }

    @Override
    public Object call(Interpreter interpreter, List<Object> arguments) {
        Environment environment = new Environment(closure);
        for (int i = 0; i < params.size(); i++) {
            environment.define(params.get(i).lexeme,
                    arguments.get(i));
        }

        try {
            interpreter.executeBlock(body, environment);
        } catch (Return returnValue) {
            return returnValue.value;
        }

        return null;
    }

    @Override
    public int arity() {
        return params.size();
    }
}
