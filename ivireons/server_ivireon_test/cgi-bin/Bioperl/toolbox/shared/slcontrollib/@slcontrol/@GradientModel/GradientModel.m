function this = GradientModel(model, hVars)
% GRADIENTMODEL Constructor

% Author(s): Bora Eryilmaz
% Copyright 1986-2010 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2010/04/21 21:47:38 $

% Create object
this = slcontrol.GradientModel;

% Set properties
this.GradModel  = strrep(tempname, tempdir, '');
this.WSVariable = strrep(tempname, tempdir, '');
this.OrigModel  = model;

% Create and initialize gradient model
initialize(this, hVars)

% Listeners
L = handle.listener( this, 'ObjectBeingDestroyed', @(hSrc,hData) LocalDelete(hSrc) );
set( L, 'CallbackTarget', this );
this.Listeners = L;

% ----------------------------------------------------------------------------%
function LocalDelete(this)
% Close the model
if exist( this.GradModel, 'file') == 4
  close_system( this.GradModel, 0 );
end
if ishandle(this.hModel)
   delete(this.hModel)
end
