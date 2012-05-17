function option = configureOptimizationOptions(nlsys, algo, option, varargin)
%CONFIGUREOPTIMIZATIONOPTIONS Configure model specific options to be used
%with given optimizer.

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2008/05/19 23:07:58 $

option.Display = algo.Display;
if strcmpi(algo.Display, 'full')
    option.Display = 'On';
end

option.LimitError = algo.LimitError;
option.MaxSize = algo.MaxSize;

option.NoiseVariance = pvget(nlsys,'NoiseVariance');

