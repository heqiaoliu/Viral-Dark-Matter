function str = getInputComboString(this)
%Construct the combo box list of strings for the input selection.

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:56:26 $

str = this.IONames.u;
if ~this.isGUI
    str = ['<all inputs>';str];
end
