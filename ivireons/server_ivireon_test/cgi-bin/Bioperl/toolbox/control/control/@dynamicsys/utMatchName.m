function [indy1,indu2] = utMatchName(L1,L2)
% Matches input channels of L2 against output channels of L1. 
%
%   [INDY1,INDU2] = UTMATCHNAME(L1,L2) matches the input channel
%   names of L2 against the output channel names of L1 and returns 
%   index vectors such that
%      L2.InputName(INDU2) = L1.OutputName(INDY1)
%
%   This function is used for named-based interconnections.

%   Author(s): P. Gahinet
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2007/12/14 14:23:28 $
if any(strcmp(L2.InputName,'')) || any(strcmp(L1.OutputName,''))
    ctrlMsgUtils.error('Control:combination:UndefinedIONames')
end
[junk,indy1,indu2] = intersect(L1.OutputName,L2.InputName);
