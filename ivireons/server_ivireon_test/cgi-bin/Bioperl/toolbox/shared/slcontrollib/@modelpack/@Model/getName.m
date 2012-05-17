function name = getName(this)
% GETNAME Returns the name of the model.
%
% +getName() : string
% +getName() : cell array of strings    % Vectorized form

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2008 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/05/31 23:25:31 $

n = numel(this);

if n == 1
  name = '';
  warning('modelpack:AbstractMethod', 'Method needs to be implemented by subclasses.');
else
  name = cell(n,1);
  for ct=1:n
     name{ct} = this(ct).getName;
  end
end


