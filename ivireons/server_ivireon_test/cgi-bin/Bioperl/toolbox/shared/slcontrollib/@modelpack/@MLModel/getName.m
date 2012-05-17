function name = getName(this)
% GETNAME Returns the name of the model

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2005/11/15 01:37:16 $

n = length( this(:) );

if n == 1
  name = LocalGetName(this);
else
  name = cell(n,1);
  for ct = 1:n
    name{ct} = LocalGetName(this(ct));
  end
end

% ----------------------------------------------------------------------------
function name = LocalGetName(h)
if ~isempty(h.ModelFcn)
  name = func2str(h.ModelFcn);
else
  name = '';
end
