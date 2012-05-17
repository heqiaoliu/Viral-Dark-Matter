function layout(this)
%LAYOUT   Layout the container.

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/01/05 18:01:34 $

% Don't waste any time if the panel isn't visible or if there is nothing
% added to it yet.
grid = get(this, 'Grid');
if isempty(grid)
    return;
end

panelpos    = getpanelpos(this);
ctag        = getconstraintstag(this);
[rows cols] = size(grid);

hg = get(this, 'HorizontalGap');
vg = get(this, 'VerticalGap');

wd = (panelpos(3) - hg*(cols+1))/cols;
ht = (panelpos(4) - vg*(rows+1))/rows;

for indx = 1:rows
    for jndx = 1:cols
        if ishghandle(grid(indx,jndx))

            [n m] = getcomponentsize(this, indx, jndx);

            pos = [ ...
                (wd+hg)*(jndx-1)+hg+1 ...
                panelpos(4)-(ht+vg)*(indx+n-1)+1 ...
                wd+(hg+wd)*(m-1) ...
                ht+(vg+ht)*(n-1)];

            if isappdata(grid(indx, jndx), ctag)
                hC = getappdata(grid(indx, jndx), ctag);

                pos = pos + [...
                    hC.LeftInset ...
                    hC.BottomInset ...
                    -hC.LeftInset-hC.RightInset ...
                    -hC.BottomInset-hC.TopInset];
            end

            % Set the components position.
            set(grid(indx,jndx), 'Units', 'Pixels', 'Position', pos);

            % Remove the control from the grid.
            grid(indx:indx+n-1,jndx:jndx+m-1) = NaN;
        end
    end
end

% [EOF]
