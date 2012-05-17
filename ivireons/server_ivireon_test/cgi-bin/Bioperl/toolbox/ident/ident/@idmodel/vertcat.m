function L = vertcat(L1,L2)
%VERTCAT  Vertical concatenation of IDMODEL objects. 
%
%   MOD = VERTCAT(MOD1,MOD2,...) performs the concatenation 
%   operation
%         MOD = [MOD1 ; MOD2 , ...]
% 
%   This operation amounts to appending  the outputs of the 
%   IDMODEL objects MOD1, MOD2,... and feeding all these models
%   with the same input vector.
% 
%   See also HORZCAT.

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.9.4.5 $ $Date: 2008/12/29 02:07:40 $

L = L1;
if nargin==1,
   % Parser call to HORZCAT with single argument in [SLTI ; SYSJ.LTI]
   return
end

% Notes and UserData
%L.Notes = {};
%L.UserData = [];
if any(L1.InputDelay ~=L2.InputDelay)
    ctrlMsgUtils.error('Ident:combination:concatUDelayMismatch')
end
if L1.Ts~=L2.Ts,
   ctrlMsgUtils.error('Ident:combination:concatTsMismatch')
end

% Append output names
[nol,L.OutputName,ovl] = defnum2(L1.OutputName, 'y',L2.OutputName);
if ~isempty(ovl)
     ctrlMsgUtils.error('Ident:combination:vertcatNonUniqueYname')
end

 L.OutputUnit = [L1.OutputUnit ; L2.OutputUnit];
% OutputName: check compatibility and merge
if ~isempty(L1.InputName) % not time series
	[L.InputName,InputNameClash] = mrgname(L1.InputName,L2.InputName);
	if InputNameClash
        ctrlMsgUtils.warning('Ident:combination:concatUNameClash')
		L.InputName = defnum({},'u',length(L.InputName));
	end
	[L.InputUnit,UnitClash] = mrgname(L1.InputUnit,L2.InputUnit);
	if UnitClash
		ctrlMsgUtils.warning('Ident:combination:concatUnitClash')
		EmptyStr = {''};
		L.InputUnit = EmptyStr(ones(length(L.InputName),1),1);
	end
end
W1 = L1.Algorithm.Weighting;
W2 = L2.Algorithm.Weighting;
W = blkdiag(W1,W2);
L.Algorithm.Weighting = W;
