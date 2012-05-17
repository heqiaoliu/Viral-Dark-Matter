function S = ziscalarexpand(Hd,S)
%ZISCALAREXPAND Expand empty or scalar initial conditions to a vector.

% This should be a private method

%   Author: R. Losada
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.3.4.8 $  $Date: 2009/03/30 23:59:43 $

error(nargchk(2,2,nargin,'struct'));

nsecs = nsections(Hd);

% If the user passes in a cell array, it might be the old R13 style states.
if iscell(S)
    
    % Warn that this functionality might be removed.
    warning(generatemsgid('deprecatedFeature'), ...
        sprintf('%s\n%s', ...
        'The use of cell arrays as states is deprecated and may be removed', ...
        'in a future release.  Use a matrix instead.'));
    zicell = S;

    % Build the states from the cell array.
    S      = [];
    for indx = 1:nsecs
        S = [S zicell{indx}{2}];
    end
end
if ~isnumeric(S)
    error(generatemsgid('MustBeNumeric'),'States must be numeric.');
end
if issparse(S),
    error(generatemsgid('Sparse'),'States cannot be a sparse matrix.');
end

if nsecs ~=0
    if isempty(S),
        S = nullstate1(Hd.filterquantizer);
    end
    statespersec=2;
    if length(S)==1,
        % Zi expanded to a matrix with 2 of rows and as many columns as
        % sections
        S = S(ones(statespersec,nsecs));
    end
    % At this point we must have a matrix with the right number of rows
    if size(S,1) ~= statespersec,
        error(generatemsgid('InvalidDimensions'),...
            'The states must be a matrix with %d rows per channel.',statespersec);
    end
end
