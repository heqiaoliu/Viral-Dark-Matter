function varargout = simget(varargin)
%SIMGET Get SIM Options structure.
%
% This command is obsolete because of the single-output SIM command syntax.
% However, the SIMGET command will be maintained for the purpose of backwards
% compatibility.
%
%   Struct = SIMGET('MODEL') returns the current SIM command Options 
%   structure for the given Simulink model. The Options structure is used 
%   in the SIM and the SIMSET commands.
%
%   Value = SIMGET(MODEL,property) extracts the value of the named 
%   simulation parameter or the solver property from the model.
%
%   Value = SIMGET(OptionStructure,property) extracts the value of the 
%   named simulation parameter or the solver property from the 
%   OptionStructure. If the value is not specified in the structure, then 
%   Simulink returns an empty matrix. This property can be a cell array  
%   containing the list of the parameter and the property names of interest.  
%   If you use a cell array, then the output is also a cell array.
%
%   You need to enter only as many leading characters of a property name, 
%   as are necessary to uniquely identify it. Simulink ignores case for 
%   property names.
%
%   Struct = SIMGET returns the full options structure with the fields set 
%   to [].
%
%   See also SIM, SIMSET.

%   Loren Dean
%   Copyright 1990-2009 The MathWorks, Inc.
%   $Revision: 1.20.2.15 $


%
% Create an options structure and get its field names.
%
OptionsStructure=simset;
FieldNames=fieldnames(OptionsStructure);

switch nargin,
  case 0,
    varargout{1} = OptionsStructure;
    
  case 1,
    % return full options structure
    if isstruct(varargin{1}),
      varargout{1}=LocalGetEmptyFields(varargin{1},FieldNames);
    % Model name passed in, return options structure
    else
        try
            varargout{1} = LocalGetOptionsStructure(varargin{1});
        catch e
            throw(e);
        end
    end
  case 2,
    if isstruct(varargin{1}),
      Options=varargin{1};
    else
        try
            Options = LocalGetOptionsStructure(varargin{1});
        catch e
            throw(e);
        end
    end
    if ~iscell(varargin{2}),
      Name=varargin(2);
    else
      Name=varargin{2};
    end

    Names=lower(char(FieldNames));
    TempOut=[];
    for CellLp=1:length(Name),
      TempName=lower(Name{CellLp});
      Loc = strmatch(TempName,Names);
      if isempty(Loc), % No matches
        DAStudio.error('Simulink:util:UnrecognizedOption', TempName, 'SIMSET');
      elseif length(Loc) > 1, % More than one match
        % Check for any exact matches
        TempLoc = strmatch(TempName, Names, 'exact');
        if length(TempLoc) == 1,
          Loc = TempLoc;
        else
         DAStudio.error('Simulink:util:AmbiguousOption', name, 'SIMSET');
        end % length
      end % isempty

      % Return a value
      if length(Name)==1,
        TempOut= Options.(FieldNames{Loc});

      % Return a structure
      else
        TempOut{CellLp}=Options.(FieldNames{Loc}); %#ok<AGROW>
      end
    end
    varargout{1}=TempOut;
end % switch

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalGetOptionsStructure %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Struct]=LocalGetOptionsStructure(ModelName)

OpenFlag=1;
ErrorFlag=isempty(find_system(0,'flat','CaseSensitive','off','Name',ModelName));
if ErrorFlag,
  ErrorFlag=~(exist(ModelName)==4); %#ok<EXIST>
  if ~ErrorFlag,
    OpenFlag=0;
    load_system(ModelName);
  end
end
if ErrorFlag,
    DAStudio.error('Simulink:util:ModelNameRequired',ModelName);
end

Struct=simset;
ErrorString={};

%StartTime and StopTime are not part of the structure
%but we should see if they have errors anyway.
ErrorString = LocalGetVal(ModelName,'StartTime',ErrorString);
ErrorString = LocalGetVal(ModelName,'StopTime',ErrorString);

Struct.Solver=get_param(ModelName,'Solver');

Struct.RelTol=get_param(ModelName,'RelTol');
if strcmpi(Struct.RelTol,'auto') == 0
  [ErrorString,Struct.RelTol]=LocalGetVal(ModelName,'RelTol',ErrorString);
end

Struct.AbsTol=get_param(ModelName,'AbsTol');
if strcmpi(Struct.AbsTol,'auto') == 0
  [ErrorString,Struct.AbsTol]=LocalGetVal(ModelName,'AbsTol',ErrorString);
end

[ErrorString,Struct.Refine]=LocalGetVal(ModelName,'Refine',ErrorString);

Struct.MaxStep=get_param(ModelName,'MaxStep');
if strcmpi(Struct.MaxStep,'auto') == 0
  [ErrorString,Struct.MaxStep]=LocalGetVal(ModelName,'MaxStep',ErrorString);
end

Struct.MinStep=get_param(ModelName,'MinStep');
if strcmpi(Struct.MinStep,'auto') == 0
  [ErrorString,Struct.MinStep]=LocalGetVal(ModelName,'MinStep',ErrorString);
end

[ErrorString,Struct.MaxConsecutiveMinStep]=LocalGetVal(ModelName,'MaxConsecutiveMinStep',ErrorString);

Struct.InitialStep=get_param(ModelName,'InitialStep');
if strcmpi(Struct.InitialStep,'auto') == 0
  [ErrorString,Struct.InitialStep]= ...
      LocalGetVal(ModelName,'InitialStep',ErrorString);
end

Struct.MaxOrder=get_param(ModelName,'MaxOrder');

Struct.ConsecutiveZCsStepRelTol=get_param(ModelName,'ConsecutiveZCsStepRelTol');
if strcmpi(Struct.ConsecutiveZCsStepRelTol,'auto') == 0
  [ErrorString,Struct.ConsecutiveZCsStepRelTol]= ...
      LocalGetVal(ModelName,'ConsecutiveZCsStepRelTol',ErrorString);
end
[ErrorString,Struct.MaxConsecutiveZCs]=LocalGetVal(ModelName,'MaxConsecutiveZCs',ErrorString);



Struct.FixedStep=get_param(ModelName,'FixedStep');
if strcmpi(Struct.FixedStep,'auto') == 0
  [ErrorString,Struct.FixedStep]= ...
      LocalGetVal(ModelName,'FixedStep',ErrorString);
end

switch get_param(ModelName,'OutputOption'),
  case 'RefineOutputTimes',
    Struct.OutputPoints='all';
  case 'AdditionalOutputTimes',
    Struct.OutputPoints='all';
  case 'SpecifiedOutputTimes',
    Struct.OutputPoints='specified';
end % switch

TTemp=get_param(ModelName,'SaveTime');
XTemp=get_param(ModelName,'SaveState');
YTemp=get_param(ModelName,'SaveOutput');
Val='';
if TTemp(2)=='n',Val=[Val 't'];end
if XTemp(2)=='n',Val=[Val 'x'];end
if YTemp(2)=='n',Val=[Val 'y'];end
Struct.OutputVariables=Val;

if strcmp(get_param(ModelName,'LimitDataPoints'),'off'),
  Struct.MaxDataPoints=0;
else
 [ErrorString,Struct.MaxDataPoints]= ...
     LocalGetVal(ModelName,'MaxDataPoints',ErrorString);
end

[ErrorString,Struct.Decimation]= ...
    LocalGetVal(ModelName,'Decimation',ErrorString);

if strcmp(get_param(ModelName,'LoadInitialState'),'off'),
  Struct.InitialState=[];
else
  [ErrorString,Struct.InitialState]= ...
      LocalGetVal(ModelName,'InitialState',ErrorString);
end

if strcmp(get_param(ModelName,'SaveFinalState'),'off'),
  Struct.FinalStateName ='';
else
  Struct.FinalStateName =get_param(ModelName,'FinalStateName');
end

Struct.Debug                  ='off'; % Currently forced off
Struct.Trace                  =''; % Currently forced to this
Struct.SrcWorkspace           ='base'; % Currently forced to this value
Struct.DstWorkspace           ='current'; % Currently forced to this value
Struct.ZeroCross              =get_param(ModelName,'ZeroCross');
Struct.SaveFormat             =get_param(ModelName,'SaveFormat');
Struct.SignalLogging          =get_param(ModelName,'SignalLogging');

if strcmp(Struct.SignalLogging,'off'),
  Struct.SignalLoggingName ='';
else
  Struct.SignalLoggingName =get_param(ModelName,'SignalLoggingName');
end

Struct.ExtrapolationOrder = get_param(ModelName,'ExtrapolationOrder');
Struct.NumberNewtonIterations = get_param(ModelName,'NumberNewtonIterations');

if ~OpenFlag,close_system(ModelName,0);end
if ~isempty(ErrorString),
  ParamString='';
  ReturnChar=sprintf('\n');
  for lp=1:length(ErrorString),
    ParamString=[ParamString '    ' ErrorString{lp} ReturnChar]; %#ok<AGROW>
  end % for lp
  ParamString(end)='';

  DAStudio.error('Simulink:util:UndefinedVarsInSimGet',ParamString);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalGetEmptyFields %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function OptionsStructure=LocalGetEmptyFields(OptionsStructure,FieldNames)
for lp=1:length(FieldNames),
  if ~isfield(OptionsStructure,FieldNames{lp}),
      OptionsStructure.(FieldNames{lp}) = [];
  end
end % for

%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalGetVal %%%%%
%%%%%%%%%%%%%%%%%%%%%%%
function [ErrorString,OutputVal]=LocalGetVal(ModelName,Parameter,ErrorString)

OutputVal = slResolve(get_param(ModelName,Parameter),ModelName);
if (isempty(OutputVal) && ~isa(OutputVal,'Simulink.SimState.ModelSimState'))
  ErrorString{end+1}=Parameter;
end % if
