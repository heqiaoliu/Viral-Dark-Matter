function setName(this, name)
% SETNAME Sets the name of the port identified by THIS.
%
% NAME is a string (cell array of strings if THIS is an object array).

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2005 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2005/12/22 18:53:25 $

n = length( this(:) );

if n == 1
  set(this, 'Name', name)
else
  set(this, {'Name'}, name(:))
end
