function  [nlobj,ei,nv,covmat] = soinitialize(nlobj, yvec, regmat, algo)
%SOINITIALIZE: single object initialization for PWLINEAR estimators.
%
%  [nlobj,ei,nv,covmat] = soinitialize(nlobj, yvec, regmat, algo)
%
%  yvec and regmat should be vectors.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2008/10/02 18:55:13 $

% Author(s): Qinghua Zhang

ni=nargin;
error(nargchk(4, 4, ni,'struct'))
ei.LossFcn = NaN;
ei.Iterations = NaN;
nv = [];
covmat = [];

if isempty(yvec) || isempty(regmat)
    ctrlMsgUtils.error('Ident:estimation:emptyData')
end
if iscell(yvec)
    % Tolerate cellarray data
    yvec = yvec{1};
end
if iscell(regmat)
    % Tolerate cellarray data
    regmat = regmat{1};
end

if ~isreal(yvec) || ~isreal(regmat) || ndims(yvec)~=2 || ndims(regmat)~=2
    ctrlMsgUtils.error('Ident:estimation:soinitialize1')
end
[nobsd, nyd] = size(yvec);
[nobs, regdim]=size(regmat);
if nobsd~=nobs
    ctrlMsgUtils.error('Ident:estimation:soinitialize2')
end

if regdim~=1
    ctrlMsgUtils.error('Ident:idnlfun:scalarInputOnly','PWLINEAR')
end

%Note: initialization (by NumberOfUnits) is necessary only if BreakPoints is empty

brpts = nlobj.BreakPoints;
if isempty(brpts)
    numunits = nlobj.NumberOfUnits;
    if isempty(numunits)
        numunits = 0;
    end
    if isempty(regmat)
        brpts = linspace(-1,1,numunits+2);
        brpts = brpts(2:end-1);
        nlobj.BreakPoints = brpts;
    else
        xmin = min(regmat);
        xmax = max(regmat);
        if xmax-xmin<(numunits+2)*eps
            xmin = xmin - 1;
            xmax = xmax + 1;
        end
        brpts = linspace(xmin, xmax, numunits+2);
        brpts = brpts(2:end-1);
        nlobj.BreakPoints = brpts;
    end
end

% FILE END
