function rtwconfiguremodel(varargin)
% RTWCONFIGUREMODEL - Configure a model for a Real-Time Workshop
% application.  
% 
% args{1}   - Name or handle of the model
% args{2}   - Operating mode
% args{3:N} - optional argument/value list: acceptable arguments
%  
% fxpMode   - 'fixed'   : configure for fixed-point
%             'floating': configure for floating-point
%             'noop'    : don't change relevant fixed/float settings
% forGRT    - true/false: Configure for GRT
% optimized - true/false: optimized or debug
% forDSP    - true/false: requires DSP support (i.e., complex)
%

% Copyright 1994-2010 The MathWorks, Inc.
% $Revision: 1.1.6.27 $  $Date: 2010/05/20 02:52:09 $


  % Sanity check
  if nargin < 2
      DAStudio.error('RTW:utility:invalidArgCount',...
                     'rtwconfiguremodel','at least two');
  end

  model = varargin{1};
  % the first argument must be a valid model
  if ishandle(model)
      if ~isequal(get_param(model, 'Type'), 'block_diagram') || ...
              ~isequal(get_param(model, 'BlockDiagramType'), 'model')
          DAStudio.error('RTW:targetSpecific:rtwconfiguremodelInvalidArgs');
      end
  elseif ischar(model)
      if isempty(find_system(model, 'type', 'block_diagram')) || ...
              ~isequal(get_param(model, 'BlockDiagramType'), 'model')
          DAStudio.error('RTW:targetSpecific:rtwconfiguremodelInvalidArgs');
      end
  else
      DAStudio.error('RTW:targetSpecific:rtwconfiguremodelInvalidArgs');
  end
  
  % default values for other settings
  fxpMode   = 'noop';
  forGRT    = true;
  optimized = true;
  isDSP     = true;
  nonFiniteOption = false;

  mode = varargin{2};
  switch mode
   case 'ERT (optimized for fixed-point)'
    fxpMode = 'fixed';
    forGRT = false;
    optimized = true;
    
   case 'ERT (optimized for floating-point)'
    fxpMode = 'floating';
    forGRT = false;
    optimized = true;
    
   case 'GRT (optimized for fixed/floating-point)'
    fxpMode = 'noop';
    forGRT = true;
    optimized = true;
    
   case 'GRT (debug for fixed/floating-point)'
    fxpMode = 'noop';
    forGRT = true;
    optimized = false;

   case 'Specified'
    i = 3;
    while i < nargin
      var = varargin{i};
      setting = varargin{i+1};
      if isequal(var, 'fxpMode')
        fxpMode = setting;
      elseif isequal(var, 'forGRT')
        forGRT = setting;
      elseif isequal(var, 'optimized')
        optimized = setting;
      elseif isequal(var, 'forDSP')
        isDSP = setting;
      elseif isequal(var, 'nonFinites')
        nonFiniteOption = true;
        nonFinites = setting;
      end
      i = i + 2;
    end
    
    otherwise
     assertMsg = 'Internal error: unrecognized configuration mode'; 
     assert(false,assertMsg); 
  end

  % Obtain the active configuration set
  
  cs = getActiveConfigSet(model);
  
  % Select appropriate RTW system target file
  
  if forGRT
    stf = 'grt.tlc';
  else
    stf = 'ert.tlc';
  end
      
  % Switch to the appropriate target
  
  switchTarget(cs,stf,[]);

  % turn off 'CheckMdlBeforeBuild' option
  cs.set_param('CheckMdlBeforeBuild', 0);
  
  isERT = strcmp(get_param(cs,'IsERTTarget'),'on');
  
  % TLC command line options
  
  %set_param(cs,'TLCOptions','-p0');
  
  % Solver options
  
  %set_param(cs,'SolverType','Fixed-step');        % Type
  %set_param(cs,'Solver','FixedStepDiscrete');     % Solver
  %set_param(cs,'SolverMode','Auto');              % Tasking mode for periodic sample times
  %set_param(cs,'AutoInsertRateTranBlk','on');     % Automatically handle data transfers
                                                   % between tasks (on Solver page)
  %set_param(cs,'InsertRTBMode', 'Deterministic'); % Specify the mode for auto inserted Rate 
                                                   % Transition blocks 

  % Optimizations

  if optimized
    set_param(cs,'BlockReduction','on');               % Block reduction optimization
    set_param(cs,'ConditionallyExecuteInputs','on');   % Conditional input branch execution
    set_param(cs,'InlineParams','on');                 % Inline parameters
    set_param(cs,'BooleanDataType','on');              % Implement logic signals a boolean data
    set_param(cs,'OptimizeBlockIOStorage','on');       % Signal storage reuse
    set_param(cs,'LocalBlockOutputs','on');            % Enable local block outputs
    set_param(cs,'BufferReuse','on');                  % Reuse block outputs
    set_param(cs,'ExpressionFolding','on');            % Eliminate superfluous temporary variables
    set_param(cs,'RollThreshold',5);                   % Loop unrolling threshold
    set_param(cs,'InlineInvariantSignals','on');       % Compute and inline invariant signals in the
                                                       % code
    set_param(cs,'StateBitsets','on');                 % Use bitsets for storing state configuration
                                                       % (Stateflow)
    set_param(cs,'DataBitsets','on');                  % Use bitsets for storing boolean data
                                                       % (Stateflow)
    set_param(cs,'UseTempVars','on');                  % Minimize array reads using temporary
                                                       % variables (Stateflow)
    set_param(cs,'FoldNonRolledExpr','on');            % Non-UI
    %set_param(cs, 'OptimizeModelRefInitCode', 'on');  % Suppress initialization code of a Model
                                                       % block when initialization code is superfluous
                                                       % in its parent's context.
    set_param(cs,'EfficientMapNaN2IntZero','on');      % check NaN, if it is NaN, set it to zero (R2008b)
    set_param(cs,'EnableMemcpy','on');                 % enable memory copy (R2008b)
    
    if isERT
      set_param(cs,'ZeroExternalMemoryAtStartup','off'); % Remove root level I/O zero initialization
                                                         % (NOTE: inverted logic from UI)
      set_param(cs,'ZeroInternalMemoryAtStartup','off'); % Remove internal state zero initialization
                                                         % (NOTE: inverted logic from UI)
      set_param(cs,'InitFltsAndDblsToZero','off');       % Use memset to initialize floats and double
      set_param(cs,'InlinedParameterPlacement',...       % Parameter structure
                   'NonHierarchical');                   
      set_param(cs,'NoFixptDivByZeroProtection','on');  % Remove code that protects against division 
                                                        % arithmetic exceptions
      set_param(cs, 'IncludeERTFirstTime', 'off');      % Non-UI
    end
    set_param(cs,'EfficientFloat2IntCast','on');        % Remove code from floating-point to integer 
                                                        % conversions that wraps out-of-range values
  else
    set_param(cs,'BlockReduction','off');               % Block reduction optimization
    set_param(cs,'ConditionallyExecuteInputs','off');   % Conditional input branch execution
    set_param(cs,'InlineParams','off');                 % Inline parameters
    set_param(cs,'OptimizeBlockIOStorage','off');       % Signal storage reuse
    set_param(cs,'InlineInvariantSignals','off');       % Inline invariant signals
                                                        % to 0.0 (NOTE: inverted logic from UI)
    set_param(cs,'StateBitsets','off');                 % Use bitsets for storing state configuration
                                                        % (Stateflow)
    set_param(cs,'DataBitsets','off');                  % Use bitsets for storing boolean data
                                                        % (Stateflow)
    set_param(cs,'UseTempVars','off');                  % Minimize array reads using temporary
                                                        % variables (Stateflow)
    set_param(cs,'FoldNonRolledExpr','off');            % Non-UI

    set_param(cs,'EfficientMapNaN2IntZero','off');      % check NaN, if it is NaN, set it to zero (R2008b)
    set_param(cs,'EnableMemcpy','off');                 % enable memory copy (R2008b)
  
    if isERT
      set_param(cs,'ZeroExternalMemoryAtStartup','on'); % Remove root level I/O zero initialization
                                                        % (NOTE: inverted logic from UI)
      set_param(cs,'ZeroInternalMemoryAtStartup','on'); % Remove internal state zero initialization
                                                        % (NOTE: inverted logic from UI)
      set_param(cs,'InitFltsAndDblsToZero','on');       % Use memset to initialize floats and double
      set_param(cs,'InlinedParameterPlacement',...      % Parameter structure
                   'Hierarchical');                   
      set_param(cs,'NoFixptDivByZeroProtection','off')  % Remove code that protects against division 
                                                        % arithmetic exceptions
    end
    set_param(cs,'EfficientFloat2IntCast','off');       % Remove code from floating-point to integer 
                                                        % conversions that wraps out-of-range values
  end

  % Hardware Implementation
  %
  % Note: if you are targeting the MATLAB host computer, extract the hardware
  % details for MATLAB host computer using rtwhostwordlengths and
  % rtw_host_implementation_props.
  %
  %set_param(cs,'ProdHWDeviceType','Generic->Custom');    % Device type
  %set_param(cs,'ProdBitPerChar', 8);                     % char number of bits
  %set_param(cs,'ProdBitPerShort', 16);                   % short number of bits
  %set_param(cs,'ProdBitPerInt', 32);                     % int number of bits
  %set_param(cs,'ProdBitPerLong', 32);                    % long number of bits
  %set_param(cs,'ProdWordSize', 32);                      % Native word size
  %set_param(cs,'ProdIntDivRoundTo', 'Floor');            % Integer division with negative operand
  %                                                       % quotient rounds to
  %set_param(cs,'ProdShiftRightIntArith','on');           % Shift right on a signed integer as
  %                                                       % arithmetic shift right
  %set_param(cs,'ProdEndianess','LittleEndian');          % Byte ordering
  %set_param(cs,'ProdEqTarget','on');                     % None (literally 'None')
      
  % Report
  
  set_param(cs,'GenerateReport','on');             % Generate HTML report
  set_param(cs,'LaunchReport','on');               % Launch report
  
  if ~isERT || ~strcmpi(get_param(cs,'CPPClassGenCompliant'),'on')
      if strcmp(get_param(cs,'TargetLang'),'C++ (Encapsulated)')
         set_param(cs,'TargetLang','C++'); 
      end
  end
  
  if isERT
    set_param(cs,'IncludeHyperlinkInReport','on'); % Code-to-block navigation
    set_param(cs,'GenerateTraceInfo','on');        % Block-to-code navigation
    set_param(cs,'GenerateTraceReport','on');      % Report eliminated / virtual blocks
    set_param(cs,'GenerateTraceReportSl','on');    % Report traceable Simulink blocks
    set_param(cs,'GenerateTraceReportSf','on');    % Report traceable Stateflow objects
    set_param(cs,'GenerateTraceReportEml','on');   % Report Embedded MATLAB functions 
  end
  
  % Comments
  
  set_param(cs,'GenerateComments','on');         % Include comments
  set_param(cs,'SimulinkBlockComments','on');    % Simulink block comments
  set_param(cs,'ShowEliminatedStatement','off'); % Show eliminated statements
  set_param(cs,'ForceParamTrailComments','on');  % Verbose comments for SimulinkGlobal
                                                 % storage class
  if isERT
    set_param(cs,'InsertBlockDesc','on');        % Simulink block descriptions
    set_param(cs,'SimulinkDataObjDesc','on');    % Simulink data object descriptions
    %set_param(cs,'EnableCustomComments','off'); % Custom comments (MPT objects only)
  end
  
  % Symbols
  
  %set_param(cs,'MaxIdLength',31);                     % Maximum identifier length
  if isERT
    set_param(cs,'MangleLength',1);                    % Minimum mangling length for ids
    set_param(cs,'CustomSymbolStrGlobalVar','rt$N$M'); % Symbol format for global variables
    set_param(cs, 'CustomSymbolStrType', '$N$M');      % Symbol format for global types
    set_param(cs, 'CustomSymbolStrField', '$N$M');     % Symbol format for field name of types
    set_param(cs, 'CustomSymbolStrFcn', '$N$M$F');     % Symbol format for subsystem methods
    set_param(cs, 'CustomSymbolStrTmpVar', '$N$M');    % Symbol format for temporary variables
    set_param(cs, 'CustomSymbolStrBlkIO', 'rtb_$N$M'); % Symbol format for local block output variables
    set_param(cs, 'CustomSymbolStrMacro', '$N$M');     % Symbol format for macros
    set_param(cs,'InlinedPrmAccess','Literals');       % Generate scalar inlined parameters as literals
    if ~strcmp(get_param(cs,'TargetLang'),'C++ (Encapsulated)')
        set_param(cs,'IgnoreCustomStorageClasses','off');  % Ignore custom storage classes
    end
    %set_param(cs,'DefineNamingRule','None');          % #define naming
    %set_param(cs,'ParamNamingRule','None');           % Parameter naming
    %set_param(cs,'SignalNamingRule','None');          % Signal naming
  end
  
  % Software Environment
  
  %set_param(cs,'TargetFunctionLibrary','ISO_C');   % Target floating point math
                                                    % environment (ANSI_C, ISO_C,
                                                    % GNU)
  if isERT
    if strcmp(fxpMode,'fixed')
      set_param(cs,'PurelyIntegerCode','on');       % Floating point numbers (Note: inverted
                                                    % logic from UI)
    % set_param(cs, 'UseIntDivNetSlope', 'on');     % Use integer division to handle net slopes 
                                                    % that are reciprocals of integers                                                   
    elseif strcmp(fxpMode,'floating')
      set_param(cs,'PurelyIntegerCode','off');      % Floating point numbers (Note: inverted
                                                    % logic from UI)
    end
    if nonFiniteOption
      if nonFinites
        set_param(cs,'SupportNonFinite','on');      % Non-finite numbers
      else
        set_param(cs,'SupportNonFinite','off');
      end
    end
    if isDSP
      set_param(cs,'SupportComplex','on');          % Complex numbers
    else
      set_param(cs,'SupportComplex','off');
    end
    %set_param(cs,'SupportAbsoluteTime','off');       % Absolute time
    %set_param(cs,'SupportContinuousTime','off');     % Continuous time
    %set_param(cs,'SupportNonInlinedSFcns','off');    % Non-inlined S-Functions
    %set_param(cs,'LifeSpan','1');                    % Application lifespan (days)
    
    %set_param(cs,'EnableUserReplacementTypes','on'); % Replace data type
                                                      % names in the generated code                                  
    % replacementName.double  = 'F64';
    % replacementName.single  = 'F32';
    % replacementName.int32   = 'S32';
    % replacementName.int16   = 'S16';
    % replacementName.int8    = 'S8';
    % replacementName.uint32  = 'US32';
    % replacementName.uint16  = 'U16';
    % replacementName.uint8   = 'US8';
    % replacementName.boolean = 'US8';
    % replacementName.int     = 'S32';
    % replacementName.uint    = 'US32';
    % replacementName.char    = 'CHAR';
    %set_param(cs,'ReplacementTypes', replacementName); % Replacement Name 
      
  end

  % Code interface
  
  if isERT
    set_param(cs,'IncludeMdlTerminateFcn','off');        % Terminate function required
    %set_param(cs,'MultiInstanceERTCode','off');         % Generate reusable code
    %set_param(cs,'MultiInstanceErrorCode','Error');     % Reusable code error diagnostic
    %set_param(cs,'RootIOFormat','Structure Reference'); % Pass root-level I/O as
    %set_param(cs,'SuppressErrorStatus','on');           % Suppress error status in real-time model
                                                         % data structure
    set_param(cs,'GRTInterface','off');                  % GRT compatible call interface
    set_param(cs,'CombineOutputUpdateFcns','on');        % Single output update
    set_param(cs,'CombineSignalStateStructs','on');      % Combine block signal and state structures
  end
  %set_param(cs,'UtilityFuncGeneration','Auto');         % Utility function generation

  % Data exchange
  
  %set_param(cs,'RTWCAPIParams','off');    % Generate C-API for signals
  %set_param(cs,'RTWCAPISignals','off');   % Generate C-API for parameters
  %set_param(cs,'RTWCAPIStates','off');    % Generate C-API for states
  %set_param(cs,'GenerateASAP2','off');    % Generate ASAP2 file
  %set_param(cs,'ExtMode','off');          % Generate External Mode interface

  % Code style
  
  if isERT
      %set_param(cs, 'ParenthesesLevel', 'Nominal'); % Control parentheses style
      if optimized
          set_param(cs, 'PreserveExpressionOrder', 'off'); % Always fold expressions left
                                                           % recursively to reduce stack
                                                           % memory usage
          set_param(cs, 'PreserveIfCondition', 'off');     % Negate if-else statement to 
                                                           % remove empty conditions
      else
          set_param(cs, 'PreserveExpressionOrder', 'on');  % Fold expressions to best match
                                                           % model specification 
          set_param(cs, 'PreserveIfCondition', 'on');      % Preserve empty else conditions
                                                           % to best match model specification
      end
  end
  
  % Templates

  if isERT
    set_param(cs,'ERTCustomFileTemplate',...
                 'example_file_process.tlc');   % File customization template
    set_param(cs,'GenerateSampleERTMain',...    
                 'on');                         % Generate an example main program
    %set_param(cs,'TargetOS',...                 
    %             'BareBoardExample');          % Target operating system
    set_param(cs,'ERTSrcFileBannerTemplate',... 
                 'ert_code_template.cgt');      % Source file (*.c) template (code)
    set_param(cs,'ERTHdrFileBannerTemplate',...
                 'ert_code_template.cgt');      % Source file (*.h) template (code)
    set_param(cs,'ERTDataSrcFileTemplate',...
                 'ert_code_template.cgt');      % Source file (*.c) template (data)
    set_param(cs,'ERTDataHdrFileTemplate',...
                 'ert_code_template.cgt');      % Source file (*.h) template (data)
  end
  
  % Code Placement
  %if isERT
    %set_param(cs, 'ERTFilePackagingFormat', ...
    %              'CompactWithDataFile');       % Compact with separate data file format
  %end
  
  % Verification

  %if isERT
    %set_param(cs,'GenerateErtSFunction','off');  % Create SIL block
    %set_param(cs, 'PortableWordSizes', 'on');    % Enable platform portable word size
                                                  % for SIL testing
  %end
  set_param(cs,'MatFileLogging','off');  % MAT-file logging
  set_param(cs,'SaveTime','off');        %   o Time
  set_param(cs,'SaveOutput','off');      %   o States
  set_param(cs,'SaveState','off');       %   o Output
  set_param(cs,'SaveFinalState','off');  %   o File states

  % Build environment
  
  if optimized
    set_param(cs,'RTWVerbose','off');      % Verbose build 
    set_param(cs,'RetainRTWFile','off');   % Delete the .rtw file
    %set_param(cs,'GenCodeOnly','on');     % Generate code only
  else
    set_param(cs,'RTWVerbose','on');       % Verbose build 
    set_param(cs,'RetainRTWFile','on');    % Delete the .rtw file
    %set_param(cs,'GenCodeOnly','on');     % Generate code only
  end
  
  % Memory sections
  if isERT
      %set_param(cs,'MemSecPackage', '--- None ---');   % Package containing memory section
                                                        % definition
      %set_param(cs, 'MemSecFuncInitTerm', 'Default');  % Memory section for initialize and
                                                        % terminate function
      %set_param(cs, 'MemSecFuncExecute', 'Default');   % Memory section for other functions
      %set_param(cs, 'MemSecDataConstants', 'Default'); % Memory section for constant data
      %set_param(cs, 'MemSecDataIO', 'Default');        % Memory section for root input/output
                                                        % Data
      %set_param(cs, 'MemSecDataInternal', 'Default');  % Memory section for internal data
      %set_param(cs, 'MemSecDataParameters', 'Default');% Memory section for parameters
  end
 
  %
  % Optional section:
  %
  % It is often desirable to maximize the bi-directional traceability between the model and
  % the generated code.  In some cases, you can maximize code traceability without adversely
  % impacting code efficiency, however there are a several exceptions to consider carefully.
  % In particular:
  %
  % Block reduction
  % Expression folding
  % Inline invariant signals
  % Buffer reuse
  % Conditional branch execution
  % Preserve expression order
  % Preserve empty if-else conditions
  %
  % Uncomment the following section to maximize traceability between the model and code.
  % Depending on your code verification needs, you may only wish to uncomment them
  % selectively as they greatly impact code efficiency.
  
  % Report (no impact on code efficiency)
  
  %set_param(cs,'GenerateReport','on');             % Generate HTML report
  %set_param(cs,'LaunchReport','on');               % Launch report
  if isERT
      %set_param(cs,'IncludeHyperlinkInReport','on'); % Code-to-block navigation
      %set_param(cs,'GenerateTraceInfo','on');        % Block-to-code navigation
      %set_param(cs,'GenerateTraceReport','on');      % Report eliminated / virtual blocks
      %set_param(cs,'GenerateTraceReportSl','on');    % Report traceable Simulink blocks
      %set_param(cs,'GenerateTraceReportSf','on');    % Report traceable Stateflow objects
      %set_param(cs,'GenerateTraceReportEml','on');   % Report Embedded MATLAB functions 
  end

  % Comments (no impact on code efficiency)
  
  %set_param(cs,'GenerateComments','on');         % Include comments
  %set_param(cs,'SimulinkBlockComments','on');    % Simulink block comments
  %set_param(cs,'ShowEliminatedStatement','on');  % Show eliminated statements
  %set_param(cs,'ForceParamTrailComments','on');  % Verbose comments for SimulinkGlobal
                                                  % storage class
  if isERT
      %set_param(cs,'InsertBlockDesc','on');        % Simulink block descriptions
      %set_param(cs,'SimulinkDataObjDesc','on');    % Simulink data object descriptions
      %set_param(cs,'EnableCustomComments','on');   % Custom comments (MPT objects only)
  end

  % Symbols (no impact on code efficiency)
  
  if isERT
      %set_param(cs,'MangleLength',1);                    % Minimum mangling length for ids
      %set_param(cs,'CustomSymbolStrGlobalVar','rt$N$M'); % Symbol format for global variables
      %set_param(cs, 'CustomSymbolStrType', '$N$M');      % Symbol format for global types
      %set_param(cs, 'CustomSymbolStrField', '$N$M');     % Symbol format for field name of types
      %set_param(cs, 'CustomSymbolStrFcn', '$N$M$F');     % Symbol format for subsystem methods
      %set_param(cs, 'CustomSymbolStrTmpVar', '$N$M');    % Symbol format for temporary variables
      %set_param(cs, 'CustomSymbolStrBlkIO', 'rtb_$N$M'); % Symbol format for local block output variables
      %set_param(cs, 'CustomSymbolStrMacro', '$N$M');     % Symbol format for macros
      %set_param(cs, 'InlinedPrmAccess', 'Macros');       % Generate scalar inlined parameters as macros
  end

  % Optimizations (degrades code efficiency)
  
  %set_param(cs,'BlockReduction','off');               % Block reduction optimization
  %set_param(cs,'ConditionallyExecuteInputs','off');   % Conditional input branch execution
  %set_param(cs,'BufferReuse','off');                  % Reuse block outputs
  %set_param(cs,'ExpressionFolding','off');            % Eliminate superfluous temporary variables
  %set_param(cs,'InlineInvariantSignals','off');       % Compute and inline invariant signals in the
                                                       % code

  % Code Style (degrades code efficiency)
  
  if isERT
      %set_param(cs, 'PreserveExpressionOrder', 'on');  % Fold expressions to best match
                                                        % model specification 
      %set_param(cs, 'PreserveIfCondition', 'on');      % Preserve empty else conditions
                                                        % to best match model specification
  end
  
