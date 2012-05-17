function dvalue = double(this)
%DOUBLE   Return the double value for the state.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/07/28 04:37:35 $

[rows, cols] = size(this);

dvalue = cell(cols, 1);

for indx = 1:rows
    for jndx = 1:cols
        value = get(this(indx, jndx), 'Value');

        if ~isa(value, 'double')
            value = double(value);
        end

        dvalue{jndx} = [dvalue{jndx}; value];
    end
end

dvalue = [dvalue{:}];

% [EOF]
