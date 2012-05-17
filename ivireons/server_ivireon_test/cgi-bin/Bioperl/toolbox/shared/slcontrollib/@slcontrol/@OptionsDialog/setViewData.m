function setViewData(this)
% SETVIEWDATA Update the view data from the model settings

% Author(s): Bora Eryilmaz
% Revised: A. Stothert
% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.6.9 $ $Date: 2009/07/09 20:55:02 $

% Update the panels
if ~isempty(this.SimOptionForm)
   LocalUpdateSimOptions(this)
end
if ~isempty(this.OptimOptionForm)
   LocalUpdateOptimOptions(this)
end
if this.showParallelOptions
   LocalUpdateParallelOptions(this)
end
end

% --------------------------------------------------------------------------
function LocalUpdateSimOptions(this)
h = this.SimOptionForm;
Handles = this.SimOptionHandles;

% Update text fields
Fields = { 'StartTime',   'StopTime',  'MaxStep', 'MinStep', ...
	   'InitialStep', 'FixedStep', 'RelTol',  'AbsTol' };
Handles.Panel.setFields( LocalGetInfo(Fields, h) );

% Finite settings
typeidx   = 1;
solveridx = 1;
if ~strcmp(h.Solver,'auto')
   typeidx = 2;
   solveridx = find( strcmp( h.Solver, this.VariableStepSolvers ) );
   if isempty(solveridx)
      solveridx = find( strcmp( h.Solver, this.FixedStepSolvers ) );
      typeidx   = 3;
   end
end
zeroidx = find( strcmp( h.ZeroCross, {'off', 'on'} ) );

% Update combo boxes
indices = [ typeidx-1, solveridx-1, zeroidx-1 ];
Handles.Panel.setIndices( indices );
end

% --------------------------------------------------------------------------
function LocalUpdateOptimOptions(this)
h = this.OptimOptionForm;
Handles = this.OptimOptionHandles;

% Update text fields
Fields = { 'DiffMaxChange', 'DiffMinChange', 'TolCon', 'TolFun', 'TolX', ...
	   'MaxFunEvals', 'MaxIter', 'Restarts', 'SearchLimit' };
Handles.Panel.setFields( LocalGetInfo(Fields, h) );

% Finite settings
alg = set(h, 'Algorithm');
switch h.Method
  case 'lsqnonlin'
    alg = alg(~ismember(alg, {'active-set','interior-point'}));
  case 'fmincon'
    alg = alg(~ismember(alg, {'levenberg-marquardt'}));  % Remove LM for fmincon.
end

mthdidx   = find( strcmp( h.Method,       set(h, 'Method') ) );
algidx    = find( strcmp( h.Algorithm,    alg ) );
dispidx   = find( strcmp( h.Display,      set(h, 'Display') ) );
gradidx   = find( strcmp( h.GradientType, set(h, 'GradientType') ) );
searchidx = find( strcmp( h.SearchMethod, set(h, 'SearchMethod') ) );

% Build indices as required
indices = [mthdidx algidx dispidx gradidx];

% Check for optional fields
fieldNames = fieldnames(h);

% Cost function type
if any( strcmp('CostType', fieldNames) )
  costidx = find( strcmp( h.CostType, set(h, 'CostType') ) );
  indices = [indices, costidx];
end

% Robust algorithm
if any( strcmp('RobustCost', fieldNames) )
  robustidx = find( strcmp( h.RobustCost, {'off', 'on'} ) );
  indices  = [indices, robustidx];
end

% Interior-point search
if any( strcmp('MaximallyFeasible', fieldNames) )
  indices  = [indices, h.MaximallyFeasible+1];
end

indices = [indices, searchidx];

% Update combo boxes
Handles.Panel.setIndices( indices-1 );  % Java offset
end

% -------------------------------------------------------------------------
function LocalUpdateParallelOptions(this)
h = this.Dialog.getParallelOptionPanel;

if strcmp(this.OptimOptionForm.UseParallel,'always')
   h.setIndices(1);
   awtinvoke(h.getPathDependencyEDT,'setEnabled(Z)',true);
   awtinvoke(h.getDependencyCheckerBTN,'setEnabled(Z)',true);
   awtinvoke(h.getBrowsePathBTN,'setEnabled(Z)',true);
else
   h.setIndices(0);
   awtinvoke(h.getPathDependencyEDT,'setEnabled(Z)',false);
   awtinvoke(h.getDependencyCheckerBTN,'setEnabled(Z)',false);
   awtinvoke(h.getBrowsePathBTN,'setEnabled(Z)',false);
end
if isempty(this.OptimOptionForm.ParallelPathDependencies)
   h.setFields(ctrlMsgUtils.message('SLControllib:slcontrol:warnNoPathDependencies'))
else
   cPaths = this.OptimOptionForm.ParallelPathDependencies;
   sPaths = '';
   nP = numel(cPaths);
   for ct=1:nP
      sPaths = sprintf('%s%s',sPaths,cPaths{ct});
      if nP > 1 && ct < nP
	 sPaths = sprintf('%s\n',sPaths);
      end
   end
   h.setFields(sPaths)
end
end

% --------------------------------------------------------------------------
function info = LocalGetInfo(Fields, h)
[common, ia] = intersect( Fields, fieldnames(h) );
ia = sort(ia);

% Default strings
info = cell( size(common) );
info(:) = {'not available'};

for ct = 1:length(ia)
  idx = ia(ct);
  f = Fields{idx};
  info{ct} = h.(f);
end
end
