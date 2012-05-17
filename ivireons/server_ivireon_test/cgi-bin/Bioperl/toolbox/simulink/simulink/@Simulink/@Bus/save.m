function save(fileName, format, busNames) 
% Simulink.Bus.save saves bus objects in a MATLAB file.
%
% Simulink.Bus.save saves bus objects in cell or bus object format 
%   in a MATLAB file. 
%
%   Usage: Simulink.Bus.save(fileName, format, busNames) 
%
%   Inputs:
%      fileName: Name of the file to store the bus objects
%      format:   May be 'cell' or 'object' or omitted in which
%                case 'cell' is assumed. Use cell format to save the 
%                objects in a compact form. 
%      busNames: A cell array containing names of bus objects to be saved.
%                If the cell array is empty, all bus objects in the 
%                base workspace will be saved.
%
%   The generated MATLAB file for the cell format will include a call to 
%   Simulink.Bus.cellToObject to recreate the bus objects when it is executed. In
%   addition, the generated MATLAB file will return the cell array when executed.
%   To suppress the creation of bus objects when the generated MATLAB file is run,
%   supply an optional argument 'false' to the MATLAB file when executing it.
%  
%   Example:
%   Simulink.Bus.save(fileName)            Saves all bus objects in cell format
%   Simulink.Bus.save(fileName, 'object')  Saves all bus objects in bus object 
%                                          format
%   Simulink.Bus.save(fileName, 'cell', {'myBus'}) Saves myBus in a MATLAB file
%
%   See also Simulink.Bus.cellToObject
%
  
%
%   Copyright 1994-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.10.2.1 $
  
% do not disp backtraces when reporting warning
wStates = [warning; warning('query','backtrace')];
warning off backtrace;
warning on; %#ok

try
  fid = -1;
  % This function expects one to three arguments
  isOk = nargin < 1 || nargin > 3;
  if isOk
      DAStudio.error('Simulink:tools:slbusInvalidNumInputs');
  end
  
  % Fill with default values if the inputs are not specified
  if nargin < 2
    format  = 'cell';
  end
  
  if nargin < 3
    busNames = {};
  end
  
  % Inputs must be string
  if ~ischar(fileName) || ~ischar(format) 
      DAStudio.error('Simulink:tools:slbusSaveInvalidFirstArg');
  end
  
  % Check file name extension
  [pathStr, fcnName, ext] = fileparts(fileName); %#ok
  if isempty(ext) 
    fileName = [fileName, '.m'];
  elseif ~strcmp(ext, '.m')
      DAStudio.error('Simulink:tools:slbusSaveInvalidExt');
  end

  % error if the file exists
  if exist(fileName, 'file')
      DAStudio.error('Simulink:tools:slbusSaveFileAlreadyExists', fileName, fileName);
  end
  
  % Check the path
  if ~isempty(pathStr) && ~exist(pathStr, 'dir')
      DAStudio.error('Simulink:tools:slbusSaveDirDoesNotExist');
  end
  
  % format must be 'cell' or 'object'
  if ~(strcmpi(format, 'cell') || strcmpi(format,'object'))
      DAStudio.error('Simulink:tools:slbusSaveInvalidSecondArg');
  end
  
  % Check busName
  isOk = iscell(busNames);
  if isOk 
    for idx = 1:length(busNames)
      if ~isvarname(busNames{idx})
        isOk = false;
        break;
      end
    end
  end
  
  if ~isOk
      DAStudio.error('Simulink:tools:slbusSaveInvalidThirdArg');
  end
  
  % Open the file name
  [fid, message] = fopen(fileName,'wt');
  if fid == -1
      DAStudio.error('Simulink:tools:slbusSaveFileOpenError', fileName, message);
  end
  
  if strcmpi(format,'cell')
    save_bus_in_cell_format_l(fid, fileName, busNames);
  else
    save_bus_in_object_format_l(fid, fileName, busNames);
  end
  
  save_nonbus_numeric_dtypes_l(fid, busNames);
  
  fclose(fid);
catch me
  if fid ~= -1
      fclose(fid);
      delete(fileName);
  end
  cleanup_l(wStates);
  rethrow(me);
end
cleanup_l(wStates);

%endfunction

% Function cleanup_l ==========================================================
%   Reset the warning to its original state.
function cleanup_l(wStates)
warning(wStates); %#ok
%endfunction

% Function save_bus_in_cell_format_l ==========================================
% Abstract:
%    It saves either all bus objects in the base workspace or 
%    the specified buses in cell format in a MATLAB file.
%
function save_bus_in_cell_format_l(fid, fileName, busNames)

[pathStr, fcnName] = fileparts(fileName); %#ok
  
fprintf(fid,'function cellInfo = %s(varargin) \n', fcnName);
tmpStr = 'returns a cell array containing bus object information';
fprintf(fid,'%% %s %s \n', upper(fcnName), tmpStr);
fprintf(fid,'%% \n');
fprintf(fid, '%% Optional Input: ''false'' will suppress a call to Simulink.Bus.cellToObject \n');
fprintf(fid, '%%                 when the MATLAB file is executed. \n');
fprintf(fid,'%% The order of bus element attributes is as follows:\n');
tmpStr = ['ElementName, Dimensions, DataType, SampleTime, ', ...
          'Complexity, SamplingMode, DimensionsMode'];
fprintf(fid,'%%   %s \n\n', tmpStr);

fprintf(fid, 'suppressObject = false; \n');
fprintf(fid, 'if nargin == 1 && islogical(varargin{1}) && varargin{1} == false \n');
fprintf(fid, '    suppressObject = true; \n');
fprintf(fid, 'elseif nargin > 1 \n');
fprintf(fid, '    error(''Invalid input argument(s) encountered''); \n');
fprintf(fid, 'end \n\n');

fprintf(fid, 'cellInfo = { ... \n');

%
% Call objectToCell to convert the bus objects to a cell array. Note that if busNames
% is empty, objectToCell will convert all bus objects in the base workspace automatically.
%
busCell = Simulink.Bus.objectToCell(busNames);

for i=1:length(busCell)
    bus = busCell{i};
    fprintf(fid, '  { ... \n');
    fprintf(fid, '    ''%s'', ... \n', bus{1});   % Name
    fprintf(fid, '    ''%s'', ... \n', bus{2});   % HeaderFile
    % Multiline descriptions containing newline does not enable creation 
    % of valid cell array in the generated MATLAB file.
    % So, use sprintf to assign descriptions to these.     
    busDesc = ['sprintf(''', strrep(escapeForSprintf(bus{3}), ...
        sprintf('\n'), '\n'), ''')'];
    fprintf(fid, '    %s, { ... \n', busDesc); % Description

    for j=1:length(bus{4})
        el = bus{4}{j};
        dimsStr = sl('busUtils', 'GetDimsStr', el{2});
        tsStr   = sl('busUtils', 'GetSampleTimeStr', el{4});
        % Handle data types with quotes: fixdt('double', 'DataTypeOverride', 'Off')
        dataTypeStr = strrep(el{3},'''','''''');
        % name, dims, dataType, sampleTime, cplx, frames, dimsMode
        fprintf(fid, ...
                '      {''%s'', %s, ''%s'', %s, ''%s'', ''%s'', ''%s''}; ...\n', ...
                el{1}, dimsStr, dataTypeStr, tsStr, el{5}, el{6}, el{7});
    end
    fprintf(fid, '    } ...\n');
    fprintf(fid, '  } ...\n');
end

fprintf(fid,  '}''; \n\n');

fprintf(fid, 'if ~suppressObject \n');
fprintf(fid, '    %% Create bus objects in the MATLAB base workspace \n');
fprintf(fid, '    Simulink.Bus.cellToObject(cellInfo) \n');
fprintf(fid, 'end \n');


%endfunction save_bus_in_cell_format_l


% Function save_bus_in_object_format_l ========================================
% Abstract:
%    It saves either all bus objects in the base workspace or 
%    the specified buses in object format in a MATLAB file.
%    
function save_bus_in_object_format_l(fid, fileName, busNames)

[pathStr, fcnName] = fileparts(fileName); %#ok

fprintf(fid,'function %s() \n', fcnName);
tmpStr = 'initializes a set of bus objects in the MATLAB base workspace';
fprintf(fid,'%% %s %s \n\n', upper(fcnName), tmpStr);

if isempty(busNames)
  var = evalin('base','whos');
  for idx = 1:length(var)
    if (strcmp(var(idx).class,'Simulink.Bus'))
      save_one_bus_in_object_format_l(fid, var(idx).name);
    end
  end
else
  for idx = 1:length(busNames)
    save_one_bus_in_object_format_l(fid, busNames{idx});
  end
end

%endfunction save_bus_in_object_format_l

% Function save_one_bus_in_object_format_l ====================================
% Abstract:
%   Save one bus object in the object format in the file.
%
function save_one_bus_in_object_format_l(fid, busName)

  fprintf(fid, '%% Bus object: %s \n', busName);
  fprintf(fid,'clear elems;\n');

  busObj = sl('slbus_get_object_from_name', busName);
  elems = busObj.Elements;
  
  for eIdx = 1:length(elems)
    thisElm = elems(eIdx);
    
    fprintf(fid,'elems(%d) = Simulink.BusElement;\n',eIdx);
    fprintf(fid,'elems(%d).Name = ''%s'';\n', eIdx, thisElm.Name);

    dimsStr = sl('busUtils', 'GetDimsStr', thisElm.Dimensions);
    fprintf(fid,'elems(%d).Dimensions = %s;\n', eIdx, dimsStr);
    
    fprintf(fid,'elems(%d).DimensionsMode = ''%s'';\n', eIdx, thisElm.DimensionsMode);
            
    % Handle data types with quotes: fixdt('double', 'DataTypeOverride', 'Off')
    dataTypeStr = strrep(thisElm.DataType,'''','''''');
    fprintf(fid,'elems(%d).DataType = ''%s'';\n', eIdx, dataTypeStr);
    
    tsStr = sl('busUtils', 'GetSampleTimeStr', thisElm.SampleTime);
    fprintf(fid,'elems(%d).SampleTime = %s;\n', eIdx, tsStr);
    
    fprintf(fid,'elems(%d).Complexity = ''%s'';\n', eIdx, thisElm.Complexity);
    fprintf(fid,'elems(%d).SamplingMode = ''%s'';\n',eIdx,thisElm.SamplingMode);
    
    fprintf(fid,'\n');
  end

  headerFile = busObj.HeaderFile;
  
  fprintf(fid,'%s = Simulink.Bus;\n',busName);
  fprintf(fid,'%s.HeaderFile = ''%s'';\n', busName, headerFile);
  % Multiline descriptions containing newline does not enable creation 
  % of valid cell array in the generated MATLAB file.
  % So, use sprintf to assign descriptions to these.     
  description = ['sprintf(''', ...
      strrep(escapeForSprintf(busObj.Description), ...
      sprintf('\n'), '\n'), ''')'];
  fprintf(fid, '%s.Description = %s;\n', busName, description);    

  if ~isempty(elems)
    fprintf(fid,'%s.Elements = elems;\n',busName);
  end
  fprintf(fid, 'assignin(''base'', ''%s'', %s)\n', busName, busName);
  fprintf(fid,'\n');
  
%endfunction save_one_bus_in_object_format_l
 
% Function: save_nonbus_numeric_dtypes_l ======================================
% Abstract:
%    Also add the numeric data types to the file.
% 
function busDataTypes = save_nonbus_numeric_dtypes_l(fid, busNames)
  
  busDataTypes  ={};
  if isempty(busNames)
    var = evalin('base','whos');
    for idx = 1:length(var)
      if (strcmp(var(idx).class,'Simulink.Bus'))
        busNames{end+1} = var(idx).name; %#ok
      end
    end
  end
  % We have a list of bus names
  
  for idx = 1:length(busNames)
    bus = evalin('base', busNames{idx});
    for yidx = 1:length( bus.Elements)
      elem = bus.Elements(yidx);
      % This can be generalized in future
      if strncmp(elem.DataType, 'slnum_', 6)
        % Numeric data types are generated using slnum_ prefix
        % See slbus_gen_object
        dtypeName  = elem.DataType;
        fixptdtype = elem.DataType(7:end);
        
        tmpStr = [dtypeName, ' = fixdt(''', fixptdtype, ''');\n'];
        fprintf(fid,tmpStr);
        
        tmpStr = ['assignin(''base'', ''',dtypeName,''', ',dtypeName,');\n'];
        fprintf(fid,tmpStr);
      end
    end
  end
%endfunction

function outStr = escapeForSprintf( str )
% Escape the input string where required for use with sprintf

  outStr = strrep(str, '\', '\\');
  outStr = strrep(outStr, '''', '''''');
  outStr = strrep(outStr, '%', '%%');
