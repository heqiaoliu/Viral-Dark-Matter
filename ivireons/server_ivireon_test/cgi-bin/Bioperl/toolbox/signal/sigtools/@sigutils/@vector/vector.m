function h = vector(limit, varargin)
%VECTOR Construct a vector

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/04/11 18:46:21 $

h = sigutils.vector;

if nargin > 0,
    set(h, 'Limit', limit);
end

for i = 1:length(varargin)
    h.addelement(varargin{i});
end

% [EOF]
