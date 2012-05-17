function this = OptionsDialog(SimOptionForm, OptimOptionForm, parent, model, deleteObject, showSim, showOpt, showParallel)
% OPTIONSDIALOG

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.6.8 $ $Date: 2009/08/29 08:32:00 $

% Create class instance
this = slcontrol.OptionsDialog;

% Store model and option objects
this.Model           = model;
this.SimOptionForm   = SimOptionForm;
this.OptimOptionForm = OptimOptionForm;
if nargin < 5, deleteObject = []; end
if nargin >= 6, this.showSimOptions = showSim; end
if nargin >= 7, this.showOptimOptions = showOpt; end
if nargin >= 8, this.showParallelOptions = showParallel; end

% Create the options dialog
switch class(OptimOptionForm)
   case 'srogui.OptimOptionForm'
      type = 'SRO';
   case 'speforms.OptimOptionForm'
      type = 'SPE';
end

%Is parallel installed?
showParallelOptions = this.showParallelOptions && ...
   (license('test','distrib_computing_toolbox') && ~isempty(ver('distcomp')));

% If the parent is a Figure,
if isjava(parent)
  this.Dialog = ...
      awtcreate( 'com.mathworks.toolbox.control.settings.OptionsDialog', ...
                 'Ljava/awt/Frame;Ljava/lang/String;ZZZ', ...
                 parent, type, this.showSimOptions, this.showOptimOptions, showParallelOptions );
else
  this.Dialog = ...
      awtcreate( 'com.mathworks.toolbox.control.settings.OptionsDialog', ...
                 'Ljava/awt/Frame;Ljava/lang/String;ZZZ', ...
                 [], type, this.showSimOptions, this.showOptimOptions, showParallelOptions );
  centerfig(this.Dialog, parent)
end

% Configure callbacks & listeners
configurePanels(this);
configureButtons(this);

% Update the GUI content with the new data
setViewData(this);

% Listeners
L(1) = handle.listener( this, 'ObjectBeingDestroyed', ...
                        { @LocalDestroy, this } );
if ~isempty(deleteObject)
  L(2) = handle.listener( deleteObject, 'ObjectBeingDestroyed', ...
                          { @LocalDelete, this } );
end
this.Listeners = [ this.Listeners; L(:) ];

% --------------------------------------------------------------------------
function LocalDestroy(~, ~, this)
% Delete dialog
awtinvoke( this.Dialog, 'dispose()' )

% --------------------------------------------------------------------------
function LocalDelete(~, ~, this)
% Delete dialog
delete(this);
