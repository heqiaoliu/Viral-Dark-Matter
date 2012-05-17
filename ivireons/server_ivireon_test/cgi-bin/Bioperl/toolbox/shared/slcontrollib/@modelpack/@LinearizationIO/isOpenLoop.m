function flag = isOpenLoop(this)
% ISOPENLOOP Returns the open-loop status of the signal marked as a
% linearization I/O.
%
% FLAG is a logical value (cell array of logical values if THIS is
% an object array).

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2005 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2005/12/22 18:53:02 $

n = length( this(:) );

if n == 1
  flag = false;
else
  flag = cell(n,1);
  flag(:) = {false};
end

warning('modelpack:AbstractMethod', ...
        'Method needs to be implemented by subclasses.');
