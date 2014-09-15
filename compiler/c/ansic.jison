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
    $$ = new playground.c.lib.Node("declaration_specifiers", yytext, yylineno);
    $$.children.unshift($1);
  }
  | storage_class_specifier declaration_specifiers
  {
    parser.yy.R("declaration_specifiers : " +
      "storage_class_specifier declaration_specifiers");
    $$ = $2;
    $$.children.unshift($1);
  }
  | type_specifier
  {
    parser.yy.R("declaration_specifiers : type_specifier");
    $$ = new playground.c.lib.Node("declaration_specifiers", yytext, yylineno);
    $$.children.unshift($1);
  }
  | type_specifier declaration_specifiers
  {
    parser.yy.R("declaration_specifiers : type_specifier declaration_specifiers");
    $$ = $2;
    $$.children.unshift($1);
  }
  | type_qualifier
  {
    parser.yy.R("declaration_specifiers : type_qualifier");
    $$ = new playground.c.lib.Node("declaration_specifiers", yytext, yylineno);
    $$.children.unshift($1);
  }
  | type_qualifier declaration_specifiers
  {
    parser.yy.R("declaration_specifiers : type_qualifier declaration_specifiers");
    $$ = $2;
    $$.children.unshift($1);
  }
  ;

init_declarator_list
  : init_declarator
  {
    parser.yy.R("init_declarator_list : init_declarator");
    $$ = new playground.c.lib.Node("init_declarator_list", yytext, yylineno);
    $$.children.push($1);
  }
  | init_declarator_list ',' init_declarator
  {
    parser.yy.R("init_declarator_list : init_declarator_list ',' init_declarator");
    $$ = $1;
    $$.children.push($3);
  }
  ;

init_declarator
  : declarator
  {
    parser.yy.R("init_declarator : declarator");
    $$ = new playground.c.lib.Node("init_declarator", yytext, yylineno);
    $$.children.push($1);
    $$.children.push(playground.c.lib.Node.getNull(yylineno));     // no initializer
  }
  | declarator '=' initializer
  {
    parser.yy.R("init_declarator : declarator '=' initializer");
    $$ = new playground.c.lib.Node("init_declarator", yytext, yylineno);
    $$.children.push($1);
    $$.children.push($3);
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
    $$ = [$1, $2, $3, $4, '{', $6, '}'];

    // Add a symbol table entry for this struct (a type)
    parser.yy.types[$3.value] = $1.value;
  }
  | struct_or_union ns_struct ns_normal lbrace struct_declaration_list rbrace
  {
    parser.yy.R("struct_or_union_specifier : " +
      "struct_or_union lbrace struct_declaration_list rbrace");

        // Create an identifier node
    //identifier = new playground.c.lib.Node("identifier", yytext, yylineno);
    //identifier.value = "struct#" + playground.c.lib.Symtab.getUniqueId();

    $$ = [$1, $2, $3, '{', $5, '}'];
  }
  | struct_or_union ns_struct identifier ns_normal
  {
    parser.yy.R("struct_or_union_specifier : struct_or_union identifier");
    $$ = $1;
    $$.children.push(playground.c.lib.Node.getNull(yylineno)); // no declaration list
    $$.children.push($3);

    // Add a symbol table entry for this struct
    playground.c.lib.Symtab.getCurrent().add($3.value, yylineno, true);
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
    $$ = new playground.c.lib.Node("struct_declaration_list", yytext, yylineno);
    $$.children.push($1);
  }
  | struct_declaration_list struct_declaration
  {
    parser.yy.R("struct_declaration_list : struct_declaration_list struct_declaration");
    $$ = $1;
    $$.children.push($2);
  }
  ;

struct_declaration
  : specifier_qualifier_list struct_declarator_list ';'
  {
    parser.yy.R("struct_declaration : " +
      "specifier_qualifier_list struct_declarator_list ';'");
    $$ = new playground.c.lib.Node("struct_declaration", yytext, yylineno);
    $$.children.push($1);
    $$.children.push($2);
  }
  ;

specifier_qualifier_list
  : type_specifier specifier_qualifier_list
  {
    parser.yy.R("specifier_qualifier_list : type_specifier specifier_qualifier_list");
    $$ = $2;
    $$.children.unshift($1);
  }
  | type_specifier
  {
    parser.yy.R("specifier_qualifier_list : type_specifier");
    $$ =
      new playground.c.lib.Node("specifier_qualifier_list", yytext, yylineno);
    $$.children.unshift($1);
  }
  | type_qualifier specifier_qualifier_list
  {
    parser.yy.R("specifier_qualifier_list : type_qualifier specifier_qualifier_list");
    $$ = $2;
    $$.children.unshift($1);
  }
  | type_qualifier
  {
    parser.yy.R("specifier_qualifier_list : type_qualifier");
    $$ =
      new layground.c.lib.Node("specifier_qualifier_list", yytext, yylineno);
    $$.children.unshift($1);
  }
  ;

struct_declarator_list
  : struct_declarator
  {
    parser.yy.R("struct_declarator_list : struct_declarator");
    $$ = new playground.c.lib.Node("struct_declarator_list", yytext, yylineno);
    $$.children.push($1);
  }
  | struct_declarator_list ',' struct_declarator
  {
    parser.yy.R("struct_declarator_list : struct_declarator_list ',' struct_declarator");
    $$ = $1;
    $$.children.push($3);
  }
  ;

struct_declarator
  : declarator
  {
    parser.yy.R("struct_declarator : declarator");
    $$ = new playground.c.lib.Node("struct_declarator", yytext, yylineno);
    $$.children.push($1);
    $$.children.push(playground.c.lib.Node.getNull(yylineno)); // no bitfield
  }
  | ':' constant_expression
  {
    parser.yy.R("struct_declarator : ':' constant_expression");
    $$ = new playground.c.lib.Node("struct_declarator", yytext, yylineno);
    $$.children.push(playground.c.lib.Node.getNull(yylineno)); // no declarator
    $$.children.push($2);
  }
  | declarator ':' constant_expression
  {
    parser.yy.R("struct_declarator : declarator ':' constant_expression");
    $$ = new playground.c.lib.Node("struct_declarator", yytext, yylineno);
    $$.children.push($1);
    $$.children.push($3);
  }
  ;

enum_specifier
  : ENUM ns_struct identifier ns_normal lbrace enumerator_list rbrace
  {
    parser.yy.R("enum : ENUM identifier lbrace enumerator_list rbrace");
    $$ = new playground.c.lib.Node("enum", yytext, yylineno);
    $$.children.push($6);
    $$.children.push($3);

    // Add a symbol table entry for this enum (a type)
    playground.c.lib.Symtab.getCurrent().add($3.value, yylineno, true);
  }
  | ENUM ns_struct ns_normal lbrace enumerator_list rbrace
  {
    var             identifier;

    parser.yy.R("enum : ENUM lbrace enumerator_list rbrace");
    $$ = new playground.c.lib.Node("enum", yytext, yylineno);
    $$.children.push($5);

    // Create an identifier node
    identifier = new playground.c.lib.Node("identifier", yytext, yylineno);
    identifier.value = "struct#" + playground.c.lib.Symtab.getUniqueId();

    // Add a symbol table entry for this struct (a type)
    playground.c.lib.Symtab.getCurrent().add(identifier.value, yylineno, true);

    // Add the identifier
    $$.children.push(identifier);
  }
  | ENUM ns_struct identifier ns_normal
  {
    parser.yy.R("enum : ENUM identifier");
    $$ = new playground.c.lib.Node("enum", yytext, yylineno);
    $$.children.push(playground.c.lib.Node.getNull(yylineno)); // no enumerator_list
    $$.children.push($3);

    // Add a symbol table entry for this struct
    playground.c.lib.Symtab.getCurrent().add($3.value, yylineno, true);
  }
  ;

enumerator_list
  : enumerator
  {
    parser.yy.R("enumerator_list : enumerator");
    $$ = new playground.c.lib.Node("enumerator_list", yytext, yylineno);
    $$.children.push($1);
  }
  | enumerator_list ',' enumerator
  {
    parser.yy.R("enumerator_list : enumerator_list ',' enumerator");
    $$ = $1;
    $$.children.push($3);
  }
  ;

enumerator
  : identifier
  {
    parser.yy.R("enumerator : identifier");
    $$ = new playground.c.lib.Node("enumerator", yytext, yylineno);
    $$.children.push($1);
    $$.children.push(playground.c.lib.Node.getNull(yylineno)); // no initializer
  }
  | identifier '=' constant_expression
  {
    parser.yy.R("enumerator : identifier '=' constant_expression");
    $$ = new playground.c.lib.Node("enumerator", yytext, yylineno);
    $$.children.push($1);
    $$.children.push($3);
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
    $$ = new playground.c.lib.Node("declarator", yytext, yylineno);
    $$.children.push($2);
    $$.children.push($1);
  }
  | direct_declarator
  {
    parser.yy.R("declarator : direct_declarator");
    $$ = new playground.c.lib.Node("declarator", yytext, yylineno);
    $$.children.push($1);
    $$.children.push(playground.c.lib.Node.getNull(yylineno));
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
    $$ = $2;
  }
  | direct_declarator '[' constant_expression ']'
  {
    parser.yy.R("direct_declarator : direct_declarator '[' constant_expression ']'");

    var             array_decl;

    $$ = $1;
    array_decl = new playground.c.lib.Node("array_decl", yytext, yylineno);
    array_decl.children.push($3);
    $$.children.push(array_decl);
  }
  | direct_declarator '[' ']'
  {
    parser.yy.R("direct_declarator : direct_declarator '[' ']'");

    var             array_decl;

    $$ = $1;
    array_decl = new playground.c.lib.Node("array_decl", yytext, yylineno);
    $$.children.push(array_decl);
  }
  | direct_declarator function_scope '(' parameter_type_list ')'
  {
    parser.yy.R("direct_declarator : " +
      "direct_declarator '(' parameter_type_list ')'");

    $$ = new playground.c.lib.Node("function_decl", yytext, yylineno);
    $$.children.push($1);
    $$.children.push($4);
    $$.children.push(playground.c.lib.Node.getNull(yylineno));     // no identifier_list
  }
/* Don't support K&R-style declarations...
  | direct_declarator function_scope '(' identifier_list ')'
  {
    parser.yy.R("direct_declarator : " +
      "direct_declarator '(' identifier_list ')'");

    $$ = new playground.c.lib.Node("function_decl", yytext, yylineno);
    $$.children.push($1);
    $$.children.push(playground.c.lib.Node.getNull(yylineno));     // no parameter_type_list
    $$.children.push($4);
  }
// ... and require 'void' for parameter list if no formal parameters
  | direct_declarator function_scope '(' ')'
  {
    parser.yy.R("direct_declarator : direct_declarator '(' ')'");

    $$ = new playground.c.lib.Node("function_decl", yytext, yylineno);
    $$.children.push($1);
    $$.children.push(playground.c.lib.Node.getNull(yylineno));     // no parameter_type_list
    $$.children.push(playground.c.lib.Node.getNull(yylineno));     // no identifier_list
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
    $$ = new playground.c.lib.Node("type_qualifier_list", yytext, yylineno);
    $$.children.push($1);
  }
  | type_qualifier_list type_qualifier
  {
    parser.yy.R("type_qualifier_list : type_qualifier_list type_qualifier");
    $$ = $1;
    $$.children.push($2);
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
    $$ = $1;
    $$.children.push($3);
  }
  ;

parameter_list
  : parameter_declaration
  {
    parser.yy.R("parameter_list : parameter_declaration");
    $$ = new playground.c.lib.Node("parameter_list", yytext, yylineno);
    $$.children.push($1);
  }
  | parameter_list ',' parameter_declaration
  {
    parser.yy.R("parameter_list : parameter_list ',' parameter_declaration");
    $$ = $1;
    $$.children.push($3);
  }
  ;

parameter_declaration
  : declaration_specifiers declarator
  {
    parser.yy.R("parameter_declaration : declaration_specifiers declarator");
    $$ = new playground.c.lib.Node("parameter_declaration", yytext, yylineno);
    $$.children.push($1);
    $$.children.push($2);
    $$.children.push(playground.c.lib.Node.getNull(yylineno));     // no abstract declarator
  }
  | declaration_specifiers abstract_declarator
  {
    parser.yy.R("parameter_declaration : declaration_specifiers abstract_declarator");
    $$ = new playground.c.lib.Node("parameter_declaration", yytext, yylineno);
    $$.children.push($1);
    $$.children.push(playground.c.lib.Node.getNull(yylineno));     // no declarator
    $$.children.push($2);
  }
  | declaration_specifiers
  {
    parser.yy.R("parameter_declaration : declaration_specifiers");
    $$ = new playground.c.lib.Node("parameter_declaration", yytext, yylineno);
    $$.children.push($1);
    $$.children.push(playground.c.lib.Node.getNull(yylineno));     // no declarator
    $$.children.push(playground.c.lib.Node.getNull(yylineno));     // no abstract declarator
  }
  ;

identifier_list
  : identifier
  {
    parser.yy.R("identifier_list : identifier");
    $$ = new playground.c.lib.Node("identifier_list", yytext, yylineno);
    $$.children.push($1);
  }
  | identifier_list ',' identifier
  {
    parser.yy.R("identifier_list : identifier_list ',' identifier");
    $$ = $1;
    $$.children.push($3);
  }
  ;

type_name
  : specifier_qualifier_list
  {
    parser.yy.R("type_name : specifier_qualifier_list");
    $$ = new playground.c.lib.Node("type_name", yytext, yylineno);
    $$.children.push($1);
    $$.children.push(playground.c.lib.Node.getNull(yylineno));     // no abstract declarator
  }
  | specifier_qualifier_list abstract_declarator
  {
    parser.yy.R("type_name : specifier_qualifier_list abstract_declarator");
    $$ = new playground.c.lib.Node("type_name", yytext, yylineno);
    $$.children.push($1);
    $$.children.push($2);
  }
  ;

abstract_declarator
  : pointer
  {
    parser.yy.R("abstract_declarator : pointer");
    $$ = new playground.c.lib.Node("abstract_declarator", yytext, yylineno);
    $$.children.push($1);
    $$.children.push(playground.c.lib.Node.getNull(yylineno));     // no abstract_declarator
  }
  | direct_abstract_declarator
  {
    parser.yy.R("abstract_declarator : direct_abstract_declarator");
    $$ = new playground.c.lib.Node("abstract_declarator", yytext, yylineno);
    $$.children.push(playground.c.lib.Node.getNull(yylineno));     // no pointer
    $$.children.push($1);
  }
  | pointer direct_abstract_declarator
  {
    parser.yy.R("abstract_declarator : pointer direct_abstract_declarator");
    $$ = new playground.c.lib.Node("abstract_declarator", yytext, yylineno);
    $$.children.push($1);
    $$.children.push($2);
  }
  ;

direct_abstract_declarator
  : '(' abstract_declarator ')'
  {
    parser.yy.R("direct_abstract_declarator : '(' abstract_declarator ')'");
    $$ =
      new playground.c.lib.Node("direct_abstract_declarator", yytext, yylineno);
    $$.children.push($2);
  }
  | '[' ']'
  {
    parser.yy.R("direct_abstract_declarator : '[' ']'");

    var             array_decl;

    $$ =
      new playground.c.lib.Node("direct_abstract_declarator", yytext, yylineno);
    array_decl = new playground.c.lib.Node("array_decl", yytext, yylineno);
    $$.children.push(array_decl);
  }
  | '[' constant_expression ']'
  {
    parser.yy.R("direct_abstract_declarator : '[' constant_expression ']'");

    var             array_decl;

    $$ =
      new playground.c.lib.Node("direct_abstract_declarator", yytext, yylineno);
    array_decl = new playground.c.lib.Node("array_decl", yytext, yylineno);
    array_decl.children.push($2);
    $$.children.push(array_decl);
  }
  | direct_abstract_declarator '[' ']'
  {
    parser.yy.R("direct_abstract_declarator : direct_abstract_declarator '[' ']'");

    var             array_decl;
    var             child;

    $$ = $1;
    child =
      new playground.c.lib.Node("direct_abstract_declarator", yytext, yylineno);
    array_decl = new playground.c.lib.Node("array_decl", yytext, yylineno);
    child.children.push(array_decl);
    $$.children.push(child);
  }
  | direct_abstract_declarator '[' constant_expression ']'
  {
    parser.yy.R("direct_abstract_declarator : " +
      "direct_abstract_declarator '[' constant_expression ']'");

    var             array_decl;
    var             child;

    $$ = $1;
    child =
      new playground.c.lib.Node("direct_abstract_declarator", yytext, yylineno);
    array_decl = new playground.c.lib.Node("array_decl", yytext, yylineno);
    array_decl.children.push($3);
    child.children.push(array_decl);
    $$.children.push(child);
  }
  | '(' ')'
  {
    parser.yy.R("direct_abstract_declarator : '(' ')'");
    $$ =
      new playground.c.lib.Node("direct_abstract_declarator", yytext, yylineno);
  }
  | '(' parameter_type_list ')'
  {
    parser.yy.R("direct_abstract_declarator : '(' parameter_type_list ')'");
    $$ =
      new playground.c.lib.Node("direct_abstract_declarator", yytext, yylineno);
    $$.children.push($2);
  }
  | direct_abstract_declarator '(' ')'
  {
    parser.yy.R("direct_abstract_declarator : direct_abstract_declarator '(' ')'");

    var             child;

    $$ = $1;
    child =
      new playground.c.lib.Node("direct_abstract_declarator", yytext, yylineno);
    $$.children.push(child);
  }
  | direct_abstract_declarator '(' parameter_type_list ')'
  {
    parser.yy.R("direct_abstract_declarator : " +
      "direct_abstract_declarator '(' parameter_type_list ')'");

    var             child;

    $$ = $1;
    child =
      new playground.c.lib.Node("direct_abstract_declarator", yytext, yylineno);
    child.children.push($2);
    $$.children.push(child);
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
    $$ = new playground.c.lib.Node("initializer_list", yytext, yylineno);
    $$.children.push($1);
  }
  | initializer_list ',' initializer
  {
    parser.yy.R("initializer_list : initializer_list ',' initializer");
    $$ = $1;
    $$.children.push($3);
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
    $$ = new playground.c.lib.Node("compound_statement", yytext, yylineno);
    $$.children.push(playground.c.lib.Node.getNull(yylineno));     // no declaration list
    $$.children.push(playground.c.lib.Node.getNull(yylineno));     // no statement list
  }
  | lbrace_scope statement_list rbrace_scope
  {
    parser.yy.R("compound_statement : lbrace_scope statement_list rbrace_scope");
    $$ = new playground.c.lib.Node("compound_statement", yytext, yylineno);
    $$.children.push(playground.c.lib.Node.getNull(yylineno));     // no declaration_list
    $$.children.push($2);
  }
  | lbrace_scope declaration_list rbrace_scope
  {
    parser.yy.R("compound_statement : lbrace_scope declaration_list rbrace_scope");
    $$ = new playground.c.lib.Node("compound_statement", yytext, yylineno);
    $$.children.push($2);
    $$.children.push(playground.c.lib.Node.getNull(yylineno));     // no statement list
  }
  | lbrace_scope declaration_list statement_list rbrace_scope
  {
    parser.yy.R("compound_statement : lbrace_scope declaration_list statement_list rbrace_scope");
    $$ = new playground.c.lib.Node("compound_statement", yytext, yylineno);
    $$.children.push($2);
    $$.children.push($3);
  }
  ;

declaration_list
  : declaration
  {
    parser.yy.R("declaration_list : declaration");
    $$ = new playground.c.lib.Node("declaration_list", yytext, yylineno);
    $$.children.push($1);
  }
  | declaration_list declaration
  {
    parser.yy.R("declaration_list : declaration_list declaration");
    $$ = $1;
    $$.children.push($2);
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
    $$ = $1;
    $$.children.push($2);

    // Recursively move the statement portion of 'case n : statement' up to
    // the statement list
    (function(thisNode, listNode)
    {
      switch(thisNode.type)
      {
        case "case" :
          index = 1;
          break;

        case "default" :
          index = 0;
          break;

        default :
          // Not case nor default, so we have nothing to do
          return;
      }

      // Move this case's statement to the statement list
      listNode.children.push(thisNode.children[index]);
      thisNode.children.length = 1;

      // It's a case. Call recursively, to handle child being another case.
      arguments.callee(thisNode.children[index], listNode);
    })($2, $$);
  }
  | statement_list save_position declaration
  {
    playground.c.lib.Node.getError().parseError(
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
    $$ = new playground.c.lib.Node("if", yytext, yylineno);
    $$.children.push($3);
    $$.children.push($5);
    $$.children.push(playground.c.lib.Node.getNull(yylineno)); // else statement
  }
  | IF '(' expression ')' statement ELSE statement
  {
    parser.yy.R("selection_statement : IF '(' expression ')' statement ELSE statement");
    $$ = new playground.c.lib.Node("if", yytext, yylineno);
    $$.children.push($3);
    $$.children.push($5);
    $$.children.push($7);
  }
  | SWITCH '(' expression ')' statement
  {
    parser.yy.R("selection_statement : SWITCH '(' expression ')' statement");
    $$ = new playground.c.lib.Node("switch", yytext, yylineno);
    $$.children.push($3);
    $$.children.push($5);
  }
  ;

iteration_statement
  : WHILE '(' expression ')' statement
  {
    parser.yy.R("iteration_statement : WHILE '(' expression ')' statement");
    $$ = new playground.c.lib.Node("for", yytext, yylineno);
    $$.children.push(playground.c.lib.Node.getNull(yylineno));     // initialization
    $$.children.push($3);       // while condition
    $$.children.push($5);       // statement block
    $$.children.push(playground.c.lib.Node.getNull(yylineno));     // after each iteration
  }
  | DO statement WHILE '(' expression ')' ';'
  {
    parser.yy.R("iteration_statement : DO statement WHILE '(' expression ')' ';'");
    $$ = new playground.c.lib.Node("do-while", yytext, yylineno);
    $$.children.push($2);       // statement
    $$.children.push($5);       // while condition
  }
  | FOR '(' expression_statement expression_statement ')' statement
  {
    parser.yy.R("iteration_statement : FOR '(' expression_statement expression_statement ')' statement");
    $$ = new playground.c.lib.Node("for", yytext, yylineno);
    $$.children.push($3);       // initialization
    $$.children.push($4);       // while condition
    $$.children.push($6);       // statement block
    $$.children.push(playground.c.lib.Node.getNull(yylineno));     // after each iteration
  }
  | FOR '(' expression_statement expression_statement expression ')' statement
  {
    parser.yy.R("iteration_statement : " +
      "FOR '(' expression_statement expression_statement expression ')' " +
      "statement");
    $$ = new playground.c.lib.Node("for", yytext, yylineno);
    $$.children.push($3);       // initialization
    $$.children.push($4);       // while condition
    $$.children.push($7);       // statement block
    $$.children.push($5);       // after each iteration
  }
  ;

jump_statement
  : GOTO identifier ';'
  {
    parser.yy.R("jump_statement : GOTO identifier ';'");
    $$ = new playground.c.lib.Node("goto", yytext, yylineno);
    $$.children.push($2);
  }
  | CONTINUE ';'
  {
    parser.yy.R("jump_statement : CONTINUE ';'");
    $$ = new playground.c.lib.Node("continue", yytext, yylineno);
  }
  | BREAK ';'
  {
    parser.yy.R("jump_statement : BREAK ';'");
    $$ = new playground.c.lib.Node("break", yytext, yylineno);
  }
  | RETURN ';'
  {
    parser.yy.R("jump_statement : RETURN ';'");
    $$ = new playground.c.lib.Node("return", yytext, yylineno);
    $$.children.push(playground.c.lib.Node.getNull(yylineno));
  }
  | RETURN expression ';'
  {
    parser.yy.R("jump_statement : RETURN expression ';'");
    $$ = new playground.c.lib.Node("return", yytext, yylineno);
    $$.children.push($2);
  }
  ;

translation_unit
  : external_declaration
    {
      parser.yy.R("translation_unit : external_declaration");
      $$ = new playground.c.lib.Node("translation_unit", yytext, yylineno);
      $$.children.push($1);
    }
  | translation_unit external_declaration
    {
      parser.yy.R("translation_unit : translation_unit external_declaration");
      $$ = $1;
      $$.children.push($2);
    }
  ;

external_declaration
  : function_definition
  {
    parser.yy.R("external_declaration : function_definition");
    $$ = $1;

    // Pop the symtab created by function_scope from the stack
    playground.c.lib.Symtab.popStack();
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
    $$ = new playground.c.lib.Node("function_definition", yytext, yylineno);
    $$.children.push($1);       // declaration_specifiers
    $$.children.push($3);       // declarator
    $$.children.push($4);       // declaration_list
    $$.children.push($5);       // compound_statement
  }
*/
  : declaration_specifiers maybe_typedef_mode declarator compound_statement
  {
    parser.yy.R("function_definition : " +
      "declaration_specifiers declarator compound_statement");
    $$ = new playground.c.lib.Node("function_definition", yytext, yylineno);
    $$.children.push($1);       // declaration_specifiers
    $$.children.push($3);       // declarator
    $$.children.push(playground.c.lib.Node.getNull(yylineno));     // declaration_list
    $$.children.push($4);       // compound_statement
  }
/* Don't support K&R-style declarations...
  | declarator declaration_list compound_statement
  {
    parser.yy.R("function_definition : declarator declaration_list compound_statement");
    $$ = new playground.c.lib.Node("function_definition", yytext, yylineno);
    $$.children.push(playground.c.lib.Node.getNull(yylineno));     // declaration_specifiers
    $$.children.push($1);       // declarator
    $$.children.push($2);       // declaration_list
    $$.children.push($3);       // compound_statement
  }
*/
  | declarator compound_statement
  {
    parser.yy.R("function_definition : declarator compound_statement");
    $$ = new playground.c.lib.Node("function_definition", yytext, yylineno);
    $$.children.push(playground.c.lib.Node.getNull(yylineno));     // declaration_specifiers
    $$.children.push($1);       // declarator
    $$.children.push(playground.c.lib.Node.getNull(yylineno));     // declaration_list
    $$.children.push($2);       // compound_statement
  }
  ;

function_scope
  :
  {
    new playground.c.lib.Symtab(
      playground.c.lib.Symtab.getCurrent(), null, yylineno + 1);
    $$ = $1;
  }
  ;

identifier
  : IDENTIFIER
  {
    if (playground.c.lib.Node.typedefMode === 2)
    {
      parser.yy.R("identifier : TYPE_DEFINITION (" + yytext + ")");
      $$ = new playground.c.lib.Node("identifier", yytext, yylineno);
      $$.value = playground.c.lib.Node.namespace + yytext;
      playground.c.lib.Symtab.getCurrent().add(yytext, yylineno, true);
    }
    else
    {
      parser.yy.R("identifier : IDENTIFIER (" + yytext + ")");
      $$ = new playground.c.lib.Node("identifier", yytext, yylineno);
      $$.value = playground.c.lib.Node.namespace + yytext;
    }
  }
  ;

type_name_token
  : TYPE_NAME
  {
    parser.yy.R("identifier : TYPE_NAME (" + yytext + ")");
    $$ = new playground.c.lib.Node("type_name_token", yytext, yylineno);
    $$.value = yytext;
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
    $$ = "{"
  }
  ;

rbrace
  : RBRACE
  {
    parser.yy.R("rbrace : RBRACE");
    $$ = "}";
  }
  ;

%%
/* helper functions for bidirectional data exchagne between lexer and parser */
parser.yy.R = function(entry) {
  console.log(entry);
};
// default
parser.yy.bSawStruct = false;

parser.yy.typedefMode = 0;
parser.yy.types = {};

parser.yy.isType = function(type) {
  if(!type || !type.length || type.length === 0) {
    return false;
  }

  return parser.yy.types.hasOwnProperty(type);
}
