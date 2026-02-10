package com.mylox.lox;

class RPNAstPrinter extends AstPrinter {
    @Override
    public String visitBinaryExpr(Expr.Binary expr) {
        return String.join(
                " ",
                expr.left.accept(this),
                expr.right.accept(this),
                expr.operator.lexeme
        );
    }

    @Override
    public String visitGroupingExpr(Expr.Grouping expr) {
        return expr.expression.accept(this);
    }

    @Override
    public String visitLiteralExpr(Expr.Literal expr) {
        // literals are treated the same!
        return super.visitLiteralExpr(expr);
    }

    @Override
    public String visitUnaryExpr(Expr.Unary expr) {
        return String.join(
                " ",
                expr.right.accept(this),
                expr.operator.lexeme
        );
    }

    public static void main(String[] args) {
        Expr expression = new Expr.Binary(
                new Expr.Grouping(
                        new Expr.Binary(
                                new Expr.Literal(1),
                                new Token(TokenType.PLUS, "+", null, 1),
                                new Expr.Literal(2)
                        )
                ),
                new Token(TokenType.STAR, "*", null, 1),
                new Expr.Grouping(
                        new Expr.Binary(
                                new Expr.Literal(3),
                                new Token(TokenType.MINUS, "-", null, 1),
                                new Expr.Literal(4)
                        )
                )
        );

        System.out.println(new RPNAstPrinter().print(expression));

    }
}
