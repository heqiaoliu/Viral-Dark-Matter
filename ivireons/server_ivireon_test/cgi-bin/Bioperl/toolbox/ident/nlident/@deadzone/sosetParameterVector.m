function nlobj = sosetParameterVector(nlobj, th)
%sosetParameterVector sets the parameters of a single DEADZONE object.
%
%  nlobj = sosetParameterVector(nlobj, vector)

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/10/02 18:52:51 $

% Author(s): Qinghua Zhang

if ~isinitialized(nlobj)
    ctrlMsgUtils.error('Ident:idnlfun:parSetNonInitializedNL')
end

if ~isempty(th) && ~all(isfinite(th(:)))
    ctrlMsgUtils.error('Ident:idnlfun:nonFinitePar','DEADZONE')
end

param = nlobj.prvParameters;
interval = param.Interval;

if isempty(interval) % Two sides
    if length(th)~=2
        ctrlMsgUtils.error('Ident:idnlfun:deadsatParSize','DEADZONE')
    end
    param.Center = th(1);
    param.Scale = th(2);
    nlobj.prvParameters = param;
    
else % Single side or degenerate
    indnoninf = find(~isinf(interval));
    if isempty(indnoninf) % degenerate case
        if ~isempty(th)
            ctrlMsgUtils.error('Ident:idnlfun:deadsatTwoSideInf','DEADZONE')
        end
    elseif length(indnoninf)==1 % Single side case
        if length(th)~=1
            ctrlMsgUtils.error('Ident:idnlfun:deadsatOneSidedDim','DEADZONE')
        end
        interval(indnoninf) = th;
        param.Interval = interval;
        nlobj.prvParameters = param;
        
    else % length(indnoninf)>1 %This should not happen
        ctrlMsgUtils.error('Ident:idnlfun:deadsatTwoSideIntervalStorage','DEADZONE')
    end
end

% FILE END

