function [sys, ind] = estimateinitarg(sys, pvlist, ind)
%ESTIMATEINITARG: Process the P-V arguments for initial state estimation.
%
% Look for InitialState in pvlist(ind) and set the found value to sys.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/10/02 18:54:25 $

% Author(s): Qinghua Zhang


if nargin<3
    ind = 1:length(pvlist);
end

if isempty(ind)
    % Do nothing in this case
    return
end

lthind = length(ind);

InitArgFound = false;
toRemove = false(1,lthind);
for ka=1:2:lthind;
    ki = ind(ka);
    if ischar(pvlist{ki}) && strncmpi(pvlist{ki}, 'InitialState', max(3, length(pvlist{ki})))
        if InitArgFound
            ctrlMsgUtils.error('Ident:general:multipleSpecificationForOpt','InitialState')
        else
            InitArgFound = true;
            
            if ki+1>max(ind)
                ctrlMsgUtils.error('Ident:utility:missingPropVal')
            end
            
            initval = pvlist{ki+1};
            
            if ischar(initval) && strncmpi(initval, 'z', 1)
                sys = pvset(sys, 'InitialState', []);
            elseif (ischar(initval) && strncmpi(initval, 'e', 1))
                sys = pvset(sys, 'InitialState', 'e');
            else
                ctrlMsgUtils.error('Ident:idnlmodel:idnlhwx0Val')
            end
            
            toRemove([ka ka+1]) = true;
        end
    end
end

if any(toRemove);
    ind(toRemove) = [];
end

% FILE END
