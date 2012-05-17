function configureButtons(this)
% CONFIGUREBUTTONS

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2010 The MathWorks, Inc.
% $Revision: 1.1.6.12.6.1 $ $Date: 2010/07/23 15:43:05 $

% Get the dialog handle
Dialog = this.Dialog;
L = [];
% Configure buttons

h = handle( Dialog.getHelpButton, 'callbackproperties' );
L = [L; ...
   handle.listener(h,'actionperformed', {@LocalHelpButton this})];

h = handle( Dialog.getOkButton, 'callbackproperties' );
L = [L; ...
   handle.listener(h,'actionperformed', {@LocalOKButton this})];

h = handle( Dialog.getApplyButton, 'callbackproperties' );
L = [L; ...
   handle.listener(h,'actionperformed', {@LocalApplyButton this})];

h = handle( Dialog.getCancelButton, 'callbackproperties' );
L = [L; ...
   handle.listener(h,'actionperformed', {@LocalCancelButton this})];

if this.showParallelOptions
   %Callbacks for parallel options
   h = handle( Dialog.getParallelOptionPanel.getDependencyCheckerBTN, 'callbackproperties');
   L = [L; ...
      handle.listener(h,'actionperformed', {@LocalGetDependencies, this})];
   
   h = handle( Dialog.getParallelOptionPanel.getUseParallelCHK, 'callbackproperties');
   L = [L; ...
      handle.listener(h,'actionperformed', {@LocalUseParallel this})];
   
   h = handle( Dialog.getParallelOptionPanel.getBrowsePathBTN, 'callbackproperties');
   L = [L; ...
      handle.listener(h,'actionperformed', {@LocalBrowsePath this})];
end

%Store the listeners
this.Listeners = [this.Listeners; L];
end

% ----------------------------------------------------------------------------- %
function LocalHelpButton(~, ~, this)
% Launch the help browser
if isa(this.OptimOptionForm, 'srogui.OptimOptionForm')
   prefix = 'optim_';
elseif isa(this.OptimOptionForm, 'speforms.OptimOptionForm')
   prefix = 'estim_';
end;
mapfile = [docroot '/toolbox/sldo/sldo.map'];

if this.Dialog.getOptimOptionPanel.isVisible
   helpview(mapfile, [prefix 'options_opt'])
elseif this.Dialog.getSimOptionPanel.isVisible
   helpview(mapfile, [prefix 'options_sim'])
elseif this.Dialog.getParallelOptionPanel.isVisible
   helpview(mapfile, [prefix 'options_parallel'])
else
   %Default to simulation options
   helpview(mapfile, [prefix 'options_sim'])
end

end

% ----------------------------------------------------------------------------- %
function LocalOKButton(~, ~, this)
% Call the apply callback
isOK = LocalApplyButton([], [], this);

% Call the cancel callback if data update is successful
if isOK
  LocalCancelButton([], [], this);
end
end

% ----------------------------------------------------------------------------- %
function LocalCancelButton(~, ~, this)
% Close the dialog
awtinvoke(this.Dialog, 'setVisible', false);
end

% ----------------------------------------------------------------------------- %
function isOK = LocalApplyButton(~, ~, this)
% Update data
isOK = setModelData(this);
end

% -------------------------------------------------------------------------
function LocalGetDependencies(~, ~, this)
%Evaluate run dependency checker callback and update dependency field
if ~isempty(this.RunDependencyCheckerCallback)
   hBar = parallelsim.ProgressBar.getInstance;
   hBar.setTitle('');
   hBar.setStatus(ctrlMsgUtils.message('SLControllib:slcontrol:msgParallelFindDependencies'))
   hBar.isModal = true;
   hFrame = hBar.getFrame;
   hFrame.setLocationRelativeTo(this.Dialog)
   hBar.show;
   fcn = this.RunDependencyCheckerCallback;
   try
       if numel(fcn) > 1
           cPaths = fcn{1}(this,fcn{2:end});
       else
           cPaths = fcn{1}(this);
       end
       hBar.hide;
       localSetPathList(this,cPaths);
   catch E
       hBar.hide
       h = errordlg(ctrlMsgUtils.message('SLControllib:slcontrol:errParallelFindDependencies',E.message));
       ctrlMsgUtils.SuspendWarnings('MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
       jf = get(h, 'JavaFrame');
       if ~isempty(jf)
           jframe = javax.swing.SwingUtilities.getWindowAncestor(jf.getAxisComponent);
           jframe.setLocationRelativeTo(this.Dialog);
       end
   end
end
end

% --------------------------------------------------------------------------
function LocalBrowsePath(~,~,this)
% Open path browser to add to path dependencies

newDepend = uigetdir(pwd,ctrlMsgUtils.message('SLControllib:slcontrol:msgAddPathDependency'));
if newDepend
   cPaths = this.getPathsFromUI;
   cPaths = vertcat(cPaths,newDepend);
   localSetPathList(this,cPaths);
end

end

% --------------------------------------------------------------------------
function LocalUseParallel(hSrc,hData,this)
% UseParallel state changed, if enabled check for model dependencies

if hSrc.isSelected
   LocalGetDependencies(hSrc,hData,this)
end

%Disable this listener as we only want to call it once per instance of the
%dialog
idx = cellfun(@(x) isequal(x,hSrc), get(this.Listeners,{'SourceObject'}));
if any(idx)
   set(this.Listeners(idx),'Enabled','off')
end
end

% --------------------------------------------------------------------------
function localSetPathList(this,cPaths)
%Helper function to set the path dependency list
if ~isempty(cPaths)
   sPaths = '';
   nP = numel(cPaths);
   for ct=1:nP
      sPaths = sprintf('%s%s',sPaths,cPaths{ct});
      if nP > 1 && ct < nP
         sPaths = sprintf('%s\n',sPaths);
      end
   end
   hPnl = this.Dialog.getParallelOptionPanel;
   hPnl.setFields(sPaths)
end
end
