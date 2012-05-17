function [uname,yname] = decipherIOPair(this,v)
% convert combobox item location to an I/O pair indices.

% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2008/08/01 12:22:55 $

iopairs = get(this.UIs.LinearCombo,'userdata');
if ~this.isGUI
    v = max(2,v);
end
thispair = iopairs(v,:);
uname = thispair{1};
yname = thispair{2};
