function Ts = utValidateTs(Ts,IsData,IsTimeDomain)
% Validates value of Ts: sampling interval
% For time domain data, Ts>0 or [].
% For frequency domain data, Ts>=0
% For models, Ts>=0
% Ts could be a cell array of entries for multi-exp data

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2008/10/02 18:52:20 $

if IsData && IsTimeDomain
    % data Ts may be empty for time domain data
    BasicCheckFun = @(x)~isnumeric(x) || ~isreal(x) || ( ~isempty(x) && (~isscalar(x) || ~isfinite(x)) );
else
    BasicCheckFun = @(x)~isnumeric(x) || ~isscalar(x) || ~isreal(x) || ~isfinite(x);
end

if ~iscell(Ts)
    BasicCheckFailed = BasicCheckFun(Ts);
    if IsData
        Ts = {Ts};
    end
else
    % cell array for Ts not acceptable for models.
    BasicCheckFailed = ~IsData || any(cellfun(BasicCheckFun,Ts));
end

if IsData
    isMultiExp = length(Ts)>1;
    if IsTimeDomain && (BasicCheckFailed || any(cellfun(@(x)~isempty(x) && x<=0, Ts)))
        if ~isMultiExp
            ctrlMsgUtils.error('Ident:iddata:invalidTs')
        else
            ctrlMsgUtils.error('Ident:iddata:invalidTsMultiExp')
        end
    elseif ~IsTimeDomain && (BasicCheckFailed || any(cellfun(@(x) isempty(x) || x<0, Ts)))
        if ~isMultiExp
            ctrlMsgUtils.error('Ident:iddata:invalidTsForFreqData')
        else
            ctrlMsgUtils.error('Ident:iddata:invalidTsForFreqDataMultiExp')
        end
    else
        Ts = cellfun(@(x)double(full(x)),Ts,'UniformOutput',false);
    end
else
    if BasicCheckFailed || Ts<0
        ctrlMsgUtils.error('Ident:general:invalidTsForModels')
    else
        Ts = double(full(Ts));
    end
end
