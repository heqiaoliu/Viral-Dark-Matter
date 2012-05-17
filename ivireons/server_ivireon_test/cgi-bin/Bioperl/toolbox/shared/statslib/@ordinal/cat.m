function a = cat(dim,varargin)
%HORZCAT Concatenate ordinal arrays.
%   C = CAT(DIM, A, B, ...) concatenates the ordinal arrays A, B, ... along
%   dimension DIM.  All inputs must have the same size except along dimension
%   DIM.  All inputs must have the same sets of ordinal levels, including
%   their order.
%
%   See also ORDINAL/HORZCAT, ORDINAL/VERTCAT.

%   Copyright 2006-2009 The MathWorks, Inc. 
%   $Revision: 1.1.6.3 $  $Date: 2009/06/16 05:25:41 $

a = varargin{1};

for i = 2:nargin-1
    b = varargin{i};

    % Accept [] as a valid "identity element" for either arg.
    if isequal(a,[])
        a = b;
        continue;
    elseif isequal(b,[])
        continue;
    elseif ~isa(b,class(a))
        error('stats:ordinal:cat:TypeMismatch', ...
              'All input arguments must be from the same categorical class.');
    end
    if isequal(a.labels,b.labels)
        bcodes = b.codes;
    else
        error('stats:ordinal:cat:OrdinalLevelsMismatch', ...
              'Ordinal levels and their ordering must be identical.');
    end

    try
        a.codes = cat(dim, a.codes, bcodes);
    catch ME
        throw(ME);
    end
end
