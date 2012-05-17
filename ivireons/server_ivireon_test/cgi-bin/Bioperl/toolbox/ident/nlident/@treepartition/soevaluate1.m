function yhat = soevaluate1(nlobj, x)
%SOEVALUATE: Single output evaluate method, return the value of TREEPARTITION at given input.
%
%  yhat = soevaluate(nlobj, regmat)

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2008/10/02 18:55:45 $

% Author(s): Anatoli Iouditski

%no=nargout;
ni=nargin;
error(nargchk(2,2,ni,'struct'))

if ~isa(nlobj,'treepartition')
    ctrlMsgUtils.error('Ident:general:objectTypeMismatch2','soevaluate1','TREEPARTITION')
end

if ~isinitialized(nlobj)
    ctrlMsgUtils.error('Ident:idnlfun:unInitializedNL','TREEPARTITION')
end

if iscell(x) && numel(x)==1
    % Tolerate cellarray data
    x = x{1};
end

if isempty(x)
    yhat = zeros(size(x));
    return
end

[ninp, regdim] = size(x);
thrh=nlobj.Options.Threshold;
if ischar(thrh) && strcmpi(thrh,'auto')
    thrh=1.0;
end
param = nlobj.Parameters;
ht=param.Tree;
nobs=param.SampleLength;
nv=param.NoiseVariance;
coeflin=param.LinearCoef;
regmean = param.RegressorMean;

x = x - regmean(ones(ninp,1), :);  %  regmat mean removal
if isempty(ht.TreeLevelPntr)
    %    yhat=[ones(ninp,1),x]*coeflin+param.OutputOffset;
    yhat=x*coeflin+param.OutputOffset;
else
    yhat = adevcmp(x,ht,nobs,thrh,nv)+param.OutputOffset;
end
% FILE END

