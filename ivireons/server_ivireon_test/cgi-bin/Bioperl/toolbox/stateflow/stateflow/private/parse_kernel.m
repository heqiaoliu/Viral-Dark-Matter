function throwError = parse_kernel(machineId,chartId,targetId,parentTargetId,mainMachineId,parseLevel)

%   Copyright 1995-2009 The MathWorks, Inc.
%   $Revision: 1.5.2.12 $  $Date: 2010/05/20 03:36:14 $

throwError = 0;

if(nargin<6)
    parseLevel = 2;
end
if(nargin<5)
    mainMachineId = machineId;
end
if(isempty(mainMachineId))
    mainMachineId = machineId;
end
if(~isempty(chartId))
    objectType = 'chart';
    parseObjectId = chartId;
else
    objectType = 'machine';
    parseObjectId = machineId;
end

try
    sf('Parse', parseObjectId, targetId, parentTargetId, parseLevel);
catch err
    throwError = 1;
end

if(parseLevel>=2) 
    % G451640: With the advent of enums, it is not possible to do full symbol 
    % resolution outside of the model compilation process.
    % In all likelihood, the chart will not have access to the set of
    % enum-types (especially those coming from Simulink IO) and the 
    % enum constants end up looking like unresolved symbols.
    % the same problem existed before for exported graphical functions.
    % enums just make it much worse.
    switch(objectType)
    case 'chart'
        allCharts = chartId;
    case 'machine'
        % G448266: Do not check for unresolved symbols in charts that are
        % not instantiated. These charts were not parsed during this compile session
        % and accessing any parse info from these charts will be accessing stale information.
        allCharts = get_instantiated_charts_in_machine(machineId);
    end

    [allowedVariables allowedFunctions] = ...
        collect_custom_code_syms(mainMachineId,targetId,parentTargetId,parseObjectId);
        
    for i=1:length(allCharts)
        if(parser_unresolved_symbol(machineId,...
                                    allCharts(i),...
                                    targetId,...
                                    allowedVariables,...
                                    allowedFunctions))
            throwError = 1;
        end
    end

    % call symbol-wiz no matter what. it will hide the GUI if no symbols.

    symbol_wiz('New',parseObjectId);    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [allowedVariables allowedFunctions] = collect_custom_code_syms(mainMachineId,targetId,parentTargetId,parseObjectId)

allowedVariables.ignoreUnresolvedSymbols = 1;
allowedVariables.symbols = {};
 
allowedFunctions.ignoreUnresolvedSymbols = 1;
allowedFunctions.symbols = {};

if sfc('coder_options','ignoreUnresolvedSymbols')
    return;
end

targetName = sf('get',targetId,'target.name');
if ~strcmp(targetName,'sfun')
    return;
end

customCodeSettings = sfc('private','get_custom_code_settings',targetId,parentTargetId);
if isempty(customCodeSettings.customSourceCode)
    customCode = customCodeSettings.customCode;
else
    customCode = [customCodeSettings.customCode sprintf('\n') ...
                  customCodeSettings.customSourceCode];
end

if isempty(customCode)
    % Since there is no custom code for the S-Function target, therefore 
    % there are no allowed parsed variables or functions.
    %
    % Go directly to the allowed functions section
    allowedVariables.symbols = {};
    allowedParsedFunctions = {};
    allowedMacros = {};
else
    % If you are here, it is an S-Function target which has custom code 
    mainModelName  = sf('get', mainMachineId, 'machine.name');
    cs = getActiveConfigSet(mainModelName);
    parseCC = strcmp(get_param(cs, 'SimParseCustomCode'), 'on');

    if ~parseCC
        return;
    end
    
    % Note: We are currently not using the type information, but it may be
    %       useful in the future
    parseResult = collect_custom_code_symbols(customCodeSettings.machineId, ...
                                              parseObjectId,targetId,parentTargetId,customCode);

    if parseResult.status == 0
        % A Stateflow variable could be represented as a macro, and in the case
        % of the sizeof function, a type, so concatenate these cell arrays together
        allowedVariables.symbols = [parseResult.variables; parseResult.macros; parseResult.types];

        % EDG will return some default allowed functions, which have a "__builtin_"
        % header in front, so strip out the header
        %
        % Note: There is some overlap between allowedParsedFunctions and
        %       defaultAllowedFunctions
        if ~isempty(parseResult.functions)
            allowedParsedFunctions = regexprep(parseResult.functions, '__builtin_{1,3}', '');
        else
            allowedParsedFunctions = {};
        end

        allowedMacros = parseResult.macros;
    else
        % If custom code parsing failed, allow unresloved symbols.
        construct_warning(parseObjectId, 'Parse', 'Failed to parse custom code specified in model configuration parameters dialog: Simulation Target -> Custom Code. Unresolved symbols are not reported.');
        return;
    end
end

allowedVariables.ignoreUnresolvedSymbols = 0;
allowedFunctions.ignoreUnresolvedSymbols = 0;

defaultAllowedFunctions = {
      'min'
      'max'
      'sin'
      'cos'
      'tan'
      'asin'
      'acos'
      'atan'
      'atan2'
      'sinh'
      'cosh'
      'tanh'
      'exp'
      'log'
      'log10'
      'pow'
      'sqrt'
      'ceil'
      'floor'
      'fabs'
      'ldexp'
      'fmod'
      'rand'
      'abs'
      'labs'
      'sizeof'
};

exportedFcnInfo = sf('get',mainMachineId,'machine.exportedFcnInfo');
if isempty(exportedFcnInfo)
    exportedFcnNames = {};
else
    exportedFcnNames = {exportedFcnInfo.name};
end

% Valid functions can come from default allowed function names, 
% parsed function names, exported function names, and macro names.
allowedFunctions.symbols = [defaultAllowedFunctions(:); allowedParsedFunctions(:); exportedFcnNames(:); allowedMacros(:)];
