function list = parselist(listin)
%Parse comma separated list into a cell array

%   Copyright 1984-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2006/10/04 22:54:34 $

if (isempty(listin))
    list = {};
else
    % Return a row vector.
    list = strread(listin, '%s', 'delimiter', ',')';
end
