function [sys1,g,T,Ti] = balreal(sys)
%BALREAL  Gramian-based balancing of state-space realizations.
%   Requires Control System Toolbox.
%
%   MODb = BALREAL(MOD) returns a balanced state-space realization
%   of the reachable, observable, stable model MOD, given as an
%   IDSS or IDGREY model.
%
%   [MODb,G,T,Ti] = BALREAL(MOD) also returns a vector G containing
%   the diagonal of the Gramian of the balanced realization.  The
%   matrices T is the state transformation xb = Tx used to convert SYS
%   to SYSb, and Ti is its inverse.
%
%   If the system is normalized properly, small elements in the balanced
%   Gramian G indicate states that can be removed to reduce the model
%   to lower order.
%
%   The noise input contributions are also balanced. To obtain a
%   balanced model with just measured inputs, use BALREAL(MOD('m')).
%
%   The covariance information is lost in the transition.

%	Copyright 1986-2008 The MathWorks, Inc.
%	$Revision: 1.5.4.6 $  $Date: 2008/10/02 18:47:54 $

if ~(isa(sys,'idss') || isa(sys,'idgrey'))
    ctrlMsgUtils.error('Ident:analysis:balrealCheck1')
end

if ~iscstbinstalled
    ctrlMsgUtils.error('Ident:general:cstbRequired','balreal')
end

try
    sys1 = ss(sys);
    %nx = size(sys,'nx');
catch E
    throw(E)
end
if nargout == 1
    sys1 = balreal(sys1);
else
    [sys1,g,T,Ti] = balreal(sys1);
end
sys1 = idss(sys1);
sys1 = pvset(sys1,'DisturbanceModel',pvget(sys,'DisturbanceModel'),...
    'Algorithm',pvget(sys,'Algorithm'));
