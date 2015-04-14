switch (CI.getFrontendOpts().ProgramAction) {
  case ASTDeclList:            return new ASTDeclListAction();
  case ASTDump:                return new ASTDumpAction();
  case ASTPrint:               return new ASTPrintAction();
  case ASTView:                return new ASTViewAction();
  case DumpRawTokens:          return new DumpRawTokensAction();
  case DumpTokens:             return new DumpTokensAction();
  case EmitAssembly:           return new EmitAssemblyAction();
  case EmitBC:                 return new EmitBCAction();
  case EmitHTML:               return new HTMLPrintAction();
  case EmitLLVM:               return new EmitLLVMAction();
  case EmitLLVMOnly:           return new EmitLLVMOnlyAction();
  case EmitCodeGenOnly:        return new EmitCodeGenOnlyAction();
  case EmitObj:                return new EmitObjAction();
  case FixIt:                  return new FixItAction();
  case GenerateModule:         return new GenerateModuleAction;
  case GeneratePCH:            return new GeneratePCHAction;
  case GeneratePTH:            return new GeneratePTHAction();
  case InitOnly:               return new InitOnlyAction();
  case ParseSyntaxOnly:        return new SyntaxOnlyAction();
  case ModuleFileInfo:         return new DumpModuleInfoAction();
  case VerifyPCH:              return new VerifyPCHAction();
}

/// \brief Holds long-lived AST nodes (such as types and decls) that can be
/// referred to throughout the semantic analysis of a file.
class ASTContext : public RefCountedBase<ASTContext> {
  ASTContext &this_() { return *this; }

  mutable SmallVector<Type *, 0> Types;
  mutable llvm::FoldingSet<ExtQuals> ExtQualNodes;
  mutable llvm::FoldingSet<ComplexType> ComplexTypes;
  mutable llvm::FoldingSet<PointerType> PointerTypes;
  mutable llvm::FoldingSet<AdjustedType> AdjustedTypes;
  mutable llvm::FoldingSet<BlockPointerType> BlockPointerTypes;
  mutable llvm::FoldingSet<LValueReferenceType> LValueReferenceTypes;
  mutable llvm::FoldingSet<RValueReferenceType> RValueReferenceTypes;
  mutable llvm::FoldingSet<MemberPointerType> MemberPointerTypes;
  mutable llvm::FoldingSet<ConstantArrayType> ConstantArrayTypes;
  mutable llvm::FoldingSet<IncompleteArrayType> IncompleteArrayTypes;
  mutable std::vector<VariableArrayType*> VariableArrayTypes;
  mutable llvm::FoldingSet<DependentSizedArrayType> DependentSizedArrayTypes;
  mutable llvm::FoldingSet<DependentSizedExtVectorType>
    DependentSizedExtVectorTypes;
    

-> builtin types (including nullptr) - might need store to refer later    
void ASTContext::InitBuiltinTypes(const TargetInfo &Target) {
  assert((!this->Target || this->Target == &Target) &&
         "Incorrect target reinitialization");
  assert(VoidTy.isNull() && "Context reinitialized?");

  this->Target = &Target;
  
  ABI.reset(createCXXABI(Target));
  AddrSpaceMap = getAddressSpaceMap(Target, LangOpts);
  AddrSpaceMapMangling = isAddrSpaceMapManglingEnabled(Target, LangOpts);
  
  // C99 6.2.5p19.
  InitBuiltinType(VoidTy,              BuiltinType::Void);

  // C99 6.2.5p2.
  InitBuiltinType(BoolTy,              BuiltinType::Bool);
  // C99 6.2.5p3.
  if (LangOpts.CharIsSigned)
    InitBuiltinType(CharTy,            BuiltinType::Char_S);
  else
    InitBuiltinType(CharTy,            BuiltinType::Char_U);
  // C99 6.2.5p4.
  InitBuiltinType(SignedCharTy,        BuiltinType::SChar);
  InitBuiltinType(ShortTy,             BuiltinType::Short);
  InitBuiltinType(IntTy,               BuiltinType::Int);
  InitBuiltinType(LongTy,              BuiltinType::Long);
  InitBuiltinType(LongLongTy,          BuiltinType::LongLong);

  // C99 6.2.5p6.
  InitBuiltinType(UnsignedCharTy,      BuiltinType::UChar);
  InitBuiltinType(UnsignedShortTy,     BuiltinType::UShort);
  InitBuiltinType(UnsignedIntTy,       BuiltinType::UInt);
  InitBuiltinType(UnsignedLongTy,      BuiltinType::ULong);
  InitBuiltinType(UnsignedLongLongTy,  BuiltinType::ULongLong);

  // C99 6.2.5p10.
  InitBuiltinType(FloatTy,             BuiltinType::Float);
  InitBuiltinType(DoubleTy,            BuiltinType::Double);
  InitBuiltinType(LongDoubleTy,        BuiltinType::LongDouble);

  // GNU extension, 128-bit integers.
  InitBuiltinType(Int128Ty,            BuiltinType::Int128);
  InitBuiltinType(UnsignedInt128Ty,    BuiltinType::UInt128);

  // C++ 3.9.1p5
  if (TargetInfo::isTypeSigned(Target.getWCharType()))
  
  
  
.. when ASTConsumer has finished initialization,

void ASTFrontendAction::ExecuteAction() {
  CompilerInstance &CI = getCompilerInstance();
  if (!CI.hasPreprocessor())
    return;

  // FIXME: Move the truncation aspect of this into Sema, we delayed this till
  // here so the source manager would be initialized.
  if (hasCodeCompletionSupport() &&
      !CI.getFrontendOpts().CodeCompletionAt.FileName.empty())
    CI.createCodeCompletionConsumer();

  // Use a code completion consumer?
  CodeCompleteConsumer *CompletionConsumer = nullptr;
  if (CI.hasCodeCompletionConsumer())
    CompletionConsumer = &CI.getCodeCompletionConsumer();

  if (!CI.hasSema())
    CI.createSema(getTranslationUnitKind(), CompletionConsumer);

  ParseAST(CI.getSema(), CI.getFrontendOpts().ShowStats,
           CI.getFrontendOpts().SkipFunctionBodies);
}



ParseTopLevelDecl {
  /// ParseExternalDeclaration:
  ///
  ///       external-declaration: [C99 6.9], declaration: [C++ dcl.dcl]
  ///         function-definition
  ///         declaration
  /// [GNU]   asm-definition
  /// [GNU]   __extension__ external-declaration
  /// [OBJC]  objc-class-definition
  /// [OBJC]  objc-class-declaration
  /// [OBJC]  objc-alias-declaration
  /// [OBJC]  objc-protocol-definition
  /// [OBJC]  objc-method-definition
  /// [OBJC]  @end
  /// [C++]   linkage-specification
  /// [GNU] asm-definition:
  ///         simple-asm-expr ';'
  /// [C++11] empty-declaration
  /// [C++11] attribute-declaration
  ///
  /// [C++11] empty-declaration:
  ///           ';'
  ///
  /// [C++0x/GNU] 'extern' 'template' declaration
  Parser::DeclGroupPtrTy Parser::ParseExternalDeclaration()
    // We can't tell whether this is a function-definition or declaration yet.
    might call ParseDeclarationOrFunctionDefinition() {
      /// ParseDeclarationOrFunctionDefinition - Parse either a function-definition or
      /// a declaration.  We can't tell which we have until we read up to the
      /// compound-statement in function-definition. TemplateParams, if
      /// non-NULL, provides the template parameters when we're parsing a
      /// C++ template-declaration.
      ///
      ///       function-definition: [C99 6.9.1]
      ///         decl-specs      declarator declaration-list[opt] compound-statement
      /// [C90] function-definition: [C99 6.7.1] - implicit int result
      /// [C90]   decl-specs[opt] declarator declaration-list[opt] compound-statement
      ///
      ///       declaration: [C99 6.7]
      ///         declaration-specifiers init-declarator-list[opt] ';'
      /// [!C99]  init-declarator-list ';'                   [TODO: warn in c99 mode]
      /// [OMP]   threadprivate-directive                              [TODO]
      ///
      Parser::DeclGroupPtrTy
      Parser::ParseDeclOrFunctionDefInternal {
        /// ParseDeclarationSpecifiers
        ///       declaration-specifiers: [C99 6.7]
        ///         storage-class-specifier declaration-specifiers[opt]
        ///         type-specifier declaration-specifiers[opt]
        /// [C99]   function-specifier declaration-specifiers[opt]
        /// [C11]   alignment-specifier declaration-specifiers[opt]
        /// [GNU]   attributes declaration-specifiers[opt]
        /// [Clang] '__module_private__' declaration-specifiers[opt]
        ///
        ///       storage-class-specifier: [C99 6.7.1]
        ///         'typedef'
        ///         'extern'
        ///         'static'
        ///         'auto'
        ///         'register'
        /// [C++]   'mutable'
        /// [C++11] 'thread_local'
        /// [C11]   '_Thread_local'
        /// [GNU]   '__thread'
        ///       function-specifier: [C99 6.7.4]
        /// [C99]   'inline'
        /// [C++]   'virtual'
        /// [C++]   'explicit'
        /// [OpenCL] '__kernel'
        ///       'friend': [C++ dcl.friend]
        ///       'constexpr': [C++0x dcl.constexpr]

        ///
        void Parser::ParseDeclarationSpecifiers {
          (every one of these calls void Preprocessor::Lex(Token &Result))
          Notice: EVERY Loc (i.e. SourceLocation) locates a token/whatever by doing (FileID + real_file_offset). The SourceManager
          is needed to understand this location.
        }
      }
    }
      
}

-> first need a way to map every path in a hierarchy like this

  clang.exe!FinishOverloadedCallExpr(clang::Sema & SemaRef, clang::Scope * S, clang::Expr * Fn, clang::UnresolvedLookupExpr * ULE, clang::SourceLocation LParenLoc, llvm::MutableArrayRef<clang::Expr *> Args, clang::SourceLocation RParenLoc, clang::Expr * ExecConfig, clang::OverloadCandidateSet * CandidateSet, clang::OverloadCandidate * * Best, clang::OverloadingResult OverloadResult, bool AllowTypoCorrection) Line 10813	C++
  clang.exe!clang::Sema::BuildOverloadedCallExpr(clang::Scope * S, clang::Expr * Fn, clang::UnresolvedLookupExpr * ULE, clang::SourceLocation LParenLoc, llvm::MutableArrayRef<clang::Expr *> Args, clang::SourceLocation RParenLoc, clang::Expr * ExecConfig, bool AllowTypoCorrection) Line 10873	C++
 	clang.exe!clang::Sema::ActOnCallExpr(clang::Scope * S, clang::Expr * Fn, clang::SourceLocation LParenLoc, llvm::MutableArrayRef<clang::Expr *> ArgExprs, clang::SourceLocation RParenLoc, clang::Expr * ExecConfig, bool IsExecConfig) Line 4693	C++
 	clang.exe!clang::Parser::ParsePostfixExpressionSuffix(clang::ActionResult<clang::Expr *,1> LHS) Line 1481	C++
 	clang.exe!clang::Parser::ParseCastExpression(bool isUnaryExpression, bool isAddressOfOperand, bool & NotCastExpr, clang::Parser::TypeCastState isTypeCast) Line 1296	C++
 	clang.exe!clang::Parser::ParseCastExpression(bool isUnaryExpression, bool isAddressOfOperand, clang::Parser::TypeCastState isTypeCast) Line 441	C++
 	clang.exe!clang::Parser::ParseAssignmentExpression(clang::Parser::TypeCastState isTypeCast) Line 170	C++
 	clang.exe!clang::Parser::ParseExpression(clang::Parser::TypeCastState isTypeCast) Line 122	C++
 	clang.exe!clang::Parser::ParseExprStatement() Line 385	C++
 	clang.exe!clang::Parser::ParseStatementOrDeclarationAfterAttributes(llvm::SmallVector<clang::Stmt *,32> & Stmts, bool OnlyStatement, clang::SourceLocation * TrailingElseLoc, clang::Parser::ParsedAttributesWithRange & Attrs) Line 220	C++
 	clang.exe!clang::Parser::ParseStatementOrDeclaration(llvm::SmallVector<clang::Stmt *,32> & Stmts, bool OnlyStatement, clang::SourceLocation * TrailingElseLoc) Line 110	C++
 	clang.exe!clang::Parser::ParseCompoundStatementBody(bool isStmtExpr) Line 958	C++
 	clang.exe!clang::Parser::ParseFunctionStatementBody(clang::Decl * Decl, clang::Parser::ParseScope & BodyScope) Line 1876	C++
 	clang.exe!clang::Parser::ParseFunctionDefinition(clang::ParsingDeclarator & D, const clang::Parser::ParsedTemplateInfo & TemplateInfo, clang::Parser::LateParsedAttrList * LateParsedAttrs) Line 1104	C++
 	clang.exe!clang::Parser::ParseDeclGroup(clang::ParsingDeclSpec & DS, unsigned int Context, clang::SourceLocation * DeclEnd, clang::Parser::ForRangeInit * FRI) Line 1689	C++
 	clang.exe!clang::Parser::ParseDeclOrFunctionDefInternal(clang::Parser::ParsedAttributesWithRange & attrs, clang::ParsingDeclSpec & DS, clang::AccessSpecifier AS) Line 893	C++
 	clang.exe!clang::Parser::ParseDeclarationOrFunctionDefinition(clang::Parser::ParsedAttributesWithRange & attrs, clang::ParsingDeclSpec * DS, clang::AccessSpecifier AS) Line 909	C++
 	clang.exe!clang::Parser::ParseExternalDeclaration(clang::Parser::ParsedAttributesWithRange & attrs, clang::ParsingDeclSpec * DS) Line 767	C++
 	clang.exe!clang::Parser::ParseTopLevelDecl(clang::OpaquePtr<clang::DeclGroupRef> & Result) Line 569	C++
 	clang.exe!clang::ParseAST(clang::Sema & S, bool PrintStats, bool SkipFunctionBodies) Line 144	C++

to the source location taken in consideration.