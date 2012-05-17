function s = exportinfo(this)
%EXPORTINFO Export information.

% This should be a private method.

%   Author(s): P. Costa
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $  $Date: 2004/04/13 00:32:05 $

data = elementat(this,1);
if isa(data,'sigutils.vector'),
    % Default Variable Labels and Names
    s = defaultvarsinfo(length(this));
elseif isa(data,'handle')
    % Call the object specific information
    s = exportinfo(data);
else
    s = defaultvarsinfo(length(this));
end


% -------------------------------------------------------------------------
function s = defaultvarsinfo(le)
% Default Variable Labels and Names

s.variablelabel = repmat({'Variable'}, le, 1);
s.variablename  = repmat({'var'}, le, 1); 

% [EOF]
