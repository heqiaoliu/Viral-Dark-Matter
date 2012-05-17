function p = describe(this)
%DESCRIBE   Describe the object.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 07:02:28 $

p      = propstoadd(this);
p(1:2) = [];

for indx = 1:length(p),
    
    % Special case FilterOrder and TransitionWidth.
    switch lower(p{indx})
        case 'bw'
            d = 'Bandwidth at -3 dB';
        case 'filterorder'
            d = 'Filter Order';
    end
    p{indx} = d;
end

% Make sure that we get a column.
p = p(:);

% [EOF]
