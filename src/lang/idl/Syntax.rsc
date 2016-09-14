@contributor{Jurgen Vinju - CWI}
@source{Inspired by |https://raw.githubusercontent.com/catedrasaes-umu/idl4emf/master/org.csu.idl.xtext/src/org/csu/idl/xtext/IDL.xtext|}
module lang::idl::Syntax

syntax Specification
    =   IncludeDecl* includes Definition* definitions
    ;


syntax IncludeDecl 
    =   "#include" STRING importURI
    ;

syntax Definition
    =   TypeDecl ";"
    |   ConstDecl ";"
    |   ExceptDecl ";"
    |   InterfaceDecl ";"
    |   InterfaceFwd ";"
    |   Module ";"
    //| Type_id_decl ";"
    //| Type_prefix_decl ";"
    //| Event ";"
    //| Component ";"
    //| Home_decl ";"
    ;

syntax Module 
    =   "module" ID identifier  "{" (Definition | ";")* contains "}"
    ;

syntax InterfaceDecl
    =   ("abstract" | "local")? "interface" ID identifier
        ( ":" {ID ","}+ )? 
        "{" (Export | ";")* exports "}"
    ;

syntax InterfaceFwd
    =   ( "abstract" | "local" )? "interface" ID identifier
    ;

syntax Export 
    =   TypeDecl ";"
    |   ConstDecl ";"
    |   ExceptDecl ";"
    |   AttrDecl ";"
    |   OpDecl ";"
//  |   TypeIdDecl ";"
//  |   TypePrefixDecl ";"
    ;


syntax OpDecl 
    =   "oneway"? (OpTypeSpec  | ID ) ID identifier "(" {ParamDecl ","}* params ")"
        ( "raises" "(" {ID ","}+ exceptions ")" )?
        ( "context" "(" {STRING ","}+ contexts ")" )?
    ;


syntax OpTypeSpec 
    =   BaseTypeSpec
    |   VoidType kind
    ;


syntax ParamDecl 
    =   ParamAttribute direction (BaseTypeSpec  | ID ) ID identifier
    ;

syntax AttrDecl 
    =   ReadonlyAttrSpec
    |   AttrSpec
    ;


syntax ReadonlyAttrSpec 
    =   "readonly"? "attribute" (BaseTypeSpec  | ID ) ID identifier
        ("raises" "(" {ID ","}* raises ")")?
    ;


syntax AttrSpec
    =   "attribute" (BaseTypeSpec  | ID ) ID identifier
        ("getraises" "(" {ID ","}* getRaises ")")? 
        ("setraises" "(" {ID ","}* setRaises ")")? 
    ;


syntax ExceptDecl 
    =   "exception" ID identifier "{" Member* members "}"
    ;

syntax TypeDecl 
    =   AliasType
    |   StructType
    |   UnionType
    |   EnumType
    |   "native" ID
    |   ConstrForwardDecl
    ;
    
syntax AliasType 
    =   "typedef" ArrayTypeSpec 
    |   "typedef" (SimpleTypeSpec  | ID ) ID identifier
    ;

syntax ArrayTypeSpec
    =   (SimpleTypeSpec  | ID ) ID name ("[" Expr "]")+ bounds
    ;

syntax SimpleTypeSpec
    =   BaseTypeSpec
    |   TemplateTypeSpec
    ;


syntax BaseTypeSpec
    =   PrimitiveDef
    |   ObjectType kind
    ;


syntax TemplateTypeSpec
    =   SequenceType
    |   StringdefType
    |   WideStringdefType
    |   FixedPtType
    ;


syntax ConstrTypeSpec
    =   StructType
    |   UnionType
    |   EnumType
    ;

syntax StructType 
    =   "struct" ID identifier "{" Member+ members "}"
    ;

syntax Member 
    =   ArrayTypeSpec  ";"
    |   SimpleTypeSpec  ID identifier ";"
    |   StructType  ID identifier ";"
    |   ID  ID identifier ";"
    ;

syntax UnionType 
    =   "union" ID identifier
        "switch" "(" (SwitchTypeSpecCont containedDiscrim | ID sharedDiscrim) ")"
        "{" CaseStmt+ unionMembers '}'
    ;

syntax SwitchTypeSpecCont
    =   IntegerType
    |   CharType
    |   BooleanType
    |   EnumType
    ;

syntax CaseStmt
    =   ("case" (Expr label | "default") ":" )+ ArrayTypeSpec ";"
    |   ("case" (Expr label | "default") ":")+ (SimpleTypeSpec  | ID ) ID identifier ";"
    ;


syntax EnumType 
    =   "enum" ID identifier
        "{" EnumMember* members "}"
    ;
    
syntax EnumMember 
    =   ID identifier
    ;

syntax ConstrForwardDecl
    =   ("struct" | "union") ID identifier
    ;


syntax ConstDecl
    =   "const" (ConstType  | ID )
        ID identifier "=" Expr constValue
    ;


syntax ConstType 
    =   PrimitiveDef
    |   StringdefType
    |   WideStringdefType
    |   FixedPtConstType
    ;


syntax PrimitiveDef
    =   IntegerType
    |   FloatingPtType
    |   CharType
    |   OtherType
    ;


//---------------------------
// TEMPLATE TYPES
//---------------------------

syntax SequenceType
    =   "sequence" "\<" (SimpleTypeSpec  | ID  ) ("," Expr bound)? "\>"
    ;

syntax StringdefType 
    =   "string" "\<" Expr bound "\>"
    ;

syntax WideStringdefType
    =  "wstring"  "\<" Expr bound "\>"
    ;

syntax FixedPtType 
    =   "fixed" "\<" Expr digits "," Expr scale "\>"
    ;



//---------------------------
// PARAMETER MODES
//---------------------------

syntax ParamAttribute = "in" | "out" | "inout";


//---------------------------
// BASE TYPES
//---------------------------


syntax FloatingPtType
    =  "float" | "double" | "long" "double"; 

syntax BooleanType = "boolean";

syntax IntegerType = "short"  | "long" | "long" "long" | "unsigned" "short" | "unsigned" "long" | "unsigned" "long" "long";

syntax CharType = "char" | "wchar" | "string" | "wstring";

syntax OtherType = "boolean" | "octet" | "any" ;

syntax ObjectType = "Object";

syntax VoidType = "void";

syntax FixedPtConstType  = "fixed";


syntax Expr 
  = ID constantRef 
  | Literal
  | bracket "(" Expr ")"
  | "-" Expr
  | "+" Expr
  | "~" Expr
  > left ( Expr lhs "*" Expr rhs
         | Expr lhs "/" Expr rhs
         | Expr lhs "%" Expr rhs
         )
  > left ( Expr lhs "+" Expr rhs
         | Expr lhs "-" Expr rhs
         ) 
  > left ( Expr lhs "\>\>" Expr rhs
         | Expr lhs "\<\<" Expr rhs
         )  
  > left Expr lhs "&" Expr rhs
  > left Expr lhs "^" Expr rhs
  > left Expr lhs "|" Expr rhs            
  ;


syntax Literal
    =   HEX_LITERAL
    |   INT
    |   STRING
    /*| CHARACTER_LITERAL
    |   WIDE_CHARACTER_LITERAL*/
    |   FIXED_PT_LITERAL
    |   FLOATING_PT_LITERAL
    |   BOOLEAN_LITERAL
    ;

lexical INT = [0-9]+;

lexical FIXED_PT_LITERAL
    =   INT "." INT ([eE] [+\-]? INT)?
    |   "." INT ([eE] [+\-]? INT)?
    |   INT ([eE] [+\-]? INT)
    ;

lexical FLOATING_PT_LITERAL
    =   INT "." INT [dD]
    |   INT [dD]
    |   "." INT [dD]
    ;

lexical BOOLEAN_LITERAL
    =   "TRUE"
    |   "FALSE"
    ;

lexical HEX_LITERAL
    =   "0" "x" [0-9a-fA_F]+
    ;

lexical ID = ([a-zA-Z_] | "::") ([a-zA-Z_0-9] | "::")* !>> [a-zA-Z_0-9] !>> "::";

lexical STRING = "L"? "\"" ( ("\\" [btnfr\"\\\']) | ![\'\"])* "\"" ;
    
    