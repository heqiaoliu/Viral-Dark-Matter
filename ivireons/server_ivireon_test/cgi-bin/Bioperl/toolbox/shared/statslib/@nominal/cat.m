function a = cat(dim,varargin)
%CAT Concatenate nominal arrays.
%   C = CAT(DIM, A, B, ...) concatenates the nominal arrays A, B, ...
%   along dimension DIM.  All inputs must have the same size except along
%   dimension DIM.  The set of nominal levels for C is the sorted union of
%   the sets of levels of the inputs, as determined by their labels.
%
%   See also NOMINAL/HORZCAT, NOMINAL/VERTCAT.

%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/06/16 05:25:24 $

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
        error('stats:nominal:cat:TypeMismatch', ...
              'All input arguments must be from the same categorical class.');
    end
    if isequal(a.labels,b.labels)
        bcodes = b.codes;
    else
        % Get a's codes for b's data, possibly adding to a's levels
        [bcodes,a.labels] = matchlevels(a,b);
    end

    try
        a.codes = cat(dim, a.codes, bcodes);
    catch ME
        throw(ME);
    end
end
