function [ts,offset,ph,mn]=slidentinit(tso,cbsim,mn)
% mask init function for estimator blocks such as ARX, OE, BJ.

% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.4.4 $ $Date: 2008/10/02 18:46:22 $

tso = eval(tso);
ts = tso(1);
if length(tso) > 1,
    offset = tso(2);
else
    offset = 0;
end

switch cbsim
    case 'Simulation'
        ph = inf;
    otherwise
        ph = eval(cbsim(1:2));
end
if ~isempty(mn)
    try
        assignin('base',mn,{});
    catch
        ctrlMsgUtils.error('Ident:simulink:invalidModelName')
    end
end

