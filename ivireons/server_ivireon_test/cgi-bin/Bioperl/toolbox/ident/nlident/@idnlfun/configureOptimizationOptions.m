function option = configureOptimizationOptions(nlobj, algo, option, varargin)
%CONFIGUREOPTIMIZATIONOPTIONS Configure model specific options to be used
%with given optimizer.

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $ $Date: 2008/05/19 23:06:58 $


option.Display = algo.Display;
if strcmpi(algo.Display, 'full')
    option.Display = 'On';
end

option.LimitError = algo.LimitError;
option.MaxSize = algo.MaxSize;

try
    option.NoiseVariance = algo.NoiseVariance;
catch
    %error('Should not get here:\n%s',lasterr)
end
