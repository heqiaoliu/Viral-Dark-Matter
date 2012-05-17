function option = commonOptimConfig(sys, algo, option)
% common configuration for linear models

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $ $Date: 2008/10/02 18:48:00 $

option.NoiseVariance = pvget(sys,'NoiseVariance');

if isfield(algo,'Display')
    option.Display = algo.Display;
else
    option.Display = algo.Trace;
end
option.Focus = algo.Focus;
option.MaxSize = algo.MaxSize;
if isfield(algo,'SearchMethod')
    option.SearchMethod = algo.SearchMethod;
else
    option.SearchMethod = algo.SearchDirection;
end

option.LimitError = algo.LimitError;

option.Advanced = algo.Advanced.Search;

if ~isfield(option.Advanced,'GnPinvConst')
    option.Advanced.GnPinvConst = 1e4;
end

f = fieldnames(algo.Advanced.Threshold);
for k = 1:length(f)
    option.Advanced.(f{k}) = algo.Advanced.Threshold.(f{k});
end

option.Advanced.MaxFunEvals = Inf; %todo: add this to algo.Advanced of idmodel; also add JacPertSize
option.Advanced.MinParChange = 0;
option.Advanced.LMStartValue = algo.Advanced.Search.LmStartValue;
option.Advanced.LMStep = algo.Advanced.Search.LmStep;
%option.Advanced.GnPinvConst = algo.Advanced.GnPinvConst;

if (size(sys,'nu') == 0) && ~strcmpi(algo.Focus,'Prediction')
    ctrlMsgUtils.warning('Ident:estimation:timeSeriesFocus')
    option.Focus = 'Prediction';
end
