function rtwdemo_advsc_data(sc)
%RTWDEMO_ADVSC_INIT  Define Simulink data objects for advanced data packaging demo.

% $Revision: 1.1.8.2 $
% $Date: 2005/12/19 07:38:20 $
%
% Copyright 1994-2005 The MathWorks, Inc.

switch nargin
 case 0
  sc = 'Auto';
 case 1
  % No action
 otherwise
  error('Invalid number of input arguments.');
end

evalin('base', 'clear');

% Define data type object
l_CreateData('MYTYPE',  'DataType', 'Double');

% Define signals
l_CreateData('input1',  'Signal', sc, 'MYTYPE');
l_CreateData('input2',  'Signal', sc, 'MYTYPE');
l_CreateData('input3',  'Signal', sc, 'MYTYPE');
l_CreateData('input4',  'Signal', sc, 'MYTYPE');
l_CreateData('output',  'Signal', sc, 'MYTYPE');

% Define states
l_CreateData('mode', 'State', sc, 'boolean');
l_CreateData('X',    'State', sc, 'MYTYPE');

% Define parameters
l_CreateData('K1',      'Parameter', sc, int8(2));
l_CreateData('K2',      'Parameter', sc, int8(3));
l_CreateData('T1Break', 'Parameter', sc, [-5:5]);
l_CreateData('T1Data',  'Parameter', sc, [-1,-0.99,-0.98,-0.96,-0.76,0,0.76,0.96,0.98,0.99,1]);
l_CreateData('T2Break', 'Parameter', sc, [1:3])
l_CreateData('T2Data',  'Parameter', sc, [4 5 6;16 19 20;10 18 23]);
l_CreateData('UPPER',   'Parameter', sc, 10);
l_CreateData('LOWER',   'Parameter', sc, -10);

% Set color of current configuration block.
model = get_param(bdroot(gcbh), 'Handle');
configBlks = find_system(model, 'MaskType', 'Advanced data packaging - create data');
for idx = 1:length(configBlks)
  set_param(configBlks(idx), 'BackGroundColor', 'Gray');
end
set_param(gcbh, 'BackGroundColor', 'Red');


%============================================================
% SUBFUNCTIONS:
%============================================================
function l_CreateData(name, dClass, varargin)
% Create a data object in the base workspace

% Special handling for different classes of data.
switch dClass
 case 'DataType'
  nargchk(3, 3, nargin);
  tmpObj = Simulink.NumericType;
  % Set DataTypeMode
  tmpObj.DataTypeMode = varargin{1};
  tmpObj.IsAlias = true;
  
 case 'Parameter'
  nargchk(4, 4, nargin);
  tmpObj = Simulink.Parameter;
  % Set Value
  sc = varargin{1};
  tmpObj.Value = varargin{2};
  % Set StructName for Custom storage class
  structName = 'PARAM';
  
 case {'Signal', 'State'}
  nargchk(4, 4, nargin);
  tmpObj = Simulink.Signal;
  % Set state attributes
  sc = varargin{1};
  tmpObj.DataType = varargin{2};
  tmpObj.Dimensions = 1;
  tmpObj.Complexity = 'real';
  tmpObj.SampleTime = 1;
  tmpObj.SamplingMode = 'Sample based';
  
  % Set StructName for Custom storage class
  if isequal(dClass, 'Signal')
    structName = 'SIGNAL';
  else
    structName = 'STATE';
  end      
 otherwise
  error('Invalid data object class.');
end

if exist('sc', 'var')
  % Set common data attributes:
  % - StorageClass
  tmpObj.RTWInfo.StorageClass = sc;
  
  % - CustomStorageClass
  if strcmp(sc, 'Custom')
    tmpObj.RTWInfo.CustomStorageClass = 'Struct';
    tmpObj.RTWInfo.CustomAttributes.StructName = structName;
  end
end

% Add variable to base workspace.
assignin('base', name, tmpObj);
  
%endfunction

% EOF
