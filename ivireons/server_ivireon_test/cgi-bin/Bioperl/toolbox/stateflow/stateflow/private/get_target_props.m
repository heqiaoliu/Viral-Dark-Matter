function props = get_target_props(targetId, varargin)
% $Revision: 1.1.6.6 $
% Copyright 2008-2009 The MathWorks, Inc.
    
if (nargin<2)
  error('Stateflow:UnexpectedError','No field name');
end

machineId   = sf('get',targetId,'target.machine');
machineName = sf('get',machineId,'machine.name');
targetName  = sf('get',targetId,'target.name');
isRTW       = strcmp(targetName, 'rtw');

if ~isRTW && ~strcmp(targetName,'sfun')
  fields = [];
  for i=1:(nargin-1)
      [csObjName, resultType] = convert_prop_name(true, varargin{i}, isRTW);
      if isempty(csObjName)
          props = '';
          return;
      end
      fields{i} = csObjName;
  end
  props = sf('get', targetId, fields{:});
  return;
end

props = [];
cs    = getActiveConfigSet(machineName);

for i=1:(nargin-1)
  [csObjName, resultType] = convert_prop_name(false, varargin{i}, isRTW);
  if (strcmp(csObjName, 'codeflags'))
    props = get_code_flags(cs, isRTW);
  else
    if (strcmp(resultType, 'bool'))
      re = get_param(cs, csObjName);
      if (strcmp(re, 'on'))
        props = 1;
      else
        props = 0;
      end
    else
      % string property
      % Concatenate custom code settings from submodels
      % Logic should be the same as legacycode.util.lci_getCustomCodeSettings
      if (slfeature('LegacyCodeIntegration') == 1)
        props = '';
        [refMdls, mdlBlks] = find_mdlrefs(machineName);
        for i=1:length(refMdls)
          cs = getActiveConfigSet(refMdls{i});
          if isempty(props)
            props = cs.get_param(csObjName);
          else
            props = sprintf('%s\n%s',props,cs.get_param(csObjName));
          end
        end
      else
        props = cs.get_param(csObjName);
      end
    end
  end
end

return; % End of sfun target section

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function get_code_flags
function output = get_code_flags(cs, isRTW)
  if isRTW

    output = ' comments=';
    if (strcmp(get_param(cs,'GenerateComments'),'on'))
      output = [output '1 statebitsets='];
    else
      output = [output '0 statebitsets='];
    end

    if (strcmp(get_param(cs,'StateBitsets'),'on'))
      output = [output '1 databitsets='];
    else
      output = [output '0 databitsets='];
    end

    if (strcmp(get_param(cs,'DataBitsets'),'on'))
      output = [output '1'];
    else
      output = [output '0'];
    end

  else

    output = ' debug=';
    if (strcmp(get_param(cs,'SFSimEnableDebug'),'on'))
      output = [output '1 overflow='];
    else
      output = [output '0 overflow='];
    end

    if (strcmp(get_param(cs,'SFSimOverflowDetection'),'on'))
      output = [output '1 echo='];
    else
      output = [output '0 echo='];
    end

    if (strcmp(get_param(cs,'SFSimEcho'),'on'))
      output = [output '1 blas='];
    else
      output = [output '0 blas='];
    end

    if (strcmp(get_param(cs,'SimBlas'),'on'))
      output = [output '1 integrity='];
    else
      output = [output '0 integrity='];
    end

    if (strcmp(get_param(cs,'SimIntegrity'),'on'))
      output = [output '1 extrinsic='];
    else
      output = [output '0 extrinsic='];
    end
    
    if (strcmp(get_param(cs,'SimExtrinsic'),'on'))
      output = [output '1 ctrlc='];
    else
      output = [output '0 ctrlc='];
    end
    
    if (strcmp(get_param(cs,'SimCtrlC'),'on'))
      output = [output '1'];
    else
      output = [output '0'];
    end

  end

