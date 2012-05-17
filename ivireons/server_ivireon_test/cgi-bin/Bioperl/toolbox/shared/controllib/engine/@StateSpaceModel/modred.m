function sys = modred(sys,elim,method)
%MODRED  State elimination and order reduction.
%
%   RSYS = MODRED(SYS,ELIM) reduces the order of the state-space model 
%   SYS by eliminating the states specified in vector ELIM.  The full 
%   state vector X is partitioned as X = [X1;X2] where X2 is to be 
%   discarded, and the reduced state is set to Xr = X1+T*X2 where T is 
%   chosen to enforce matching DC gains (steady-state response) between 
%   SYS and RSYS.
%
%   ELIM can be a vector of indices or a logical vector commensurate
%   with X where TRUE values mark states to be discarded.  If SYS has 
%   been balanced with BALREAL and the vector G of Hankel singular 
%   values has small entries, you can use MODRED to eliminate the 
%   corresponding states:
%      [sys,g] = balreal(sys)   % compute balanced realization
%      elim = (g<1e-8)          % small entries of g -> negligible states
%      rsys = modred(sys,elim)  % remove negligible states
%   Note: For more accurate results, use BALRED rather than BALREAL+MODRED.
%
%   RSYS = MODRED(SYS,ELIM,METHOD) also specifies the state elimination
%   method.  Available choices for METHOD include
%      'MatchDC' :  Enforce matching DC gains (default)
%      'Truncate':  Simply delete X2 and sets Xr = X1.
%   The 'Truncate' option tends to produces a better approximation in the
%   frequency domain, but the DC gains are not guaranteed to match.
%
%   See also BALREAL, SS.

%   J.N. Little 9-4-86
%   Revised: P. Gahinet 10-30-96
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:52:02 $
ni = nargin;
if ni<2
   ctrlMsgUtils.error('Control:general:TwoOrMoreInputsRequired','modred','modred')
elseif numsys(sys)~=1
   ctrlMsgUtils.error('Control:general:RequiresSingleModel','modred')
elseif ni==3 && any(strncmpi(method,{'m','d','t'},1))
   % Make sure to trap old keywords 'mdc' and 'del'
   if strncmpi(method,'m',1)
      method = 'MatchDC';
   else
      method = 'Truncate';
   end
else
   method = 'MatchDC';  % default
end

% Get order and check ELIM
ns = order(sys);
if isa(elim,'logical')
   elim = find(elim);
end
elim = elim(:);
if any(diff(sort(elim))==0) 
    ctrlMsgUtils.error('Control:general:IndexRepeated','modred(SYS,ELIM)','ELIM')
elseif any(elim<0) || any(elim>ns)
    ctrlMsgUtils.error('Control:general:IndexOutOfRange','modred(SYS,ELIM)','ELIM')
end

% Perform separation
try
   sys = modred_(sys,method,elim);
catch E
   ltipack.throw(E,'command','modred',class(sys))
end

% Clear notes, userdata, etc
sys.Name_ = [];  sys.Notes_ = [];  sys.UserData = [];
