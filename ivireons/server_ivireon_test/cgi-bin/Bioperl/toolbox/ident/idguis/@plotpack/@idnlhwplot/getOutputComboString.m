function str = getOutputComboString(this)
%Construct the combo box list of strings for the output selection.

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:56:28 $

str = this.IONames.y;
if ~this.isGUI
    str = ['<all outputs>';str];
end
