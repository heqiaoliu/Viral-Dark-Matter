function set_target_props(targetId, varargin)
% $Revision: 1.1.6.7 $
% Copyright 2008-2009 The MathWorks, Inc.
    
if (nargin<2)
  error('Stateflow:UnexpectedError','No field name');
end

machineId  = sf('get',targetId,'target.machine');
targetName = sf('get',targetId,'target.name');
isRTW      = strcmp(targetName, 'rtw');

%if (sf('get',machineId,'machine.isLibrary')) || ~strcmp(targetName,'sfun')

if ~isRTW && ~strcmp(targetName,'sfun')
  fields = [];
  for i=1:(nargin-1)
    [csObjName, resultType] = convert_prop_name(true, varargin{i}, isRTW);
    if isempty(csObjName)
        return;
    end
    fields{i} = csObjName;
  end
  sf('set', targetId, fields{:});
  return;
end

cs = getActiveConfigSet(sf('get', machineId, 'machine.name'));

for i=1:2:(nargin-1)
  [csObjName, resultType] = convert_prop_name(false, varargin{i}, isRTW);
  if (i + 2 > nargin)
    error('Stateflow:UnexpectedError','Missing set value.');
  end

  re = varargin{i+1};
  if (strcmp(csObjName, 'codeflags'))
    set_code_flags(cs,re);
  else
    if (strcmp(resultType, 'bool'))
      if (re == 1)
        re = 'on';
      else
        re = 'off';
      end
    end
    if isequal(csObjName, 'SimReservedNames')
        cs.set_param('SimReservedNameArray', slprivate('cs_reserved_names_to_array', re));
    elseif isequal(csObjName, 'ReservedNames')
        cs.set_param('ReservedNameArray', slprivate('cs_reserved_names_to_array', re));
    else
        cs.set_param(csObjName, re);
    end
  end
end

return; % End of sfun target section

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function tokenize_code_flags
function flags = tokenize_code_flags(str)
  [first last tokens] = regexp(str,'(\w+)=(\w+)');
  flags = [];
  for i = 1:length(first)
    flags(i).name = str(tokens{i}(1,1):tokens{i}(1,2));
    flags(i).value = str(tokens{i}(2,1):tokens{i}(2,2));
    if ~isempty(regexp(flags(i).value, '^\d+$', 'once'))
      % Numeric value
      flags(i).value = str2num(flags(i).value);
    end
  end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function convert_to_on_off
function output = convert_to_on_off(num)
  if (num == 0)
    output = 'off';
  else
    output = 'on';
  end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function update_cs_property
function update_cs_property(cs,component,property,value)
  if ~(cs.getComponent(component).isReadonlyProperty(property))
    cs.set_param(property,value);
  end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function set_code_flags
function set_code_flags(cs,str)
  flags = tokenize_code_flags(str);

  for i=1:length(flags)
    if ~isnumeric(flags(i).value)
      flags(i).value = 0;
    end

    newValue = convert_to_on_off(flags(i).value);

    if (strcmp(flags(i).name,'debug'))
      update_cs_property(cs, 'Simulation Target', 'SFSimEnableDebug', newValue);
    elseif (strcmp(flags(i).name,'overflow'))
      update_cs_property(cs, 'Simulation Target', 'SFSimOverflowDetection', newValue);
    elseif (strcmp(flags(i).name,'echo'))
      update_cs_property(cs, 'Simulation Target', 'SFSimEcho', newValue);
    elseif (strcmp(flags(i).name,'blas'))
      update_cs_property(cs, 'Simulation Target', 'SimBlas', newValue);
    elseif (strcmp(flags(i).name,'ctrlc'))
      update_cs_property(cs, 'Simulation Target', 'SimCtrlC', newValue);
    elseif (strcmp(flags(i).name,'extrinsic'))
      update_cs_property(cs, 'Simulation Target', 'SimExtrinsic', newValue);
    elseif (strcmp(flags(i).name,'integrity'))
      update_cs_property(cs, 'Simulation Target', 'SimIntegrity', newValue);
    elseif (strcmp(flags(i).name,'comments'))
      if ~(cs.getComponent('Real-Time Workshop').getComponent('Code Appearance').isReadonlyProperty('GenerateComments'))
        cs.set_param('GenerateComments', newValue);
      end
    elseif (strcmp(flags(i).name,'statebitsets'))
      update_cs_property(cs, 'Optimization', 'StateBitsets', newValue);
    elseif (strcmp(flags(i).name,'databitsets'))
      update_cs_property(cs, 'Optimization', 'DataBitsets', newValue);
    end
  end

