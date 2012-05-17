function mStruct = createMATLABStruct(obj, partialStruct)
% Simulink.Bus.createMATLABStruct creates a MATLAB structure or a cell
% array of MATLAB structures having the same shape and attributes as 
% the associated bus signal or bus object. 
% The values of a field in the resulting structure uses the ground value 
% of the corresponding signal in the bus or bus object, unless you override 
% that field in the resulting output structure by specifying a partial 
% structure.
%
%   Usage: 
%     mStruct = Simulink.Bus.createMATLABStruct('BusObject', partialStruct)
%     mStruct = Simulink.Bus.createMATLABStruct(portHandle , partialStruct)
%     cellArrayOfStructures = Simulink.Bus.createMATLABStruct(
%                 arrayOfPortHandles, cellArrayOfPartialStructures)
%
%   Inputs:
%             obj: Name of a bus object in the MATLAB base workspace OR 
%                  Handle to block input or output port OR
%                  Array of handles to block input or output ports
%    
%   partialStruct: Optional argument. 
%                  MATLAB structure OR Cell array of MATLAB structures. 
%                  You can specify [] for port handles that do not 
%                  have a corresponding partial structure in the 
%                  'cellArrayOfPartialStructures' cell array.
%   
%   If you specify a partialStruct, that partial structure sets the values 
%   for matching fields in the generated output structure. The values specified 
%   in the fields of the partial structure must have the same attributes 
%   as the corresponding signals in the bus. 
%   

%   Copyright 1994-2010 The MathWorks, Inc.
    
  % This function expects 1 to 2 inputs
  isOk = (nargin == 1 || nargin == 2);
  if ~isOk
      DAStudio.error('Simulink:tools:slbusInvalidNumInputs');
  end  
  
  % Check validity of partialStruct and/or set default value if not specified
  if nargin == 2
      valid = isstruct(partialStruct) || iscell(partialStruct);
      if ~valid
        DAStudio.error('Simulink:tools:slcreateMATLABStructInvalidSecondArgument');
      end
      if ~ischar(obj)
          if length(obj) ~= length(partialStruct)
              DAStudio.error('Simulink:tools:slcreateMATLABStructInvalidNumSecondArguments');
          end
      else
          if ~isstruct(partialStruct)
              DAStudio.error('Simulink:tools:slcreateMATLABStructInvalidSecondArgument');
          end
      end
  else
      partialStruct = [];
  end
  
  % Depending on the type of input, call the appropriate helper function
  if ischar(obj)
      mStruct = createMATLABStructFromBusObject(obj, partialStruct);
  else
      mStruct = createMATLABStructFromPortHandle(obj, partialStruct);
  end
  
  % Return a single value or a cell array depending on how the user 
  % provided the inputs
  if ~ischar(obj) && ~iscell(partialStruct)
      assert(iscell(mStruct));
      if isscalar(obj)          
          mStruct = mStruct{1};
      end
  end
  
  
%-------------------------------------------------------------------------------
function mStruct = createMATLABStructFromBusObject(BusObject, initValue)
% Helper function to create a MATLAB structure from a BusObject
% We build a dummy model with root inport/outport and use the inport's
% output port to get the bus structure.
%-------------------------------------------------------------------------------

    % Must be a valid bus object and should be present in the base workspace
    if ~isvarname(BusObject) || ...
            evalin('base',['exist(''', BusObject, ''',''var'')']) == 0
        DAStudio.error('Simulink:tools:slcreateMATLABStructInvalidFirstArgument');
    end
    tmpObj = evalin('base', BusObject);
    if ~isa(tmpObj, 'Simulink.Bus')
        DAStudio.error('Simulink:tools:slcreateMATLABStructInvalidFirstArgument');
    end
    
    % Cache existing warning settings to restore after compile
    currentWarningSettings = warning;
    try      
    
        % Create a new system
        model = 'TmpModelForCreatingMATLABStruct';
        new_system(model);
        
        % Set model to strict bus lvl1
        set_param(model, 'StrictBusMsg', 'ErrorLevel1');
        
        % Add root inport and outport
        in1 = add_block('built-in/Inport', [model '/In1']);
        set_param(in1,'Position', [65    45    85    65]);
        
        % Set BusObject name on root inport (NVB)
        % The validity of the bus object, if it exists, will be checked here,
        % invalid bus object will cause exception to be thrown here.
        try 
            set_param(in1, 'UseBusObject', 'on');
            set_param(in1, 'BusObject', BusObject);
        catch me1
            errid = 'Simulink:tools:slcreateMATLABStructFromBusObject';
            InvalidBusObjectME = MException(errid, DAStudio.message(errid));
            InvalidBusObjectME = addCause(InvalidBusObjectME, me1);
            throw(InvalidBusObjectME);
        end
        set_param(in1, 'BusOutputAsStruct', 'on');
        set_param(in1, 'SkipBusObjectTsCheckForBusSrc','on');
        set_param(in1, 'Interpolate', 'off');
        
        
        term = add_block('built-in/Terminator', [model '/Terminator']);
        set_param(term,'Position', [170    45   190    65]);
        
        % Add the following connection to eliminate error related to empty block diagram
        
        in2 = add_block('built-in/Inport', [model '/In2']);
        set_param(in2,'Position', [65    90    85   110]);
        
        out = add_block('built-in/Outport', [model '/Out']);
        set_param(out,'Position', [170    90   190   110]);
        
        % Connect the inport and outport blocks
        add_line(model, 'In1/1', 'Terminator/1');
        add_line(model, 'In2/1', 'Out/1');
        
        % Turn-off data logging (does not work with NVB)
        set_param(model,'SaveOutput','off')
        set_param(model, 'Solver', 'FixedStepDiscrete');
        set_param(model, 'FixedStep', '1');
        
        ph = get_param(in1, 'PortHandles');    
        warning('off'); %#ok
        mStruct = compileModelAndGetStruct(model, ph.Outport, true);    
        assert(iscell(mStruct) && length(mStruct) == 1);
        mStruct = mStruct{1};
        warning(currentWarningSettings);
        bdclose(model);      
    catch me
        warning(currentWarningSettings);
        bdclose(model);
        throwAsCaller(me);
    end
    
    % Assign the user provided partial structure values in the generated structure
    if isstruct(initValue)
        mStruct = populateWithUserProvidedStructure(mStruct, initValue, '');
    end
    

%-------------------------------------------------------------------------------
function mStruct = createMATLABStructFromPortHandle(portHandles, initValue)  
% Helper function to create a MATLAB structure having the same shape and 
% attributes as specified by one or more portHandle
%-------------------------------------------------------------------------------
    if isempty(portHandles)
        DAStudio.error('Simulink:tools:slcreateMATLABStructInvalidFirstArgument');
    end
    
    % Treat all inputs as vector inputs
    if ~iscell(initValue)
        tmpInitValue = cell(length(portHandles), 1);
        for idx = 1:length(portHandles)
            tmpInitValue{idx} = initValue;
        end
        initValue = tmpInitValue;
    end
    
    % Validate port handle and partial structure
    for idx = 1:length(portHandles)
        ph = portHandles(idx);
        ic = initValue{idx};
        
        if ~(isstruct(ic) || isempty(ic))
            DAStudio.error('Simulink:tools:slcreateMATLABStructInvalidSecondArgument');
        end
        
        if ~ishandle(ph)
            DAStudio.error('Simulink:tools:slcreateMATLABStructInvalidFirstArgument');
        else
            if ~isa(handle(ph), 'Simulink.Port')
                DAStudio.error('Simulink:tools:slcreateMATLABStructInvalidFirstArgument');
            end
        end
    end

    % Use the first portHandle to infer model name
    model = bdroot(get_param(portHandles(1), 'Parent'));
    
    % Require the model to have strict bus diagnostic set to error level 1 or above
    if ~isempty(strmatch(get_param(model, 'StrictBusMsg'), {'None','Warning'}, 'exact'))
        DAStudio.error('Simulink:tools:slcreateMATLABStructStrictBusRequired');
    end
  
    % Ensure that model is not already in compile
    simStatus = get_param(model, 'SimulationStatus');
    if ~strcmpi(simStatus, 'stopped')
        DAStudio.error('Simulink:tools:slcreateMATLABStructBadSimulationStatus', ...
                       model, simStatus);
    end
    
    % Compile the model and generate bus structures for each portHandle
    mStruct = compileModelAndGetStruct(model, portHandles, false);
    
    % Assign the user provided partial structure values in the generated structure
    for idx = 1:length(initValue)
        if isstruct(initValue{idx})
            mStruct{idx} = populateWithUserProvidedStructure(mStruct{idx}, initValue{idx}, '');
        end
    end

%-------------------------------------------------------------------------------
function mStruct = compileModelAndGetStruct(model, portHandles, tmpModel)
% Helper function that compiles the model and calls the busDiagnostics API to 
% retrieve the MATLAB struct at one or more portHandles
%-------------------------------------------------------------------------------    
    mdlIsCompiled = false;    
    mStruct = cell(length(portHandles), 1);
    
    for idx = 1:length(portHandles)
        % Set flag for compBus caching
        set_param(portHandles(idx), 'CacheCompiledBusStruct','on');
    end

    % Put the model in compile mode. Report an error if we cannot compile the model.
    try
        feval(model, [],[],[],'compile');
        mdlIsCompiled = true;
    catch me
        assert(~mdlIsCompiled);
        if(tmpModel)
            new_me = MException('Simulink:tools:slcreateMATLABStructFromBusObject', ...
                         DAStudio.message('Simulink:tools:slcreateMATLABStructFromBusObject'));
            new_me = addCause(new_me, me);
       
            throwAsCaller(new_me);
        else
            throwAsCaller(me);
        end
    end
    
    % Get struct, and terminate model
    try
        for idx = 1:length(portHandles)
            % Call API to get the MATLAB structure for portHandle
            mStruct{idx} = slInternal('busDiagnostics','bus2struct', portHandles(idx));
        end
        
        % Term compile
        feval(model, [],[],[],'term');
    catch me
        assert(mdlIsCompiled);
        feval(model, [],[],[],'term');
        throwAsCaller(me);
    end
 
%-------------------------------------------------------------------------------
function mStruct = populateWithUserProvidedStructure(mStruct, initValue, path)
% Helper function that replaces elements in the generated structure with the 
% corresponding fields from the user provided structure 
%-------------------------------------------------------------------------------
    assert(isstruct(mStruct));    
    
    userFields = fieldnames(initValue);
    genFields = fieldnames(mStruct);
    
    for udx = 1:length(userFields)
        for gdx = 1:length(genFields)
            if strcmp(userFields{udx}, genFields{gdx})
                if isempty(path)
                    tmpPath = genFields{gdx};
                else
                    tmpPath = [path, '.', genFields{gdx}];
                end
                
                genFieldIsStruct = isstruct(mStruct.(genFields{gdx}));
                userFieldIsStruct = isstruct(initValue.(userFields{udx}));                
                
                if (genFieldIsStruct == userFieldIsStruct)
                    if (genFieldIsStruct)
                        % If both are structures, dive-in
                        mStruct.(genFields{gdx}) = populateWithUserProvidedStructure(...
                            mStruct.(genFields{gdx}), initValue.(userFields{udx}), tmpPath);
                    else
                        % Check for element attribute inconsistencies
                        checkLeafNodesForAttributeConsistency(...
                            mStruct.(genFields{gdx}), initValue.(userFields{udx}), tmpPath);
                        mStruct.(genFields{gdx}) = initValue.(userFields{udx});
                    end
                else
                    % If there is a shape inconsistency, warn and continue
                    DAStudio.error('Simulink:tools:slcreateMATLABStructBadFieldInPartialStructure', tmpPath);
                end
            end
        end
    end

%-------------------------------------------------------------------------------
function checkLeafNodesForAttributeConsistency(mGen, mInit, path)
% Helper function that checks that the generated leaf and the user provided leaf values 
% are consistent before assignment.
%-------------------------------------------------------------------------------    

    % Dimensions mismatch
    if ~isequal(size(mGen), size(mInit))
        DAStudio.error('Simulink:tools:slcreateMATLABStructBadFieldAttributeDimensions', ...
                         path, mat2str(size(mInit)), mat2str(size(mGen)));
    end
    
    % Data type mismatch
    genDType = class(mGen);
    initDType = class(mInit);
    
    if ~isequal(genDType, initDType)
        DAStudio.error('Simulink:tools:slcreateMATLABStructBadFieldAttributeDataType', ...
                         path, initDType, genDType);
    else
        if isa(mGen, 'embedded.fi')
            genDType = mGen.numerictype.tostring;
            initDType = mInit.numerictype.tostring;            
            if ~strcmp(genDType, initDType)
                DAStudio.error('Simulink:tools:slcreateMATLABStructBadFieldAttributeDataType', ...
                                 path, initDType, genDType);
            end
        end
    end
    
    % Complexity mismatch
    genComplex = isreal(mGen);
    initComplex = isreal(mInit);
    if ~isequal(genComplex, initComplex)
        if genComplex
            genComplex = 'real';
        else
            genComplex = 'complex';
        end
        if initComplex
            initComplex = 'real';
        else
            initComplex = 'complex';
        end
        DAStudio.error('Simulink:tools:slcreateMATLABStructBadFieldAttributeComplexity', ...
                         path, initComplex, genComplex);
    end
    
    
