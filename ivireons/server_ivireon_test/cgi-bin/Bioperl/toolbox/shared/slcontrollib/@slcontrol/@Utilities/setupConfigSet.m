function old = setupConfigSet(this, model, new)
% SETUPCONFIGSET Sets the Simulink model configuration options to the one
% specified in the NEW structure and return the current configuration in OLD
% structure.
%
% Assumes that the model is already open or loaded.

% Author(s): Bora Eryilmaz
% Revised: 
% Copyright 2000-2004 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2004/11/18 23:44:39 $

% Save original settings
Dirty  = get_param(model, 'Dirty');
Fields = fieldnames(new);
old = new;
for ct = 1:length(Fields)
  f = Fields{ct};
  old.(f) = get_param( model, f );
  set_param( model, f, new.(f) )
end
old.Dirty = Dirty;
