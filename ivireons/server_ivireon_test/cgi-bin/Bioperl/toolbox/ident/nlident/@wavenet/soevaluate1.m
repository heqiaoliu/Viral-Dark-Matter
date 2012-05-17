function z = soevaluate1(nlobj, x)
%SOEVALUATE: Single output evaluate method, return the value of a WAVENET at given input.
%
%  z = soevaluate(nlobj, x)

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2008/10/02 18:55:55 $

% Author(s): Qinghua Zhang

%no=nargout;
ni=nargin;
error(nargchk(2,4,ni,'struct'))

if ~isa(nlobj,'wavenet')
    ctrlMsgUtils.error('Ident:general:objectTypeMismatch2','soevaluate1','WAVENET')
end

if ~isinitialized(nlobj)
    ctrlMsgUtils.error('Ident:idnlfun:unInitializedNL','WAVENET')
end

if isempty(x)
    z = zeros(size(x));
    return
end
if iscell(x)
    % Tolerate cellarray data
    x = x{1};
end

[nbdata, regdim] = size(x);

hth = nlobj.Parameters;

regmean = hth.RegressorMean;
pct = hth.NonLinearSubspace;
lct = hth.LinearSubspace;

outoffset = hth.OutputOffset;

x = x - regmean(ones(nbdata,1), :);  %  x mean removal
xnl = x * pct;
xlin = x * lct;

coeflin = hth.LinearCoef;

z = xlin*coeflin + outoffset;

if ~isempty(hth.ScalingCoef)
    z = z + basisfun(1, xnl, hth.ScalingDilation, hth.ScalingTranslation)*hth.ScalingCoef;
end

if ~isempty(hth.WaveletCoef)
    z = z + basisfun(2, xnl, hth.WaveletDilation, hth.WaveletTranslation)*hth.WaveletCoef;
end

% FILE END

