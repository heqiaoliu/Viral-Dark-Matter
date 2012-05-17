function  [nlobj,ei,nv,covmat] = soinitialize(nlobj, yvec, regmat, algo)
%SOINITIALIZE: single object initialization for SATURATION estimators.
%
%  [nlobj,ei,nv,covmat] = soinitialize(nlobj, yvec, regmat, algo)
%
%  yvec and regmat should be vectors.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2008/10/02 18:55:32 $

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
    ctrlMsgUtils.error('Ident:idnlfun:scalarInputOnly','SATURATION')
end

xmin = min(regmat);
xmax = max(regmat);

param = nlobj.prvParameters;
interval = param.Interval;

if isempty(interval) || all(~isinf(interval)) % Two sides
    param.Interval = [];
    param.Center = 0.5*(xmin+xmax);
    param.Scale = 0.7*0.5*(xmax-xmin);
    nlobj.prvParameters = param;
    
else % Single side or degenerate
    indnoninf = find(~isinf(interval));
    if isempty(indnoninf) % degenerate case
        % Do nothing
    elseif length(indnoninf)==1 % Single side case
        if indnoninf==1 % Left saturated
            interval(1) = xmin + 0.2*(xmax-xmin);
        else  % Right saturated
            interval(2) = xmin + 0.8*(xmax-xmin);
        end
        param.Interval = interval;
        nlobj.prvParameters = param;
        
    else % length(indnoninf)>1 %This should not happen
        ctrlMsgUtils.error('Ident:idnlfun:deadsatTwoSideIntervalStorage','SATURATION')
    end
end

% FILE END
