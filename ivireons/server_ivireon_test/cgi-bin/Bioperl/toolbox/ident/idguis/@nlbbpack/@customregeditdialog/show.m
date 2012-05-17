function show(this)
% show the regressor editor dialog

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/05/19 23:03:55 $

% there is no output combo anymore
% if ~this.NlarxPanel.isSingleOutput
%     Ind = this.RegDialog.getCurrentOutputIndex;
%     awtinvoke(this.jModelOutputCombo,'setSelectedIndex(I)',Ind-1);
% end

% show the dialog
javaMethodEDT('setVisible',this.jMainPanel,true);
