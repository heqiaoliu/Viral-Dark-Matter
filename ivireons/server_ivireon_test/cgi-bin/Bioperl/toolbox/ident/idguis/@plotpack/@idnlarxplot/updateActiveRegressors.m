function updateActiveRegressors(this)
% update list of active regressors in all regdata objects in
% this.RegressorData

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.10.3 $ $Date: 2008/10/02 18:51:00 $

activemodels = find(this.ModelData,'isActive',true);
activemodelnames = get(activemodels,{'ModelName'}); %names of all active models (need not all belong to robj).


for i = 1:length(this.RegressorData)
    robj = this.RegressorData(i);
 
    regnames = cell(0,1);   
    % assemble regressor names by reading RegInfo
    for k = 1:length(robj.RegInfo)
        if any(ismember(robj.RegInfo(k).ModelNames,activemodelnames)) %at least one model for this reg is active
            regnames{end+1,1} = robj.RegInfo(k).Name;
        end
    end
    robj.ActiveRegressors = regnames;
    if length(regnames)<2
        robj.is2D = true;
    end
end
