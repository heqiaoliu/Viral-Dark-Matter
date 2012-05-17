function updateSummary(obj) 
% UPDATESUMMARY  
%
 
% Author(s): John W. Glass 17-Mar-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2009/03/31 00:22:45 $

if obj.SelectedIndex == 0
    data = {'<font face="monospaced"; size=3>',...
            ctrlMsgUtils.message('Slcontrol:linearizationtask:BlockNotSelected')};
else
    [FullName,Name] = getSelectedBlockName(obj);
    BlockData = getSelectedBlockData(obj);
    data = getInspectorSummary(BlockData,Name);        
end
obj.getPeer.setBlockSummaryCallback(data);
