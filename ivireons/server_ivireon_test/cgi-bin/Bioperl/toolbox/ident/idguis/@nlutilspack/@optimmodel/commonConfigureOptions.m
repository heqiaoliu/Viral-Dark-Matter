function option = commonConfigureOptions(this, algo, option, Estimator)
%COMMONCONFIGUREOPTIONS Configure common options to be used
%with given optimizer. 
%   OPTION: struct used by estimator containing algorithm properties.
%   ALGO: Algorithm property of this.Model

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $ $Date: 2009/03/09 19:14:25 $

option.Display = algo.Display;
if strcmpi(algo.Display, 'full')
    option.Display = 'On';
end

option.LimitError = algo.LimitError;
option.MaxSize = algo.MaxSize;
option.Criterion = 'Trace';
option.Weighting = algo.Weighting;
