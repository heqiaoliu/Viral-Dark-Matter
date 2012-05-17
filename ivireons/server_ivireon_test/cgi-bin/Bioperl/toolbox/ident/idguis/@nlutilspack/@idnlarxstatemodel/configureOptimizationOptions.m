function option = configureOptimizationOptions(this, algo, option, Estimator)
%CONFIGUREOPTIMIZATIONOPTIONS Configure model specific options to be used
%with given optimizer.
%   OPTION: struct used by estimator containing algorithm properties.
%   ALGO: Algorithm property of this.Model

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2009/03/09 19:14:20 $

option = this.commonConfigureOptions(algo, option, Estimator);

Data = Estimator.Data;
if isa(Data,'iddata')
    y = pvget(Data,'OutputData');
    option.yMin = cellfun(@(x)min(x(:)),y);
    option.yMax = cellfun(@(x)max(x(:)),y);
end
