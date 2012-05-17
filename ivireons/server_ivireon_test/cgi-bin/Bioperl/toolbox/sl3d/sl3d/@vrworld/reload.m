function reload(w, preserveBindings)
%RELOAD Reload the world contents from associated file.
%   RELOAD(W) reloads the contents of the world referenced by
%   VRWORLD handle W from its associated file.
%
%   All unsaved changes made to the world are lost. If the contents
%   of the associated file was changed, these changes will propagate
%   to the world.
%
%   If W is an array of handles all the virtual worlds are reloaded.
%
%   See also VRWORLD/OPEN, VRWORLD/CLOSE.

%   Copyright 1998-2010 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.1.8.1 $ $Date: 2010/06/10 14:34:45 $ $Author: batserve $

% preserve bindable nodes by default
if nargin<2
  preserveBindings = true;
end

% check for invalid worlds
if ~all(isvalid(w(:)))
  error('VR:invalidworld', 'Invalid world.');
end

% do it
for i=1:numel(w);
  vrsfunc('Reload', w(i).id, preserveBindings);
end
