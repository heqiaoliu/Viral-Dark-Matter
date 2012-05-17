function [qindx, dindx] = getindexoffilts(hFVT)
% Return an index with the number of dfilt objects.

%   Author(s): P. Costa
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $  $Date: 2009/07/27 20:32:14 $

G = get(hFVT, 'Filters');

if isempty(G),
    qindx = [];
    dindx = [];
else
    [qindx, dindx] = getfiltindx(G);
end

% [EOF]