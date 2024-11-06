/* $Id: bison_spl_y_top.y,v 1.2 2024/10/09 18:18:55 leavens Exp $ */

%code top {
#include <stdio.h>
}

%code requires {
#include "ast.h"
#include "machine_types.h"
#include "parser_types.h"
#include "lexer.h"



extern void yyerror(const char *filename, const char *msg);
}

%verbose
%define parse.lac full
%define parse.error detailed
%parse-param { char const *file_name }

%token <ident> identsym
%token <number> numbersym
%token <token> plussym "+"
%token <token> minussym "-"
%token <token> multsym "*"
%token <token> divsym "/"

%token <token> periodsym "."
%token <token> semisym ";"
%token <token> eqsym "="
%token <token> commasym ","
%token <token> becomessym ":="
%token <token> lparensym "("
%token <token> rparensym ")"

%token <token> constsym "const"
%token <token> varsym "var"
%token <token> procsym "proc"
%token <token> callsym "call"
%token <token> beginsym "begin"
%token <token> endsym "end"
%token <token> ifsym "if"
%token <token> thensym "then"
%token <token> elsesym "else"
%token <token> whilesym "while"
%token <token> dosym "do"
%token <token> readsym "read"
%token <token> printsym "print"
%token <token> divisiblesym "divisible"
%token <token> bysym "by"

%token <token> eqeqsym "=="
%token <token> neqsym "!="
%token <token> ltsym "<"
%token <token> leqsym "<="
%token <token> gtsym ">"
%token <token> geqsym ">="


%type <block> program
%type <block> block
%type <const_decls> constDecls
%type <const_decl> constDecl
%type <const_def_list> constDefList
%type <const_def> constDef
%type <var_decls> varDecls
%type <var_decl> varDecl
%type <ident_list> identList
%type <proc_decls> procDecls
%type <proc_decl> procDecl
%type <stmts> stmts
%type <empty> empty
%type <stmt_list> stmtList
%type <stmt> stmt
%type <assign_stmt> assignStmt
%type <call_stmt> callStmt
%type <if_stmt> ifStmt
%type <while_stmt> whileStmt
%type <read_stmt> readStmt
%type <print_stmt> printStmt
%type <block_stmt> blockStmt
%type <condition> condition
%type <db_condition> dbCondition
%type <rel_op_condition> relOpCondition
%type <token> relOp
%type <expr> expr
%type <expr> term
%type <expr> factor
%type <token> sign

%start program

%code {
extern int yylex(void);
block_t progast;
/* extern empty_t global_empty; */

extern void setProgAST(block_t t);
}


%%
 /* Write your grammar rules below and before the next %% */

program:
    block periodsym {setProgAST($1);}
    ;

block : beginsym constDecls varDecls procDecls stmts endsym
        { $$ = ast_block($1,$2,$3,$4,$5); }
        ;

constDecls:
    empty { $$ = ast_const_decls_empty($1); }
    | constDecls constDecl
    { $$ = ast_const_decls($1, $2); }
    ;

constDecl:
    constsym constDefList semisym { $$ = ast_const_decl($2); }
    ;

constDefList:
    constDef
    { $$ = ast_const_def_list_singleton($1); }
    | constDefList commasym constDef
    { $$ = ast_const_def_list($1, $3); }
    ;

constDef:
    identsym eqsym numbersym
    { $$ = ast_const_def($1, $3); }
    ;

varDecls:
    empty { $$ = ast_var_decls_empty($1); }
    | varDecls varDecl
    { $$ = ast_var_decls($1, $2); }
    ;


varDecl:
    varsym identList semisym { $$ = ast_var_decl($2); }
    ;

identList:
    identsym
    { $$ = ast_ident_list_singleton($1); }
    | identList commasym identsym
    { $$ = ast_ident_list($1, $3); }
    ;

procDecls:
    empty { $$ = ast_proc_decls_empty($1); }
    | procDecls procDecl
    { $$ = ast_proc_decls($1, $2); }
    ;


procDecl:
    procsym identsym block semisym
    { $$ = ast_proc_decl($2, $3); }
    ;

empty : %empty
        { file_location *file_loc
	     = file_location_make(lexer_filename(), lexer_line());
          $$ = ast_empty(file_loc);
	    }
        ;

stmtList:
    stmt
    { $$ = ast_stmt_list_singleton($1); }
    | stmtList semisym stmt
    { $$ = ast_stmt_list($1, $3); }
    ;

stmts:
    /* handle empty stmts */
    empty { $$ = ast_stmts_empty($1); }
    | stmtList
    { $$ = ast_stmts($1); }
    ;


assignStmt:
    identsym becomessym expr
    { $$ = ast_assign_stmt($1, $3); }
    ;

callStmt:
    callsym identsym
    { $$ = ast_call_stmt($2); }
    ;

ifStmt:
    ifsym condition thensym stmts elsesym stmts endsym
    { $$ = ast_if_then_else_stmt($2, $4, $6); }
    | ifsym condition thensym stmts endsym
    { $$ = ast_if_then_stmt($2, $4); }
    ;

whileStmt:
    whilesym condition dosym stmts endsym
    { $$ = ast_while_stmt($2, $4); }
    ;

readStmt:
    readsym identsym
    { $$ = ast_read_stmt($2); }
    ;

printStmt:
    printsym expr
    { $$ = ast_print_stmt($2); }
    ;

blockStmt:
    block
    { $$ = ast_block_stmt($1); }
    ; 

stmt:
    assignStmt
    { $$ = ast_stmt_assign($1); }
    | callStmt
    { $$ = ast_stmt_call($1); }
    | ifStmt
    { $$ = ast_stmt_if($1); }
    | whileStmt
    { $$ = ast_stmt_while($1); }
    | readStmt
    { $$ = ast_stmt_read($1); }
    | printStmt
    { $$ = ast_stmt_print($1); }
    | blockStmt
    { $$ = ast_stmt_block($1); }
    ;

condition:
    dbCondition
    { $$ = ast_condition_db($1); }
    | relOpCondition
    { $$ = ast_condition_rel_op($1); }
    ;

dbCondition:
    divisiblesym expr bysym expr
    { $$ = ast_db_condition($2, $4); }
    ;

relOpCondition:
    expr relOp expr
    { $$ = ast_rel_op_condition($1, $2, $3); }
    ;

relOp:
    eqeqsym { $$ = $1; }
    | neqsym { $$ = $1; }
    | ltsym { $$ = $1; }
    | leqsym { $$ = $1; }
    | gtsym { $$ = $1; }
    | geqsym { $$ = $1; }
    ;

expr :
    term

    | expr "+" term
        { $$ = ast_expr_binary_op(ast_binary_op_expr($1, $2, $3)); }
    | expr "-" term
        { $$ = ast_expr_binary_op(ast_binary_op_expr($1, $2, $3)); }
    ;

term : 
    factor 

    | term "*" factor
        { $$ = ast_expr_binary_op(ast_binary_op_expr($1, $2, $3)); } 
    | term "/" factor 
        { $$ = ast_expr_binary_op(ast_binary_op_expr($1, $2, $3)); } 
    ;

factor : identsym {$$ = ast_expr_ident($1);}
       | numbersym {$$ = ast_expr_number($1);}
       | sign factor {$$ = ast_expr_signed_expr($1, $2);}
       | "(" expr ")" {$$ = $2;}
       ;

sign : "-" 
     | "+" 
     ;

%%

void setProgAST(block_t ast) { progast = ast; }