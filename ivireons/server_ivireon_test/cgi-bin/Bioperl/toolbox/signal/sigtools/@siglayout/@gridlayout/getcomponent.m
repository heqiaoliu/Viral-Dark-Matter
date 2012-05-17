function component = getcomponent(this, row, col)
%GETCOMPONENT   Get the component.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/06/06 17:06:49 $

g = get(this, 'Grid');

component = [];

if max(row) <= size(g, 1) && max(col) <= size(g, 2)
    for indx = 1:length(row)
        for jndx = 1:length(col)
            if ~isnan(g(row(indx), col(jndx)))
                component = [component; g(row(indx), col(jndx))];
            end
        end
    end
end

% [EOF]
