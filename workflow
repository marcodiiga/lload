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