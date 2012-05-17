function optionsobj = getAlgorithmOptions(this,nlgui)
% return algorithm options object that is currently applicable (based on
% model type).

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:53:38 $

if nargin<2
    nlgui = nlutilspack.getNLBBGUIInstance;
end

isNlhw = nlgui.ModelTypePanel.Data.StructureIndex==2;

if isNlhw
    optionsobj = this.AlgorithmOptions(2);
else
    optionsobj = this.AlgorithmOptions(1);
end
