function loadPlantData(this)
% LOADPLANTDATA  Load the plant data from the operating point into the
% design.
%
 
% Author(s): John W. Glass 21-Aug-2006
% Copyright 2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/11/17 14:04:21 $

sisotask = this.getRoot;
olddesign = sisotask.sisodb.loopData.exportdesign;
% Get the compensators from the design
for ct = 1:numel(olddesign.Tuned)
    this.design.(olddesign.Tuned{ct}) = olddesign.(olddesign.Tuned{ct});
end
sisotask.sisodb.loopData.importdesign(this.design);