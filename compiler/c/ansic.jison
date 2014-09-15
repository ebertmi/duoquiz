/**
 * Grammar for ANSI C (with some C99 mods)
 *
 * Copyright (c) 2013 Derrell Lipman
 *
 * License:
 *   GPL Version 2: http://www.gnu.org/licenses/gpl-2.0.html
 */

%token CONSTANT_HEX CONSTANT_OCTAL CONSTANT_DECIMAL CONSTANT_CHAR CONSTANT_FLOAT
%token IDENTIFIER STRING_LITERAL SIZEOF
%token PTR_OP INC_OP DEC_OP LEFT_OP RIGHT_OP LE_OP GE_OP EQ_OP NE_OP
%token AND_OP OR_OP MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN
%token SUB_ASSIGN LEFT_ASSIGN RIGHT_ASSIGN AND_ASSIGN
%token XOR_ASSIGN OR_ASSIGN TYPE_NAME

%token TYPEDEF EXTERN STATIC AUTO REGISTER
%token CHAR SHORT INT LONG SIGNED UNSIGNED FLOAT DOUBLE CONST VOLATILE VOID
%token STRUCT UNION ENUM ELLIPSIS

%token CASE DEFAULT IF ELSE SWITCH WHILE DO FOR GOTO CONTINUE BREAK RETURN

%token LBRACE RBRACE

%nonassoc IF_WITHOUT_ELSE
%nonassoc ELSE


%start start_sym

%%

start_sym
  : translation_unit
  {
    parser.yy.R("start_sym : translation_unit");
    return $$;
  }
  ;

primary_expression
  : identifier
    {
      parser.yy.R("primary_expression : identifier");
      $$ = $1;
    }
  | constant
    {
      parser.yy.R("primary_expression : constant");
      $$ = $1;
    }
  | string_literal
    {
      parser.yy.R("primary_expression : string_literal");
      $$ = $1;
    }
  | '(' expression ')'
    {
      parser.yy.R("primary_expression : '(' expression ')'");
      $$ = ['(', $2, ')'];
    }
  ;

postfix_expression
  : primary_expression
    {
      parser.yy.R("postfix_expression : primary_expression");
      $$ = $1;
    }
  | postfix_expression '[' expression ']'
    {
      parser.yy.R("postfix_expression : postfix_expression '[' expression ']'");
      $$ = [$1, '[', $3, ']'];
    }
  | postfix_expression '(' ')'
    {
      parser.yy.R("postfix_expression : postfix_expression '(' ')'");
      $$ = [$1, '(', ')'];
    }
  | postfix_expression '(' argument_expression_list ')'
    {
      parser.yy.R("postfix_expression : " +
        "postfix_expression '(' argument_expression_list ')'");
      $$ = [$1, '(', $3, ')'];
    }
  | postfix_expression '.' identifier
    {
      parser.yy.R("postfix_expression : postfix_expression '.' identifier");
      $$ = [$1, '.', $3];
    }
  | postfix_expression PTR_OP identifier
    {
      parser.yy.R("postfix_expression : postfix_expression PTR_OP identifier");
      $$ = [$1, '->', $3];
    }
  | postfix_expression INC_OP
    {
      parser.yy.R("postfix_expression : postfix_expression INC_OP");
      $$ = [$1, '++'];
    }
  | postfix_expression DEC_OP
    {
      parser.yy.R("postfix_expression : postfix_expression DEC_OP");
      $$ = [$1, '--'];
    }
  ;

argument_expression_list
  : assignment_expression
  {
    parser.yy.R("argument_expression_list : assignment_expression");
    $$ = $1;
  }
  | argument_expression_list ',' assignment_expression
  {
    parser.yy.R("argument_expression_list : " +
      "argument_expression_list ',' assignment_expression");
    $$ = [$1, ',', $3];
  }
  ;

unary_expression
  : postfix_expression
  {
    parser.yy.R("unary_expression : postfix_expression");
    $$ = $1;
  }
  | INC_OP unary_expression
  {
    parser.yy.R("unary_expression : INC_OP unary_expression");
    $$ =  ['++', $2];
  }
  | DEC_OP unary_expression
  {
    parser.yy.R("unary_expression : DEC_OP unary_expression");
    $$ =  ['--', $2];
  }
  | unary_operator cast_expression
  {
    parser.yy.R("unary_expression : unary_operator cast_expression");
    $$ =  [$1, $2];
  }
  | SIZEOF unary_expression
  {
    parser.yy.R("unary_expression : SIZEOF unary_expression");
    $$ =  ['sizeof', $2];
  }
  | SIZEOF '(' type_name ')'
  {
    parser.yy.R("unary_expression : SIZEOF '(' type_name ')'");
    $$ = ['sizeof', '(', $3, ')'];
  }
  ;

unary_operator
  : '&'
  {
    parser.yy.R("unary_operator : '&'");
    $$ = '&';
  }
  | '*'
  {
    parser.yy.R("unary_operator : '*'");
    $$ = '*';
  }
  | '+'
  {
    parser.yy.R("unary_operator : '+'");
    $$ = '+';
  }
  | '-'
  {
    parser.yy.R("unary_operator : '-'");
    $$ = '-';
  }
  | '~'
  {
    parser.yy.R("unary_operator : '~'");
    $$ = '~';
  }
  | '!'
  {
    parser.yy.R("unary_operator : '!'");
    $$ = '!';
  }
  ;

cast_expression
  : unary_expression
  {
    parser.yy.R("cast_expression : unary_expression");
    $$ = $1;
  }
  | '(' type_name ')' cast_expression
  {
    parser.yy.R("cast_expression : '(' type_name ')' cast_expression");
    $$ = ['(', $2, ')', $4];
  }
  ;

multiplicative_expression
  : cast_expression
  {
    parser.yy.R("multiplicative_expression : cast_expression");
    $$ = $1;
  }
  | multiplicative_expression '*' cast_expression
  {
    parser.yy.R("multiplicative_expression : " +
      "multiplicative_expression '*' cast_expression");
    $$ = [$1, '*', $3];
  }
  | multiplicative_expression '/' cast_expression
  {
    parser.yy.R("multiplicative_expression : " +
      "multiplicative_expression '/' cast_expression");
    $$ = [$1, '/', $3];
  }
  | multiplicative_expression '%' cast_expression
  {
    parser.yy.R("multiplicative_expression : " +
      "multiplicative_expression '%' cast_expression");
    $$ = [$1, '%', $3];
  }
  ;

additive_expression
  : multiplicative_expression
  {
    parser.yy.R("additive_expression : multiplicative_expression");
    $$ = $1;
  }
  | additive_expression '+' multiplicative_expression
  {
    parser.yy.R("additive_expression : " +
      "additive_expression '+' multiplicative_expression");
    $$ = [$1, '+', $3];
  }
  | additive_expression '-' multiplicative_expression
  {
    parser.yy.R("additive_expression : " +
      "additive_expression '-' multiplicative_expression");
    $$ = [$1, '-', $3];
  }
  ;

shift_expression
  : additive_expression
  {
    parser.yy.R("shift_expression : additive_expression");
    $$ = $1;
  }
  | shift_expression LEFT_OP additive_expression
  {
    parser.yy.R("shift_expression : shift_expression LEFT_OP additive_expression");
    $$ = [$1, '<<', $3];
  }
  | shift_expression RIGHT_OP additive_expression
  {
    parser.yy.R("shift_expression : shift_expression RIGHT_OP additive_expression");
    $$ = [$1, '>>', $3];
  }
  ;

relational_expression
  : shift_expression
  {
    parser.yy.R("relational_expression : shift_expression");
    $$ = $1;
  }
  | relational_expression '<' shift_expression
  {
    parser.yy.R("relational_expression : relational_expression '<' shift_expression");
    $$ = [$1, '<', $3];
  }
  | relational_expression '>' shift_expression
  {
    parser.yy.R("relational_expression : relational_expression '>' shift_expression");
    $$ = [$1, '>', $3];
  }
  | relational_expression LE_OP shift_expression
  {
    parser.yy.R("relational_expression : relational_expression LE_OP shift_expression");
    $$ = [$1, '<=', $3];
  }
  | relational_expression GE_OP shift_expression
  {
    parser.yy.R("relational_expression : relational_expression GE_OP shift_expression");
    $$ = [$1, '>=', $3];
  }
  ;

equality_expression
  : relational_expression
  {
    parser.yy.R("equality_expression : relational_expression");
    $$ = $1;
  }
  | equality_expression EQ_OP relational_expression
  {
    parser.yy.R("equality_expression : equality_expression EQ_OP relational_expression");
    $$ = [$1, '==', $3];
  }
  | equality_expression NE_OP relational_expression
  {
    parser.yy.R("equality_expression : equality_expression NE_OP relational_expression");
    $$ = [$1, '!=', $3];
  }
  ;

and_expression
  : equality_expression
  {
    parser.yy.R("and_expression : equality_expression");
    $$ = $1;
  }
  | and_expression '&' equality_expression
  {
    parser.yy.R("and_expression : and_expression '&' equality_expression");
    $$ = [$1, '&', $3];
  }
  ;

exclusive_or_expression
  : and_expression
  {
    parser.yy.R("exclusive_or_expression : and_expression");
    $$ = $1;
  }
  | exclusive_or_expression '^' and_expression
  {
    parser.yy.R("exclusive_or_expression : exclusive_or_expression '^' and_expression");
    $$ = [$1, '^', $3];
  }
  ;

inclusive_or_expression
  : exclusive_or_expression
  {
    parser.yy.R("inclusive_or_expression : exclusive_or_expression");
    $$ = $1;
  }
  | inclusive_or_expression '|' exclusive_or_expression
  {
    parser.yy.R("inclusive_or_expression : " +
      "inclusive_or_expression '|' exclusive_or_expression");
    $$ = [$1, '|', $3];
  }
  ;

logical_and_expression
  : inclusive_or_expression
  {
    parser.yy.R("logical_and_expression : inclusive_or_expression");
    $$ = $1;
  }
  | logical_and_expression AND_OP inclusive_or_expression
  {
    parser.yy.R("logical_and_expression : logical_and_expression AND_OP inclusive_or_expression");
    $$ = [$1, '&&', $3];
  }
  ;

logical_or_expression
  : logical_and_expression
  {
    parser.yy.R("logical_or_expression : logical_and_expression");
    $$ = $1;
  }
  | logical_or_expression OR_OP logical_and_expression
  {
    parser.yy.R("logical_or_expression : " +
      "logical_or_expression OR_OP logical_and_expression");
    $$ = [$1, '||', $3];
  }
  ;

conditional_expression
  : logical_or_expression
  {
    parser.yy.R("conditional_expression : logical_or_expression");
    $$ = $1;
  }
  | logical_or_expression '?' expression ':' conditional_expression
  {
    parser.yy.R("conditional_expression : " +
      "logical_or_expression '?' expression ':' conditional_expression");
    $$ = [$1, '?', $3, ':', $5];
  }
  ;

assignment_expression
  : conditional_expression
  {
    parser.yy.R("assignment_expression : conditional_expression");
    $$ = $1;
  }
  | unary_expression assignment_operator assignment_expression
  {
    parser.yy.R("assignment_expression : " +
      "unary_expression assignment_operator assignment_expression");
    $$ = [$1, $3, $3];
  }
  ;

assignment_operator
  : '='
  {
    parser.yy.R("assignment_operator : '='");
    $$ = '=';
  }
  | MUL_ASSIGN
  {
    parser.yy.R("assignment_operator : MUL_ASSIGN");
    $$ = '*=';
  }
  | DIV_ASSIGN
  {
    parser.yy.R("assignment_operator : DIV_ASSIGN");
    $$ = '/=';
  }
  | MOD_ASSIGN
  {
    parser.yy.R("assignment_operator : MOD_ASSIGN");
    $$ = '%=';
  }
  | ADD_ASSIGN
  {
    parser.yy.R("assignment_operator : ADD_ASSIGN");
    $$ = '+=';
  }
  | SUB_ASSIGN
  {
    parser.yy.R("assignment_operator : SUB_ASSIGN");
    $$ = '-=';
  }
  | LEFT_ASSIGN
  {
    parser.yy.R("assignment_operator : LEFT_ASSIGN");
    $$ = '<<=';
  }
  | RIGHT_ASSIGN
  {
    parser.yy.R("assignment_operator : RIGHT_ASSIGN");
    $$ = '>>=';
  }
  | AND_ASSIGN
  {
    parser.yy.R("assignment_operator : AND_ASSIGN");
    $$ = '&=';
  }
  | XOR_ASSIGN
  {
    parser.yy.R("assignment_operator : XOR_ASSIGN");
    $$ = '^=';
  }
  | OR_ASSIGN
  {
    parser.yy.R("assignment_operator : OR_ASSIGN");
    $$ = '|=';
  }
  ;

expression
  : assignment_expression
  {
    parser.yy.R("expression : assignment_expression");
    $$ = $1;
  }
  | expression ',' assignment_expression
  {
    parser.yy.R("expression : expression ',' assignment_expression");
    $$ = [$1, ',', $3];
  }
  ;

constant_expression
  : conditional_expression
  {
    parser.yy.R("constant_expression : conditional_expression");
    $$ = $1;
  }
  ;

declaration
  : declaration_specifiers maybe_typedef_mode ';'
  {
    parser.yy.R("declaration : declaration_specifiers ';'");
    // If we were in the typedef mode, revert to the initial mode.
    parser.yy.typedefMode = 0;

    $$ = [$1, ';']; // empty declaration init
  }
  | declaration_specifiers maybe_typedef_mode init_declarator_list ';'
  {
    parser.yy.R("declaration : declaration_specifiers init_declarator_list ';'");

    // If we were in the typedef mode, revert to the initial mode.
    parser.yy.typedefMode = 0;

    $$ = [$1, $3, ';']; // non empty declaration init
  }
  ;

maybe_typedef_mode
  :
  {
    // If we'd seen 'typedef'...
    if (parser.yy.typedefMode === 1)
    {
      // ... then identifiers seen now are types
      ++parser.yy.typedefMode
    }
  }
  ;

declaration_specifiers
  : storage_class_specifier
  {
    parser.yy.R("declaration_specifiers : storage_class_specifier");
    $$ = $1;
  }
  | storage_class_specifier declaration_specifiers
  {
    parser.yy.R("declaration_specifiers : " +
      "storage_class_specifier declaration_specifiers");
    $$ = [$1, $2];
  }
  | type_specifier
  {
    parser.yy.R("declaration_specifiers : type_specifier");
    $$ = $1;
  }
  | type_specifier declaration_specifiers
  {
    parser.yy.R("declaration_specifiers : type_specifier declaration_specifiers");
    $$ = [$1, $2];
  }
  | type_qualifier
  {
    parser.yy.R("declaration_specifiers : type_qualifier");
    $$ = $1;
  }
  | type_qualifier declaration_specifiers
  {
    parser.yy.R("declaration_specifiers : type_qualifier declaration_specifiers");
    $$ = [$1, $2];
  }
  ;

init_declarator_list
  : init_declarator
  {
    parser.yy.R("init_declarator_list : init_declarator");
    $$ = $1;
  }
  | init_declarator_list ',' init_declarator
  {
    parser.yy.R("init_declarator_list : init_declarator_list ',' init_declarator");
    $$ = [$1, ',', $3];
  }
  ;

init_declarator
  : declarator
  {
    parser.yy.R("init_declarator : declarator");
    $$ = $1;     // no initializer
  }
  | declarator '=' initializer
  {
    parser.yy.R("init_declarator : declarator '=' initializer");
    $$ = [$1, '=', $3];
  }
  ;

storage_class_specifier
  : TYPEDEF
  {
    parser.yy.R("storage_class_specifier : TYPEDEF");
    parser.yy.typedefMode = 1;
    $$ = 'typedef';
  }
  | EXTERN
  {
    parser.yy.R("storage_class_specifier : EXTERN");
    $$ = 'extern';
  }
  | STATIC
  {
    parser.yy.R("storage_class_specifier : STATIC");
    $$ = 'static';
  }
  | AUTO
  {
    parser.yy.R("storage_class_specifier : AUTO");
    $$ = 'auto';
  }
  | REGISTER
  {
    parser.yy.R("storage_class_specifier : REGISTER");
    $$ = 'register';
  }
  ;

type_specifier
  : VOID
  {
    parser.yy.R("type_specifier : VOID");
    $$ = 'void';
  }
  | CHAR
  {
    parser.yy.R("type_specifier : CHAR");
    $$ = 'char';
  }
  | SHORT
  {
    parser.yy.R("type_specifier : SHORT");
    $$ = 'short';
  }
  | INT
  {
    parser.yy.R("type_specifier : INT");
    $$ = 'int';
  }
  | LONG
  {
    parser.yy.R("type_specifier : LONG");
    $$ = 'long';
  }
  | FLOAT
  {
    parser.yy.R("type_specifier : FLOAT");
    $$ = 'float';
  }
  | DOUBLE
  {
    parser.yy.R("type_specifier : DOUBLE");
    $$ = 'double';
  }
  | SIGNED
  {
    parser.yy.R("type_specifier : SIGNED");
    $$ = 'signed';
  }
  | UNSIGNED
  {
    parser.yy.R("type_specifier : UNSIGNED");
    $$ = 'unsigned';
  }
  | struct_or_union_specifier
  {
    parser.yy.R("type_specifier : struct_or_union_specifier");
    $$ = $1;
  }
  | enum_specifier
  {
    parser.yy.R("type_specifier : enum_specifier");
    $$ = $1;
  }
  | type_name_token
  {
    parser.yy.R("type_specifier : type_name_token");
    $$ = $1;
  }
  ;

struct_or_union_specifier
  : struct_or_union ns_struct identifier ns_normal lbrace struct_declaration_list rbrace
  {
    parser.yy.R("struct_or_union_specifier : " +
      "struct_or_union identifier lbrace struct_declaration_list rbrace");
    $$ = [$1, $3, '{', $6, '}'];

    // Add a symbol table entry for this struct (a type)
    parser.yy.types[$3.value] = $1.value;
  }
  | struct_or_union ns_struct ns_normal lbrace struct_declaration_list rbrace
  {
    parser.yy.R("struct_or_union_specifier : " +
      "struct_or_union lbrace struct_declaration_list rbrace");
    $$ = [$1, '{', $5, '}'];
  }
  | struct_or_union ns_struct identifier ns_normal
  {
    parser.yy.R("struct_or_union_specifier : struct_or_union identifier");
    $$ = [$1, $3];

    // Add a symbol table entry for this struct
    parser.yy.types[$3.value] = $1.value;
  }
  ;

ns_struct
  :
  {
    //playground.c.lib.Node.namespace = "struct#";
  }
  ;

ns_normal
  :
  {
    //playground.c.lib.Node.namespace = "";

    // set to true by lexer
    parser.yy.bSawStruct = false;
  }
  ;

struct_or_union
  : STRUCT
  {
    parser.yy.R("struct_or_union : STRUCT");
    $$ = 'struct';
  }
  | UNION
  {
    parser.yy.R("struct_or_union : UNION");
    $$ = 'union';
  }
  ;

struct_declaration_list
  : struct_declaration
  {
    parser.yy.R("struct_declaration_list : struct_declaration");
    $$ = $1;
  }
  | struct_declaration_list struct_declaration
  {
    parser.yy.R("struct_declaration_list : struct_declaration_list struct_declaration");
    $$ = [$1, $2];
  }
  ;

struct_declaration
  : specifier_qualifier_list struct_declarator_list ';'
  {
    parser.yy.R("struct_declaration : " +
      "specifier_qualifier_list struct_declarator_list ';'");
    $$ = [$1, $2, ';'];
  }
  ;

specifier_qualifier_list
  : type_specifier specifier_qualifier_list
  {
    parser.yy.R("specifier_qualifier_list : type_specifier specifier_qualifier_list");
    $$ = [$1, $2];
  }
  | type_specifier
  {
    parser.yy.R("specifier_qualifier_list : type_specifier");
    $$ = $1;
  }
  | type_qualifier specifier_qualifier_list
  {
    parser.yy.R("specifier_qualifier_list : type_qualifier specifier_qualifier_list");
    $$ = [$1, $2];
  }
  | type_qualifier
  {
    parser.yy.R("specifier_qualifier_list : type_qualifier");
    $$ = $1;
  }
  ;

struct_declarator_list
  : struct_declarator
  {
    parser.yy.R("struct_declarator_list : struct_declarator");
    $$ = $1;
  }
  | struct_declarator_list ',' struct_declarator
  {
    parser.yy.R("struct_declarator_list : struct_declarator_list ',' struct_declarator");
    $$ = [$1, ',', $3];
  }
  ;

struct_declarator
  : declarator
  {
    parser.yy.R("struct_declarator : declarator");
    $$ = $1;
  }
  | ':' constant_expression
  {
    parser.yy.R("struct_declarator : ':' constant_expression");
    $$ = [':', $2];
  }
  | declarator ':' constant_expression
  {
    parser.yy.R("struct_declarator : declarator ':' constant_expression");
    $$ = [$1, ':', $3];
  }
  ;

enum_specifier
  : ENUM ns_struct identifier ns_normal lbrace enumerator_list rbrace
  {
    parser.yy.R("enum : ENUM identifier lbrace enumerator_list rbrace");
    $$ = ['enum', $3, '{', $6,'}'];

    // Add a symbol table entry for this enum (a type)
    parser.yy.types[$3.value] = $1.value;
  }
  | ENUM ns_struct ns_normal lbrace enumerator_list rbrace
  {
    parser.yy.R("enum : ENUM lbrace enumerator_list rbrace");
    $$ = ['enum','{', $5,'}'];
  }
  | ENUM ns_struct identifier ns_normal
  {
    parser.yy.R("enum : ENUM identifier");
    $$ = ['enum', $3,];

    // Add a symbol table entry for this struct
    parser.yy.types[$3.value] = $1.value;
  }
  ;

enumerator_list
  : enumerator
  {
    parser.yy.R("enumerator_list : enumerator");
    $$ = $1;
  }
  | enumerator_list ',' enumerator
  {
    parser.yy.R("enumerator_list : enumerator_list ',' enumerator");
    $$ = [$1, ',', $3];
  }
  ;

enumerator
  : identifier
  {
    parser.yy.R("enumerator : identifier");
    $$ = $1; // no initializer
  }
  | identifier '=' constant_expression
  {
    parser.yy.R("enumerator : identifier '=' constant_expression");
    $$ = [$1, '=', $3];
  }
  ;

type_qualifier
  : CONST
  {
    parser.yy.R("type_qualifier : CONST");
    $$ = 'const';
  }
  | VOLATILE
  {
    parser.yy.R("type_qualifier : VOLATILE");
    $$ = 'volatile';
  }
  ;

declarator
  : pointer direct_declarator
  {
    parser.yy.R("declarator : pointer direct_declarator");
    $$ = [$1, $2];
  }
  | direct_declarator
  {
    parser.yy.R("declarator : direct_declarator");
    $$ = $1;
  }
  ;

direct_declarator
  : identifier
  {
    parser.yy.R("direct_declarator : identifier");
    $$ = $1;
  }
  | '(' declarator ')'
  {
    parser.yy.R("direct_declarator : '(' declarator ')'");
    $$ = ['(', $2, ')'];
  }
  | direct_declarator '[' constant_expression ']'
  {
    parser.yy.R("direct_declarator : direct_declarator '[' constant_expression ']'");
    $$ = [$1, '[', $3, ']'];
  }
  | direct_declarator '[' ']'
  {
    parser.yy.R("direct_declarator : direct_declarator '[' ']'");
    $$ = [$1, '[', ']'];
  }
  | direct_declarator function_scope '(' parameter_type_list ')'
  {
    parser.yy.R("direct_declarator : " +
      "direct_declarator '(' parameter_type_list ')'");
    $$ = [$1, $2, '(', $4, ')'];
  }
/* Don't support K&R-style declarations...
  | direct_declarator function_scope '(' identifier_list ')'
  {
    parser.yy.R("direct_declarator : " +
      "direct_declarator '(' identifier_list ')'");
    $$ = [$1, $2, '(', $4, ')'];
  }
// ... and require 'void' for parameter list if no formal parameters
  | direct_declarator function_scope '(' ')'
  {
    parser.yy.R("direct_declarator : direct_declarator '(' ')'");
    $$ = [$1, $2, '(', ')'];
  }
*/
  ;

pointer
  : '*'
  {
    parser.yy.R("pointer : '*'");
    $$ = '*';
  }
  | '*' type_qualifier_list
  {
    parser.yy.R("pointer : '*' type_qualifier_list");
    $$ = ['*', $2];
  }
  | '*' pointer
  {
    parser.yy.R("pointer : '*' pointer");
    $$ = ['*', $2];
  }
  | '*' type_qualifier_list pointer
  {
    parser.yy.R("pointer : '*' type_qualifier_list pointer");
    $$ = ['*', $2, $3];
  }
  ;

type_qualifier_list
  : type_qualifier
  {
    parser.yy.R("type_qualifier_list : type_qualifier");
    $$ = $1;
  }
  | type_qualifier_list type_qualifier
  {
    parser.yy.R("type_qualifier_list : type_qualifier_list type_qualifier");
    $$ = [$1, $2];
  }
  ;


parameter_type_list
  : parameter_list
  {
    parser.yy.R("parameter_type_list : parameter_list");
    $$ = $1;
  }
  | parameter_list ',' ellipsis
  {
    parser.yy.R("parameter_type_list : parameter_list ',' ellipsis");
    $$ = [$1, ',', $3];
  }
  ;

parameter_list
  : parameter_declaration
  {
    parser.yy.R("parameter_list : parameter_declaration");
    $$ = $1;
  }
  | parameter_list ',' parameter_declaration
  {
    parser.yy.R("parameter_list : parameter_list ',' parameter_declaration");
    $$ = [$1, ',', $3];
  }
  ;

parameter_declaration
  : declaration_specifiers declarator
  {
    parser.yy.R("parameter_declaration : declaration_specifiers declarator");
    $$ = [$1, $2];
  }
  | declaration_specifiers abstract_declarator
  {
    parser.yy.R("parameter_declaration : declaration_specifiers abstract_declarator");
    $$ = [$1, $2];
  }
  | declaration_specifiers
  {
    parser.yy.R("parameter_declaration : declaration_specifiers");
    $$ = $1;
  }
  ;

identifier_list
  : identifier
  {
    parser.yy.R("identifier_list : identifier");
    $$ = $1;
  }
  | identifier_list ',' identifier
  {
    parser.yy.R("identifier_list : identifier_list ',' identifier");
    $$ = [$1, ',', $3];
  }
  ;

type_name
  : specifier_qualifier_list
  {
    parser.yy.R("type_name : specifier_qualifier_list");
    $$ = $1;
  }
  | specifier_qualifier_list abstract_declarator
  {
    parser.yy.R("type_name : specifier_qualifier_list abstract_declarator");
    $$ = [$1, $2];
  }
  ;

abstract_declarator
  : pointer
  {
    parser.yy.R("abstract_declarator : pointer");
    $$ = $1;
  }
  | direct_abstract_declarator
  {
    parser.yy.R("abstract_declarator : direct_abstract_declarator");
    $$ = $1;
  }
  | pointer direct_abstract_declarator
  {
    parser.yy.R("abstract_declarator : pointer direct_abstract_declarator");
    $$ = [$1, $2];
  }
  ;

direct_abstract_declarator
  : '(' abstract_declarator ')'
  {
    parser.yy.R("direct_abstract_declarator : '(' abstract_declarator ')'");
    $$ = ['(', $2, ')'];
  }
  | '[' ']'
  {
    parser.yy.R("direct_abstract_declarator : '[' ']'");
    $$ = ['[', ']'];
  }
  | '[' constant_expression ']'
  {
    parser.yy.R("direct_abstract_declarator : '[' constant_expression ']'");
    $$ = ['[', $2, ']'];
  }
  | direct_abstract_declarator '[' ']'
  {
    parser.yy.R("direct_abstract_declarator : direct_abstract_declarator '[' ']'");
    $$ = [$1, '[', ']'];
  }
  | direct_abstract_declarator '[' constant_expression ']'
  {
    parser.yy.R("direct_abstract_declarator : " +
      "direct_abstract_declarator '[' constant_expression ']'");
    $$ = [$1, '[', $3, ']'];
  }
  | '(' ')'
  {
    parser.yy.R("direct_abstract_declarator : '(' ')'");
    $$ = ['(', ')'];
  }
  | '(' parameter_type_list ')'
  {
    parser.yy.R("direct_abstract_declarator : '(' parameter_type_list ')'");
    $$ = ['(', $3, ')'];
  }
  | direct_abstract_declarator '(' ')'
  {
    parser.yy.R("direct_abstract_declarator : direct_abstract_declarator '(' ')'");
    $$ = [$1, '(', ')'];
  }
  | direct_abstract_declarator '(' parameter_type_list ')'
  {
    parser.yy.R("direct_abstract_declarator : " +
      "direct_abstract_declarator '(' parameter_type_list ')'");
    $$ = [$1, '(', $3, ')'];
  }
  ;

initializer
  : assignment_expression
  {
    parser.yy.R("initializer : assignment_expression");
    $$ = $1;
  }
  | lbrace initializer_list rbrace
  {
    parser.yy.R("initializer : lbrace initializer_list rbrace");
    $$ = $2;
  }
  | lbrace initializer_list ',' rbrace
  {
    parser.yy.R("initializer : lbrace initializer_list ',' rbrace");
    $$ = $2;
  }
  ;

initializer_list
  : initializer
  {
    parser.yy.R("initializer_list : initializer");
    $$ = $1;
  }
  | initializer_list ',' initializer
  {
    parser.yy.R("initializer_list : initializer_list ',' initializer");
    $$ = [$1, ',', $3];
  }
  ;

statement
  : labeled_statement
  {
    parser.yy.R("statement : labeled_statement");
    $$ = $1;
  }
  | compound_statement
  {
    parser.yy.R("statement : compound_statement");
    $$ = $1;
  }
  | expression_statement
  {
    parser.yy.R("statement : expression_statement");
    $$ = $1;
  }
  | selection_statement
  {
    parser.yy.R("statement : selection_statement");
    $$ = $1;
  }
  | iteration_statement
  {
    parser.yy.R("statement : iteration_statement");
    $$ = $1;
  }
  | jump_statement
  {
    parser.yy.R("statement : jump_statement");
    $$ = $1;
  }
  | error
  {
    parser.yy.R("statement : error");
  }
  ;

labeled_statement
  : identifier ':' statement
  {
    parser.yy.R("labeled_statement : identifier ':' statement");
    $$ = [$1, ':', $3];
  }
  | CASE constant_expression ':' statement
  {
    parser.yy.R("labeled_statement : CASE constant_expression ':' statement");
    $$ = ['case', $2, ':', $4];
  }
  | DEFAULT ':' statement
  {
    parser.yy.R("labeled_statement : DEFAULT ':' statement");
      $$ = ['default', ':', $3];
  }
  ;

compound_statement
  : lbrace_scope rbrace_scope
  {
    parser.yy.R("compound_statement : lbrace_scope rbrace_scope");
    $$ = [$1, $2];
  }
  | lbrace_scope statement_list rbrace_scope
  {
    parser.yy.R("compound_statement : lbrace_scope statement_list rbrace_scope");
    $$ = [$1, $2, $3];
  }
  | lbrace_scope declaration_list rbrace_scope
  {
    parser.yy.R("compound_statement : lbrace_scope declaration_list rbrace_scope");
    $$ = [$1, $2, $3];
  }
  | lbrace_scope declaration_list statement_list rbrace_scope
  {
    parser.yy.R("compound_statement : lbrace_scope declaration_list statement_list rbrace_scope");
    $$ = [$1, $2, $3, $4];
  }
  ;

declaration_list
  : declaration
  {
    parser.yy.R("declaration_list : declaration");
    $$ = $1;
  }
  | declaration_list declaration
  {
    parser.yy.R("declaration_list : declaration_list declaration");
    $$ = [$1, $2];
  }
  ;

statement_list
  : statement
  {
    parser.yy.R("statement_list : statement");
    $$ = $1;
  }
  | statement_list statement
  {
    parser.yy.R("statement_list : statement_list statement");
    $$ = [$1, $2];
  }
  | statement_list save_position declaration
  {
    parser.parseError(
      "Declarations must precede executable statements.",
      { line : yylineno },
      $2);
  }
  ;

save_position
  :
  {
    $$ = parser.lexer.showPosition();
  }
  ;

expression_statement
  : ';'
  {
    parser.yy.R("expression_statement : ';'");
    $$ = ';';
  }
  | expression ';'
  {
    parser.yy.R("expression_statement : expression ';'");
    $$ = [$1, ';'];
  }
  ;

selection_statement
  : IF '(' expression ')' statement %prec IF_WITHOUT_ELSE
  {
    parser.yy.R("selection_statement : IF '(' expression ')' statement");
    $$ = ['if', '(', $3, ')', $5];
  }
  | IF '(' expression ')' statement ELSE statement
  {
    parser.yy.R("selection_statement : IF '(' expression ')' statement ELSE statement");
    $$ = ['if', '(', $3, ')', $5, 'else', $7];
  }
  | SWITCH '(' expression ')' statement
  {
    parser.yy.R("selection_statement : SWITCH '(' expression ')' statement");
    $$ = ['switch', '(', $3, ')', $5];
  }
  ;

iteration_statement
  : WHILE '(' expression ')' statement
  {
    parser.yy.R("iteration_statement : WHILE '(' expression ')' statement");
    $$ = ['while', '(', $3, ')', $5];
  }
  | DO statement WHILE '(' expression ')' ';'
  {
    parser.yy.R("iteration_statement : DO statement WHILE '(' expression ')' ';'");
    $$ = ['do', $2, 'while', '(', $5, ')', ';'];
  }
  | FOR '(' expression_statement expression_statement ')' statement
  {
    parser.yy.R("iteration_statement : FOR '(' expression_statement expression_statement ')' statement");
    $$ = ['for', $3, $4, ')', $6];
  }
  | FOR '(' expression_statement expression_statement expression ')' statement
  {
    parser.yy.R("iteration_statement : " +
      "FOR '(' expression_statement expression_statement expression ')' " +
      "statement");
    $$ = ['for', '(',  $3,  $5, $6, $7 ];
  }
  ;

jump_statement
  : GOTO identifier ';'
  {
    parser.yy.R("jump_statement : GOTO identifier ';'");
    $$ = ['goto', $2, ';'];
  }
  | CONTINUE ';'
  {
    parser.yy.R("jump_statement : CONTINUE ';'");
    $$ = ['continue', ';'];
  }
  | BREAK ';'
  {
    parser.yy.R("jump_statement : BREAK ';'");
    $$ = ['break', ';'];
  }
  | RETURN ';'
  {
    parser.yy.R("jump_statement : RETURN ';'");
    $$ = ['return', ';'];
  }
  | RETURN expression ';'
  {
    parser.yy.R("jump_statement : RETURN expression ';'");
    $$ = ['return', $2, ';'];
  }
  ;

translation_unit
  : external_declaration
    {
      parser.yy.R("translation_unit : external_declaration");
      $$ = $1;
    }
  | translation_unit external_declaration
    {
      parser.yy.R("translation_unit : translation_unit external_declaration");
      $$ = [$1, $2];
    }
  ;

external_declaration
  : function_definition
  {
    parser.yy.R("external_declaration : function_definition");
    $$ = $1;
  }
  | declaration
  {
    parser.yy.R("external_declaration : declaration");
    $$ = $1;
  }
  ;

function_definition
/* Don't support K&R-style declarations...
  : declaration_specifiers maybe_typedef_mode declarator declaration_list compound_statement
  {
    parser.yy.R("function_definition : " +
      "declaration_specifiers declarator declaration_list compound_statement");
    $$ = [$1, $3, $4, $5];
  }
*/
  : declaration_specifiers maybe_typedef_mode declarator compound_statement
  {
    parser.yy.R("function_definition : " +
      "declaration_specifiers declarator compound_statement");
    $$ = [$1, $3, $4];
  }
/* Don't support K&R-style declarations...
  | declarator declaration_list compound_statement
  {
    parser.yy.R("function_definition : declarator declaration_list compound_statement");
    $$ = [$1, $2, $3];
  }
*/
  | declarator compound_statement
  {
    parser.yy.R("function_definition : declarator compound_statement");
    $$ = [$1, $2];
  }
  ;

function_scope
  :
  {
    $$ = $1;
  }
  ;

identifier
  : IDENTIFIER
  {
    if (parser.yy.typedefMode === 2)
    {
      parser.yy.R("identifier : TYPE_DEFINITION (" + yytext + ")");
      $$ = yytext;
      parser.yy.types[yytext] = 'TYPE_DEFINITION';
    } else {
      parser.yy.R("identifier : IDENTIFIER (" + yytext + ")");
      $$ = yytext;
    }
  }
  ;

type_name_token
  : TYPE_NAME
  {
    parser.yy.R("identifier : TYPE_NAME (" + yytext + ")");
    $$ = yytext;
  }
  ;

constant
  : CONSTANT_HEX
  {
    parser.yy.R("constant : CONSTANT_HEX (" + yytext + ")");

    $$ = $1;
  }
  | CONSTANT_OCTAL
  {
    parser.yy.R("constant : CONSTANT_OCTAL (" + yytext + ")");

    $$ = $1;
  }
  | CONSTANT_DECIMAL
  {
    parser.yy.R("constant : CONSTANT_DECIMAL (" + yytext + ")");

    $$ = $1;
  }
  | CONSTANT_CHAR
  {
    parser.yy.R("constant : CONSTANT_CHAR (" + yytext + ")");
    $$ = $1;
  }
  | CONSTANT_FLOAT
  {
    parser.yy.R("constant : CONSTANT (" + yytext + ")");
    $$ = $1;
  }
  ;


string_literal
  : STRING_LITERAL
  {
    parser.yy.R("string_literal : STRING_LITERAL");
    $$ = $1;
  }
  ;

ellipsis
  : ELLIPSIS
  {
    parser.yy.R("ellipsis : ELLIPSIS");
    $$ = '...';
  }
  ;

lbrace_scope
  : lbrace
  {
    parser.yy.R("lbrace_scope : lbrace");
    $$ = $1;
  }
  ;

rbrace_scope
  : rbrace
  {
    parser.yy.R("rbrace_scope : rbrace");
    $$ = $1;
  }
  ;

lbrace
  : LBRACE
  {
    parser.yy.R("lbrace : LBRACE");
    $$ =  $1;
  }
  ;

rbrace
  : RBRACE
  {
    parser.yy.R("rbrace : RBRACE");
    $$ = $1;
  }
  ;

%%

parser.yy.R = function(entry) {
  console.log(entry);
};


parser.yy.bSawStruct = false;

parser.yy.typedefMode = 0;
parser.yy.types = {};

parser.yy.isType = function(type) {
  if(!type || !type.length || type.length === 0) {
    return false;
  }

  return parser.yy.types.hasOwnProperty(type);
};
