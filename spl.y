 /* $Id: bison_spl_y_top.y,v 1.3 2024/10/31 19:24:47 leavens Exp leavens $ */

%code top {
#include <stdio.h>
}

%code requires {

 /* Including "ast.h" must be at the top, to define the AST type */
#include "ast.h"
#include "machine_types.h"
#include "parser_types.h"
#include "lexer.h"

    /* Report an error to the user on stderr */
extern void yyerror(const char *filename, const char *msg);

}    /* end of %code requires */

%verbose
%define parse.lac full
%define parse.error detailed

 /* the following passes file_name to yyerror,
    and declares it as an formal parameter of yyparse. */
%parse-param { char const *file_name }

%token <ident> identsym
%token <number> numbersym
%token <token> plussym    "+"
%token <token> minussym   "-"
%token <token> multsym    "*"
%token <token> divsym     "/"

%token <token> periodsym  "."
%token <token> semisym    ";"
%token <token> eqsym      "="
%token <token> commasym   ","
%token <token> becomessym ":="
%token <token> lparensym  "("
%token <token> rparensym  ")"

%token <token> constsym   "const"
%token <token> varsym     "var"
%token <token> procsym    "proc"
%token <token> callsym    "call"
%token <token> beginsym   "begin"
%token <token> endsym     "end"
%token <token> ifsym      "if"
%token <token> thensym    "then"
%token <token> elsesym    "else"
%token <token> whilesym   "while"
%token <token> dosym      "do"
%token <token> readsym    "read"
%token <token> printsym   "print"
%token <token> divisiblesym "divisible"
%token <token> bysym      "by"

%token <token> eqeqsym    "=="
%token <token> neqsym     "!="
%token <token> ltsym      "<"
%token <token> leqsym     "<="
%token <token> gtsym      ">"
%token <token> geqsym     ">="

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
 /* extern declarations provided by the lexer */
extern int yylex(void);

 /* The AST for the program, set by the semantic action 
    for the nonterminal program. */
block_t progast; 

 /* Set the program's ast to be t */
extern void setProgAST(block_t t);
}

%%
/* Program structure */
program:
    block { setProgAST($1); }
    ;

/* Block structure, which consists of constant declarations, variable declarations, procedure declarations, and statements */
block:
    constDecls varDecls procDecls stmtList { $$ = create_block($1, $2, $3, $4); }
    ;

/* Constant declarations */
constDecls:
    constsym constDefList semisym { $$ = create_const_decls($2); }
    | /* empty */ { $$ = create_empty_const_decls(); }
    ;

constDefList:
    constDef { $$ = create_const_def_list($1); }
    | constDefList commasym constDef { $$ = append_const_def_list($1, $3); }
    ;

constDef:
    identsym eqsym numbersym { $$ = create_const_def($1, $3); }
    ;

/* Variable declarations */
varDecls:
    varsym identList semisym { $$ = create_var_decls($2); }
    | /* empty */ { $$ = create_empty_var_decls(); }
    ;

identList:
    identsym { $$ = create_ident_list($1); }
    | identList commasym identsym { $$ = append_ident_list($1, $3); }
    ;

/* Procedure declarations */
procDecls:
    procDecl { $$ = create_proc_decls($1); }
    | procDecls procDecl { $$ = append_proc_decls($1, $2); }
    | /* empty */ { $$ = create_empty_proc_decls(); }
    ;

procDecl:
    procsym identsym semisym block semisym { $$ = create_proc_decl($2, $4); }
    ;

/* Statement list */
stmtList:
    stmt { $$ = create_stmt_list($1); }
    | stmtList semisym stmt { $$ = append_stmt_list($1, $3); }
    ;

/* Different types of statements */
stmt:
    assignStmt { $$ = $1; }
    | callStmt { $$ = $1; }
    | ifStmt { $$ = $1; }
    | whileStmt { $$ = $1; }
    | readStmt { $$ = $1; }
    | printStmt { $$ = $1; }
    ;

/* Assignment statement */
assignStmt:
    identsym becomessym expr { $$ = create_assign_stmt($1, $3); }
    ;

/* Call statement */
callStmt:
    callsym identsym { $$ = create_call_stmt($2); }
    ;

/* If statement */
ifStmt:
    ifsym condition thensym stmt { $$ = create_if_stmt($2, $4, NULL); }
    | ifsym condition thensym stmt elsesym stmt { $$ = create_if_stmt($2, $4, $6); }
    ;

/* While statement */
whileStmt:
    whilesym condition dosym stmt { $$ = create_while_stmt($2, $4); }
    ;

/* Read statement */
readStmt:
    readsym identsym { $$ = create_read_stmt($2); }
    ;

/* Print statement */
printStmt:
    printsym expr { $$ = create_print_stmt($2); }
    ;

/* Conditions */
condition:
    dbCondition { $$ = $1; }
    | relOpCondition { $$ = $1; }
    ;

/* Divisible by condition */
dbCondition:
    expr divisiblesym bysym expr { $$ = create_db_condition($1, $4); }
    ;

/* Relational operation condition */
relOpCondition:
    expr relOp expr { $$ = create_rel_op_condition($1, $2, $3); }
    ;

relOp:
    eqeqsym { $$ = create_rel_op(EQ); }
    | neqsym { $$ = create_rel_op(NEQ); }
    | ltsym { $$ = create_rel_op(LT); }
    | leqsym { $$ = create_rel_op(LEQ); }
    | gtsym { $$ = create_rel_op(GT); }
    | geqsym { $$ = create_rel_op(GEQ); }
    ;

/* Expressions */
expr:
    term { $$ = $1; }
    | expr plussym term { $$ = create_expr($1, PLUS, $3); }
    | expr minussym term { $$ = create_expr($1, MINUS, $3); }
    ;

term:
    factor { $$ = $1; }
    | term multsym factor { $$ = create_term($1, MULT, $3); }
    | term divsym factor { $$ = create_term($1, DIV, $3); }
    ;

/* Factors */
factor:
    numbersym { $$ = create_number_factor($1); }
    | identsym { $$ = create_ident_factor($1); }
    | lparensym expr rparensym { $$ = $2; }
    ;
%%

// Set the program's ast to be ast
void setProgAST(block_t ast) { progast = ast; }
