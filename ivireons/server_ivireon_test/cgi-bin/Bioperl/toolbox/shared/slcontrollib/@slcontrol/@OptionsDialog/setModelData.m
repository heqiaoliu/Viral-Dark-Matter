function isOK = setModelData(this)
% SETMODELDATA Update the model data from the view settings

% Author(s): Bora Eryilmaz
% Revised: A. Stothert
% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.6.13 $ $Date: 2009/07/09 20:55:01 $

% Modal data update status
isOK = false;

% Save the original data
simopts = get( this.SimOptionForm );
optopts = get( this.OptimOptionForm );

% Update the option objects
if this.showSimOptions
   LocalUpdateSimOptions(this)
end
if this.showOptimOptions
   LocalUpdateOptimOptions(this)
end
if this.showParallelOptions
   LocalUpdateParallelOptions(this)
end

% Get list of variable names in model workspace
if ~isempty(this.Model)
   ModelWS = get_param(this.Model, 'ModelWorkspace');
   s = whos(ModelWS);
   ModelWSVars = {s.name};
else
   ModelWS     = [];
   ModelWSVars = {};
end

% Evaluate simulation & optimization settings
try
  if this.showOptimOptions
     evalForm( this.OptimOptionForm, ModelWS, ModelWSVars );
  end
  if this.showSimOptions
     evalForm( this.SimOptionForm,   ModelWS, ModelWSVars );
  end
catch E
  util = slcontrol.Utilities;
  dlg = errordlg( util.getLastError(E), 'Options Error', 'modal' );
  % In case the dialog is closed before uiwait blocks MATLAB.
  if ishandle(dlg)
    uiwait(dlg)
  end

  % Revert back property values
  if this.showSimOptions
     set(this.SimOptionForm, simopts);
  end
  if this.showOptimOptions
     set(this.OptimOptionForm, optopts);
  end
  setViewData(this)
  return
end

% Notify listeners of option changes.
OptionChanged = false;
if this.showSimOptions && ~isequal( simopts, get(this.SimOptionForm) )
   OptionChanged = true;
end
if this.showOptimOptions && ~isequal( optopts, get(this.OptimOptionForm) )
   OptionChanged = true;
end
if OptionChanged
   %Fire event notifying listeners data changed
   this.send('OptionsChanged')
end

% Successful data update
isOK = true;
end

% --------------------------------------------------------------------------
function LocalUpdateSimOptions(this)
h = this.SimOptionForm;
Handles = this.SimOptionHandles;

info    =   cell( Handles.Panel.getFields );
indices = double( Handles.Panel.getIndices ) + 1; % Matlab indexing

% Update numeric settings
Fields = { 'StartTime',   'StopTime',  'MaxStep', 'MinStep', ...
	   'InitialStep', 'FixedStep', 'RelTol',  'AbsTol' };
LocalSetInfo(Fields, h, info);

% Solvers
typeidx = indices(1);
switch typeidx
   case 1
      h.Solver = 'auto';
   case 2
      h.Solver = this.VariableStepSolvers{ indices(2) };
   case 3
      h.Solver = this.FixedStepSolvers{ indices(2) };
end

% Zero crossing
onoff = {'off', 'on'};
h.ZeroCross = onoff{ indices(3) };
end

% --------------------------------------------------------------------------
function LocalUpdateOptimOptions(this)
h = this.OptimOptionForm;
Handles = this.OptimOptionHandles;

info    =   cell( Handles.Panel.getFields );
indices = double( Handles.Panel.getIndices ) + 1; % Matlab indexing

% Update numeric settings
Fields = { 'DiffMaxChange', 'DiffMinChange', 'TolCon', 'TolFun', 'TolX', ...
	   'MaxFunEvals', 'MaxIter', 'Restarts', 'SearchLimit' };
LocalSetInfo(Fields, h, info);

% Method
mthd = set(h, 'Method');
h.Method = mthd{ indices(1) };

% Algorithm
alg = set(h, 'Algorithm');
switch h.Method
  case 'lsqnonlin'
    alg = alg(~ismember(alg, {'active-set','interior-point'}));
  case 'fmincon'
    alg = alg(~ismember(alg, {'levenberg-marquardt'}));  % Remove LM for fmincon.
end
h.Algorithm = alg{ indices(2) };

% Display options
dspl = set(h, 'Display');
h.Display = dspl{ indices(3) };

% Gradient model
grad = set(h, 'GradientType');
h.GradientType = grad{ indices(4) };

% Check for optional fields
fieldNames = fieldnames(h);
idx = 5;

% Cost function type
if any( strcmp('CostType', fieldNames) )
  cost = set(h, 'CostType');
  h.CostType = cost{ indices(idx) };
  idx = idx+1;
end

% Robust algorithm
if any( strcmp('RobustCost', fieldNames) )
  robust = {'off', 'on'};
  h.RobustCost = robust{ indices(idx) };
  idx = idx + 1;
end

% Interior-point search
if any( strcmp('MaximallyFeasible', fieldNames) )
  h.MaximallyFeasible = indices(idx)-1;  % True/false
  idx = idx + 1;
end

% Search method
srch = set(h, 'SearchMethod');
h.SearchMethod = srch{ indices(idx) };
end

% -------------------------------------------------------------------------
function LocalUpdateParallelOptions(this)
h = this.OptimOptionForm;

if double(this.Dialog.getParallelOptionPanel.getIndices)
   h.UseParallel = 'always';
else
   h.UseParallel = 'never';
end

if strcmp(h.UseParallel,'always')
   pathDepend = this.getPathsFromUI;
   if numel(pathDepend)==1 && isempty(pathDepend{1})
      %No path dependencies
      h.ParallelPathDependencies = {ctrlMsgUtils.message('SLControllib:slcontrol:warnNoPathDependencies')};
   else
      h.ParallelPathDependencies = pathDepend;
      %Display warning if paths are not valid
      idx = false(size(pathDepend));
      for ct = 1:numel(pathDepend)
	 idx(ct) = ~exist(pathDepend{ct},'dir');
      end
      if any(idx)
	 msg = pathDepend(idx);
	 msg = strcat(msg,'\n');
	 msg = sprintf(strcat(msg{:}));
	 com.mathworks.mwswing.MJOptionPane.showMessageDialog(this.Dialog,...
	    ctrlMsgUtils.message('SLControllib:slcontrol:warnPathDependencyNotFound',msg),...
	    sprintf('Response Optimization'),com.mathworks.mwswing.MJOptionPane.WARNING_MESSAGE)
      end
   end
 end
end

% --------------------------------------------------------------------------
function LocalSetInfo(Fields, h, info)
[~, ia] = intersect( Fields, fieldnames(h) );
ia = sort(ia);

for ct = 1:length(ia)
  idx = ia(ct);
  f = Fields{idx};
  h.(f) = info{ct};
end
end
