function varargout = buseditor(varargin)
% BUSEDITOR: User Interface to show bus objects

%   Copyright 2003-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.18 $
%   Sanjai Singh

if slfeature('NewBusEditor') == 1
    if ~usejava('jvm')
        DAStudio.error('Simulink:busEditor:RequiresJVM');
    end
    newbuseditor(varargin{:});
    return;
end

if ~usejava('swing')
    DAStudio.error('Simulink:busEditor:RequiresJVM');
end

persistent EDITOR_DATA

% Lock this file now to prevent user tampering
mlock

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Determine what the action is
if (nargin > 0)
  Action = varargin{1};
else
  Action = 'Create';
end
if (nargin > 1)
  args = varargin(2:end);
else
  args = {};
end

switch (Action)
  case 'Create'
    if isempty(args)
      busName = '';
    else
      busName = args{1};
    end
    
    editor_exists = 0;
    
    % Check if editor already created
    if ~isempty(EDITOR_DATA)
      Frame = EDITOR_DATA.Frame;
      editor_exists = 1;
    end

    % Create Bus Editor and store it
    if (editor_exists == 0)
      Frame = CreateBusEditor(busName);
      EDITOR_DATA.Frame = Frame;
    else
      Frame.showBus(busName);
      awtinvoke(Frame,'show()');
    end
    
    if (nargout > 0)
      varargout{1} = Frame;
    end
    
  case 'GetPopulationData'
    % Return data to Populate BusEditor
    varargout{1} = PopulateBusEditor;
    
  case 'SetBusElementData'
    % Set the element data in the bus object specified
    varargout{1} = SetBusElementData(args);

  case 'CreateBus'
    varargout{1} = CreateBus(args);

  case 'AddBusElement'
    varargout{1} = AddBusElement(args);

  case 'RemoveBusElement'
    varargout{1} = RemoveBusElement(args);

  case 'MoveBusElement'
    varargout{1} = MoveBusElement(args);

  case 'RenameBus'
    varargout{1} = RenameBus(args);
    
  case 'RenameBusElement'
    varargout{1} = RenameBusElement(args);
    
  case 'SetDescription'
    SetDescription(args);
      
  case 'SetHeader'
    SetHeader(args);
      
  case 'Help'
    slprophelp('buseditor')

  case 'Close'
    % Check if editor can be closed
    if ~isempty(EDITOR_DATA)
      Frame = EDITOR_DATA.Frame;
      awtinvoke(Frame,'dispose()');
      EDITOR_DATA = [];
    end
    
  case 'GetEditorData'
    varargout{1} = EDITOR_DATA;
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function frame = CreateBusEditor(busName)
% Call constructor
frame = awtinvoke('com.mathworks.toolbox.simulink.buseditor.BusEditor','CreateBusEditor(Ljava/lang/String;)',busName);
%    'CreateBusEditor(Ljava/lang/String;)com.mathworks.toolbox.simulink.buseditor.BusEditor',busName);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data = PopulateBusEditor
% Now populate
import com.mathworks.toolbox.simulink.buseditor.BusObject;
import com.mathworks.toolbox.simulink.buseditor.BusElement;

vars = evalin('base', 'whos');
buses = vars(find(strcmp({vars.class}, 'Simulink.Bus')));
data = cell(length(buses), 1);
for i = 1:length(buses)
  tempBus = evalin('base', buses(i).name);
  bObj = BusObject(buses(i).name, tempBus.Description, tempBus.HeaderFile);
  elems = tempBus.Elements;
  for j= 1:length(elems)
      elemObj = BusElement(elems(j).Name, ...
                           mat2str(elems(j).Dimensions), ...
                           elems(j).DataType, ...
                           mat2str(elems(j).SampleTime), ...
                           elems(j).Complexity, ...
                           elems(j).DimensionsMode, ...
                           elems(j).SamplingMode);
      bObj.addElement(elemObj);
  end
  data{i} = bObj;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function errorMsg = SetBusElementData(args)

busName = args{1};
busElem = args{2};
idx     = args{3};
col     = args{4};
value   = args{5};

% First set it in MATLAB
errorMsg = '';

% Taking care of cases where we might get here while doing auto-refresh of
% the list of bus objects in the base workspace
if ((isempty(busName)) || ...
        (evalin('base', ['exist(''', busName, ''',''var'')']) ~= 1))
  return;
end

try
  switch (col)
    case 1, % Name
      % Uniquefy name of bus element
     elems = evalin('base', [busName '.Elements']);
     matBusElem = elems(idx);
      oldName = matBusElem.Name;
      names   = {};
      for i = 1:length(elems)
        names{i} = elems(i).Name;
      end
      names(idx) = [];
      if any(strcmp(names, value))
        errorMsg = sprintf('A bus element by the name of ''%s'' already exists', value);
        return;
      end
      evalin('base', [busName '.Elements(' num2str(idx) ').Name = ''' value '''']);
    case 2, % Dimension
      evalin('base', [busName '.Elements(' num2str(idx) ').Dimensions = ' value]);
    case 3, % Datatype
      evalin('base', [busName '.Elements(' num2str(idx) ').DataType = ''' value '''']);
    case 4, % SampleTime
      evalin('base', [busName '.Elements(' num2str(idx) ').SampleTime = ' value]);
    case 5, % Complexity
      evalin('base', [busName '.Elements(' num2str(idx) ').Complexity = ''' value '''']);
    case 6, % DimensionsMode/SamplingMode
      evalin('base', [busName '.Elements(' num2str(idx) ').DimensionsMode = ''' value '''']);
    case 7, % SamplingMode
      evalin('base', [busName '.Elements(' num2str(idx) ').SamplingMode = ''' value '''']);
  end
  bus = evalin('base', busName);
  refreshDDG(bus);
catch me
  errorMsg = me.message;
end

% If we succeeded proceed to propagate the changes into the
% corresponding java class.
if isempty(errorMsg)
  switch (col)
    case 1, % Name
      busElem.setName(value);
    case 2, % Dimension
      busElem.setDimensions(value);
    case 3, % Datatype
      busElem.setDataType(value);
    case 4, % SampleTime
      busElem.setSampleTime(value);
    case 5, % Complexity
      busElem.setComplexity(value);
    case 6, % DimensionsMode/SamplingMode
      busElem.setDimensionsMode(value);
    case 7, % SamplingMode
      busElem.setSamplingMode(value);
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function busObject = CreateBus(args)
% Create a new bus object

import com.mathworks.toolbox.simulink.buseditor.BusObject;

busObject = [];

name  = 'BusObject'; newName = name;
count = 1;
while evalin('base', ['exist(''', newName, ''',''var'')'])
  newName = [name, num2str(count)];
  count   = count+1;
end

evalin('base', [newName ' = Simulink.Bus;'])
busObject = BusObject(newName);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function elemObj = AddBusElement(args)
% Add a bus element
import com.mathworks.toolbox.simulink.buseditor.BusObject;
import com.mathworks.toolbox.simulink.buseditor.BusElement;

elemObj = [];
boClass = args{1};
idx     = args{2};

busName = char(boClass.getName);
bus = evalin('base', busName);
elems = bus.Elements;
busElem = Simulink.BusElement;

% Uniquefy name of bus element
oldName = busElem.Name; newName = oldName;
count = 1;
names = {};
for i = 1:length(elems)
  names{i} = elems(i).Name;
end
while any(strcmp(names, newName))
  newName = [oldName num2str(count)];
  count = count + 1;
end
busElem.Name = newName;

elemObj = BusElement(busElem.Name);

if isempty(elems)
  newElems = busElem;
else
  newElems = [elems(1:idx-1); busElem; elems(idx:end)]
end

%this line is needed to hang onto a reference to the bus object
bus.Elements = newElems;
AssignBusElementsInWS({'base', busName, newElems});

%refresh busddg
refreshDDG(bus);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function errorMsg = RemoveBusElement(args)
% Remove a bus element
import com.mathworks.toolbox.simulink.buseditor.BusObject;
import com.mathworks.toolbox.simulink.buseditor.BusElement;

errorMsg = '';
boClass  = args{1};
idx      = args{2};

busName = char(boClass.getName);
bus = evalin('base', busName);
elems = bus.Elements;

try
  if idx==0
    % Delete bus
    evalin('base', ['clear ', busName])
  else
    elems(idx) = [];
    %this line is needed to hang onto a reference to the bus object
    bus.Elements = elems;
    AssignBusElementsInWS({'base', busName, elems});
    %refresh busddg
    refreshDDG(bus);
  end
catch me
  errorMsg = me.message;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function errorMsg = MoveBusElement(args)

errorMsg = '';
boClass  = args{1};
idx      = args{2};
direction= args{3};

busName = char(boClass.getName);
bus = evalin('base', busName);
elems = bus.Elements;

try
  elemToMove = elems(idx);
  elemToReplace = elems(idx + direction);
  elems(idx) = elemToReplace;
  elems(idx + direction) = elemToMove;
  %this line is needed to hang onto a reference to the bus object
  bus.Elements = elems;
  AssignBusElementsInWS({'base', busName, elems});
  %refresh busddg
  refreshDDG(bus);
catch me
  errorMsg = me.message;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function errorMsg = RenameBus(args)
% Rename a bus
import com.mathworks.toolbox.simulink.buseditor.BusObject;

errorMsg = '';
boClass  = args{1};
newName  = char(args{2});

busName = char(boClass.getName);
bus = evalin('base', busName);

if strcmp(newName, busName)
  return;
end

exists = evalin('base', ['exist(''', newName, ''',''var'')'])
if (exists)
  errorMsg = sprintf('A variable by the name of ''%s'' already exists', newName);
  return;
end

assignin('base', newName, bus);
evalin('base',['clear ' busName])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function errorMsg = RenameBusElement(args)
% Rename a bus element
import com.mathworks.toolbox.simulink.buseditor.BusObject;

errorMsg = '';
boClass  = args{1};
beIdx    = args{2};
newName  = char(args{3});

busName = char(boClass.getName);
bus     = evalin('base', busName);
elems   = bus.Elements;
busElem = elems(beIdx);
oldName = busElem.Name;

if (strcmp(newName, oldName))
  return;
end

try
  % Uniquefy name of bus element
  names   = {};
  for i = 1:length(elems)
    names{i} = elems(i).Name;
  end
  names(beIdx) = [];
  if any(strcmp(names, newName))
    errorMsg = sprintf('A bus element by the name of ''%s'' already exists', newName);
    return;
  end
  busElem.Name = newName; %Works because it is by reference
  
  %refresh busddg
  refreshDDG(bus);
catch me
  errorMsg = me.message;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SetDescription(args)

busName     = args{1};
description = args{2};
% When description is multiline evalin fails.
% Work around: Use sprintf after escaping some chars
description = strrep(description, '\', '\\');
description = strrep(description, '''', '''''');
description = strrep(description, '%', '%%');
evalin('base', [busName, '.Description = sprintf(''', ...
                strrep(description, sprintf('\n'), '\n'), ''');']);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SetHeader(args)

busName = args{1};
header  = args{2};

evalin('base', [busName '.HeaderFile = ''' header '''']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function AssignBusElementsInWS(args)
%assign a temp variable in the base workspace with a generated name,
%and do an eval in base that assigns the bus.Elements field to the
%temp variable, and clear it.  We cannot do an assignin 'base' since
%that will make a new reference
ws       = args{1};
busName  = args{2};
newElems = args{3};

newElemVarName = [busName '_tempElem_'];
assignin(ws, newElemVarName, newElems);
evalin(ws, [busName '.Elements = ' newElemVarName]);
evalin(ws, ['clear ' newElemVarName]); %clean up the temp variable

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function refreshDDG(bus)
rt   = DAStudio.ToolRoot;
ddgs = rt.getOpenDialogs;
for i = 1:length(ddgs)
    if isequal(ddgs(i).getDialogSource, bus)
        ddgs(i).refresh;
    end
end


function newbuseditor(varargin)
%
% The new buseditor can be called in 3 ways:
%     1. buseditor - Open the bus editor
%     2. buseditor('Create', XYZ) - Open the bus editor and select XYZ
%     3. buseditor('Close') - Close bus editor
%
persistent be;
args = {};
closeEditor = false;

if (nargin > 0)
  args = varargin(2:end);  
  % If the actions are not valid, return
  if isempty(strmatch(varargin(1), {'Close','Create'}, 'exact')); 
      return;
  end     
  % Create expects exactly one argument (bus name)
  if strcmpi(varargin(1), 'Create') && length(args) ~= 1
      return;
  end
  if strcmpi(varargin(1), 'Close')
      closeEditor = true;
  end
end

if (isempty(be) || ~ishandle(be)) && ~closeEditor
    be = BusEditor.getexplorer;
    % If the BusEditor class is unknown, 'which' loads it
    if isempty(be)
        try
            evalc('which BusEditor.abstractnode;');
        catch me %#ok
        end
        % Try again
        be = BusEditor.explorer;
    end
end

if closeEditor
    if ishandle(be); delete(be); end;
    return;
end

be.show;

if ~isempty(args)
    if ~isempty(args{1}) && evalin('base',['exist(''', args{1}, ''',''var'')']) && ...
            evalin('base',['isa(',args{1},',''', be.getRoot.defaultbasetype, ''')'])        
        BusEditor.cbe_postfocus(be, '');
        nodetoselect = BusEditor.getnodefrompath(be.getRoot,args{1});
        if ~isempty(nodetoselect) && ishandle(nodetoselect)
            BusEditor.setcurrenttreenode(nodetoselect);
        end
    end
end
