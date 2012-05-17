function msg = datapropwarns(data, sys, props)
%DATAPROPWARNS Data property warnings
%   Generate warning messages when non critical properties of iddata object
%   are not consistent with those of the model.
%   Returns a cell array of warning messages

% Copyright 2006-2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/10/31 06:14:32 $

% Author(s): Qinghua Zhang

%props = {'Ts', 'OutputName', 'OutputUnit', 'InputName', 'InputUnit', 'TimeUnit'};
np = length(props);
msgFlags = false(1,np);

% Process 'Ts'
dataTs = data.Ts;
sysTs = pvget(sys, 'Ts');
if iscell(dataTs)
    dataTs = cell2mat(dataTs);
end
if iscell(sysTs) && ~isempty(sysTs)
    sysTs = sysTs{1};
end

if ~isempty(dataTs) && ~isempty(sysTs)
    if length(dataTs)>1 && any(diff(dataTs))
        msgFlags(1) = true;
    else
        msgFlags(1) = ~isequal(dataTs(1), sysTs);
    end
end

% Process other properties (with string values).
for kp=2:np % Starting from kp=2 after 'Ts'.
    dprop = data.(props{kp});
    sprop = pvget(sys, props{kp});
    if iscell(dprop) && length(dprop)==1
        dprop = dprop{1};
    end
    if iscell(sprop) && length(sprop)==1
        sprop = sprop{1};
    end
    
    if length(dprop)~=length(sprop)
        msgFlags(kp) = true;
    elseif ~(isempty(dprop) && isempty(sprop))
        msgFlags(kp)  = any(~strcmpi(dprop, sprop));
    end
end

nm = sum(msgFlags);

if nm==0
    msg = {};
    return
end

msg = cell(nm,1);
pt = 0;
for kp=1:np
    if msgFlags(kp)
        pt = pt + 1;
        msg{pt} = ctrlMsgUtils.message('Ident:general:dataModelPropMismatch',props{kp});
    end
end

% FILE END