function ci=paramci(obj,alpha)
%PARAMCI Parameter confidence intervals.
%   CI = PARAMCI(PD) returns a 2-by-N array CI containing 95% confidence
%   intervals for the parameters of the probability distribution PD.
%   N is the number of parameters in the distribution.  When PD is
%   created by specifying the parameter rather than by fitting to data, the
%   confidence intervals have 0 width because the parameters are treated as
%   known exactly.
%
%   CI = PARAMCI(PD,ALPHA) returns 100*(1-ALPHA)% confidence intervals.
%   The default is 0.05 for 95% confidence intervals.
%
%   Not all distributions support confidence intervals.  CI contains NaN
%   values when confidence intervals are not supported.
%
%   See also ProbDist, FITDIST, ProbDistUnivParam, ProbDistUnivParam/FIT.

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/16 00:19:24 $

% Check for valid input
if nargin<2
    alpha = 0.05;
elseif ~(isscalar(alpha) && isnumeric(alpha) && 0<alpha && alpha<1)
    error('stats:ProbDistUnivParam:parmamci:BadAlpha',...
          'ALPHA must be a scalar between 0 and 1.');
end

F = obj.cifunc;
if isempty(obj.InputData.data)
    ci = [obj.Params; obj.Params];
elseif ~isempty(F)
    % Distribution can compute its own confidence intervals
    ci = F(obj.Params,obj.ParamCov,alpha,...
           obj.InputData.data,obj.InputData.cens,obj.InputData.freq);
elseif ~isempty(obj.ParamCov)
    % Compute confidence intervals based on standard errors
    ci = dfswitchyard('statparamci',obj.Params,obj.ParamCov,alpha);
else
    % Can't compute confidence intervals
    ci = nan(2,obj.NumParams);
end

