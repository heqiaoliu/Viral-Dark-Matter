function num = getCurrentOutputIndex(this)
% get index of currently selected output

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/11/17 13:31:17 $

if this.isSingleOutput
    num = 1;
else
    num = max(1,this.jModelOutputCombo.getSelectedIndex+1);
end
