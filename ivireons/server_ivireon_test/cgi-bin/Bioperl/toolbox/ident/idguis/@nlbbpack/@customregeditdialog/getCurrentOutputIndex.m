function num = getCurrentOutputIndex(this)
% get index of currently selected output

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/12/27 20:53:33 $
% 
% if this.NlarxPanel.isSingleOutput
%     num = 1;
% else
%     num = max(1,this.jModelOutputCombo.getSelectedIndex+1);
% end
num = this.NlarxPanel.getCurrentOutputIndex;
