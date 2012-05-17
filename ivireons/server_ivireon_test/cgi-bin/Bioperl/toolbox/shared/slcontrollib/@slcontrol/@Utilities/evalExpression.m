function [v, Fail] = evalExpression(this, name, ModelWS, ModelWSVars)
% Evaluates model variable in appropriate workspace.

% Author(s): Bora Eryilmaz
% Revised: 
% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2008/05/31 23:25:40 $

Fail = false;
if (nargin == 4) && any( strcmp( ModelWSVars, strtok(name,'.({') ) )
   % Evaluate in model workspace, be careful of setting model dirty state
   sDirty = get_param(ModelWS.ownerName,'Dirty');
   try
      % Model workspace variable. Evaluate in model workspace.
      v = ModelWS.evalin(name);
   catch E
      v = [];
      Fail = true;
   end
   set_param(ModelWS.ownerName,'Dirty',sDirty);
else
   try
      % Base workspace variable or expression. Evaluate in base workspace.
    v = evalin('base', name);
  catch E
    v = [];
    Fail = true;
  end
end
