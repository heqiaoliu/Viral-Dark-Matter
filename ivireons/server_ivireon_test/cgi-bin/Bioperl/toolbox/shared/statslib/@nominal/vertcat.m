function a = vertcat(varargin)
%VERTCAT Vertical concatenation for nominal arrays.
%   C = VERTCAT(A, B, ...) vertically concatenates the nominal arrays A,
%   B, ... .  For matrices, all inputs must have the same number of columns.
%   For N-D arrays, all inputs must have the same sizes except in the first
%   dimension.  The set of nominal levels for C is the sorted union of the
%   sets of levels of the inputs, as determined by their labels.
%
%   C = VERTCAT(A,B) is called for the syntax [A; B].
%
%   See also NOMINAL/CAT, NOMINAL/HORZCAT.

%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/06/16 05:25:36 $

a = varargin{1};

for i = 2:nargin
    b = varargin{i};

    % Accept [] as a valid "identity element" for either arg.
    if isequal(a,[])
        a = b;
        continue;
    elseif isequal(b,[])
        continue;
    elseif ~isa(b,class(a))
        error('stats:nominal:vertcat:TypeMismatch', ...
              'All input arguments must be from the same categorical class.');
    end
    if isequal(a.labels,b.labels)
        bcodes = b.codes;
    else
        % Get a's codes for b's data, possibly adding to a's levels
        [bcodes,a.labels] = matchlevels(a,b);
    end

    try
        a.codes = vertcat(a.codes, bcodes);
    catch ME
        throw(ME);
    end
end
