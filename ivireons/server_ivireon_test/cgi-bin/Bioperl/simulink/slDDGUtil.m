function varargout = slDDGUtil(source, action, varargin)
% Utility function for Simulink block dialog source objects (subclasses of 
% SLDialogSource). 
% The following signatures are assumed for each action:
% sync:
%   slDialogUtil(source, action, activedlg, widgetType, paramName, paramValue)
% getParamIndex:
%   index = slDialogUtil(source, action, paramName)

% Copyright 2003-2005 The MathWorks, Inc.

switch action
    case 'sync'             % sync any open dialogs
        activeDlg  = varargin{1};
        widgetType = varargin{2}; 
        paramName  = varargin{3};
        paramValue = varargin{4};
        syncDialogs(source, activeDlg, widgetType, paramName, paramValue);

    case 'dataTypeEditFieldDeterminesScaling'
        dataTypeEditFieldRawString = varargin{1};
        varargout{1} = dataTypeEditFieldDeterminesScaling(source,dataTypeEditFieldRawString);
          
    otherwise
     warning('DDG:slDDGUtil','Unknown action');
end


% sync any open dialogs that containts the same properties ---------------------
function syncDialogs(source, activeDlg, widgetType, paramName, paramValue)

r=DAStudio.ToolRoot;
d=r.getOpenDialogs;

for i=1:length(d)
  if ~isequal(activeDlg, d(i)) && isequal(source, d(i).getDialogSource)
    d(i).setWidgetValue(paramName, paramValue);
    d(i).refresh;
  end
end 

function dataTypeDeterminesScaling = dataTypeEditFieldDeterminesScaling(source,dataTypeEditFieldRawString)
  %
  % try to eval directly assuming it contains, no
  % references to variables from other workspaces
  %
  if ~isempty(dataTypeEditFieldRawString)
    dataTypeEditFieldEvaluated = eval(dataTypeEditFieldRawString,'[]');
  else
    dataTypeDeterminesScaling = false;
    return
  end
  %
  % assume data type edit field does NOT determine scaling
  % so by default, if data type edit field is shown
  % then will also show ScalingMode_Popdown, ScalingEditField, LockScaling_CheckBox
  % It is better show these fields and allow user access to them when
  % it can not be robustly determined if data type edit field gives scaling.
  %
  dataTypeDeterminesScaling = false;
  
  try
    if isempty(dataTypeEditFieldEvaluated)
      %
      % if is empty, then assume direct eval failed
      % because of dependence on variable from some workspace above
      %
      if isa(source,'Simulink.DDGSource')
        blk = source.getBlock.Handle;
      else
        blk = source;
      end
      
      maskAbove = 0;
      %
      bdr = get_param(bdroot(blk),'name');
      %
      curParent = get_param(blk,'parent');
      %
      while ~strcmp(curParent,bdr)
        %
        if hasmask(curParent) == 2
          %
          maskAbove = 1;
          break;
        end
        %
        curParent = get_param(curParent,'parent');
      end
      %
      if ~maskAbove
        %
        % no mask above so variables should come from the base 
        % workspace.
        %    Cases where variable comes from a workspace above
        % are too much work to deal with correctly, so the
        % value will just be treated as empty set, which will
        % partially disable dynamic dialogs.  The design goal
        % in these situations is to leave the affected parameters
        % visible and enabled.
        %
        dataTypeEditFieldEvaluated = evalin('base',dataTypeEditFieldRawString,'[]');
      end
    end

    if ~isempty(dataTypeEditFieldEvaluated)

      dataTypeDeterminesScaling = getdatatypespecs(dataTypeEditFieldEvaluated,[],0,0,3);
    end
  catch
  end
