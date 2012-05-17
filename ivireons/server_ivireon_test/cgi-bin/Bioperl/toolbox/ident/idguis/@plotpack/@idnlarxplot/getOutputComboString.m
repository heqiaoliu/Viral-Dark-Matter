function str = getOutputComboString(this)
%Construct the combo box list of strings for the output selection.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:55:52 $

this.OutputNames = this.getOutputNames;
str = this.OutputNames;
if ~this.isGUI
    str = ['<all outputs>';str];
end
