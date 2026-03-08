package com.mylox.lox;

import java.util.*;

class Resolver implements Expr.Visitor<Void>, Stmt.Visitor<Void> {
    private final Interpreter interpreter;
    private final Stack<List<VarObj>> scopes = new Stack<>();
    private static class VarObj {
        VarType type;
        Token token;

        public VarObj(VarType type, Token token) {
            this.type = type;
            this.token = token;
        }
    }
    private final Map<String, Integer> index = new HashMap<>();

    private  enum VarType {
        DECLARED,
        DEFINED,
        USED
    }
    private FunctionType currentFunction = FunctionType.NONE;
    private enum FunctionType {
        NONE,
        FUNCTION
    }


    Resolver(Interpreter interpreter) {
        this.interpreter = interpreter;
    }

    @Override
    public Void visitBlockStmt(Stmt.Block stmt) {
        beginScope();
        resolve(stmt.statements);

        for (VarObj entry : scopes.peek()) {
            if (entry.type != VarType.USED) {
                Lox.error(entry.token, "Unused variable " + entry.token.lexeme);
            }
        }
        endScope();
        return null;
    }

    @Override
    public Void visitVarStmt(Stmt.Var stmt) {
        declare(stmt.name);
        if (stmt.initializer != null) {
            resolve(stmt.initializer);
        }
        define(stmt.name);
        return null;
    }

    @Override
    public Void visitFunctionStmt(Stmt.Function stmt) {
        declare(stmt.name);
        define(stmt.name);

        resolveFunction(stmt, FunctionType.FUNCTION);
        return null;
    }

    private void resolveFunction(Stmt.Function function, FunctionType type) {
        FunctionType enclosingFunction = currentFunction;
        currentFunction = type;

        beginScope();
        for (Token param : function.params) {
            declare(param);
            define(param);
        }
        resolve(function.body);
        endScope();
        currentFunction = enclosingFunction;
    }

    @Override
    public Void visitExpressionStmt(Stmt.Expression stmt) {
        resolve(stmt.expression);
        return null;
    }

    @Override
    public Void visitIfStmt(Stmt.If stmt) {
        resolve(stmt.condition);
        resolve(stmt.thenBranch);
        if (stmt.elseBranch != null) resolve(stmt.elseBranch);
        return null;
    }

    @Override
    public Void visitPrintStmt(Stmt.Print stmt) {
        resolve(stmt.expression);
        return null;
    }

    @Override
    public Void visitReturnStmt(Stmt.Return stmt) {
        if (currentFunction == FunctionType.NONE) {
            Lox.error(stmt.keyword, "Can't return from top-level code.");
        }
        if (stmt.value != null) {
            resolve(stmt.value);
        }

        return null;
    }

    @Override
    public Void visitWhileStmt(Stmt.While stmt) {
        resolve(stmt.condition);
        resolve(stmt.body);
        return null;
    }

    @Override
    public Void visitBinaryExpr(Expr.Binary expr) {
        resolve(expr.left);
        resolve(expr.right);
        return null;
    }

    @Override
    public Void visitCallExpr(Expr.Call expr) {
        resolve(expr.callee);

        for (Expr argument : expr.arguments) {
            resolve(argument);
        }

        return null;
    }

    @Override
    public Void visitGroupingExpr(Expr.Grouping expr) {
        resolve(expr.expression);
        return null;
    }

    @Override
    public Void visitLiteralExpr(Expr.Literal expr) {
        return null;
    }

    @Override
    public Void visitLogicalExpr(Expr.Logical expr) {
        resolve(expr.left);
        resolve(expr.right);
        return null;
    }

    @Override
    public Void visitUnaryExpr(Expr.Unary expr) {
        resolve(expr.right);
        return null;
    }

    @Override
    public Void visitVariableExpr(Expr.Variable expr) {
        int varIndex = index.getOrDefault(expr.name.lexeme, -1);
        if (varIndex != -1 && !scopes.isEmpty() && varIndex < scopes.peek().size() && scopes.peek().get(varIndex).type == VarType.DECLARED) {
            Lox.error(expr.name, "Can't read local variable in its own initializer.");
        }

        resolveLocal(expr, expr.name);
        return null;
    }

    @Override
    public Void visitAssignExpr(Expr.Assign expr) {
        resolve(expr.value);
        resolveLocal(expr, expr.name);
        return null;
    }

    private void resolveLocal(Expr expr, Token name) {
        for (int i = scopes.size() - 1; i >= 0; i--) {
            int varIndex = index.getOrDefault(name.lexeme, -1);
            if (varIndex != -1 && varIndex < scopes.get(i).size()) {
                scopes.get(i).get(varIndex).type = VarType.USED;
                interpreter.resolve(expr, scopes.size() - 1 - i);
                return;
            }
        }
    }

    void resolve(List<Stmt> statements) {
        for (Stmt statement : statements) {
            resolve(statement);
        }
    }

    void resolve(Stmt statement) {
        statement.accept(this);
    }

    void resolve(Expr expr) {
        expr.accept(this);
    }

    private void beginScope() {
        scopes.push(new ArrayList<>());
    }

    private void endScope() {
        scopes.pop();
    }

    private void declare(Token name) {
        if (scopes.isEmpty()) return;

        List<VarObj> scope = scopes.peek();
        int varIndex = index.getOrDefault(name.lexeme, -1);
        if (varIndex != -1 && varIndex < scope.size()) {
            Lox.error(name,
                    "Already a variable with this name in this scope.");
        }

        index.put(name.lexeme, scope.size());
        scope.addLast(new VarObj(VarType.DECLARED, name));
    }

    private void define(Token name) {
        if (scopes.isEmpty()) return;

        scopes.peek().get(index.get(name.lexeme)).type = VarType.DEFINED;
    }
}
