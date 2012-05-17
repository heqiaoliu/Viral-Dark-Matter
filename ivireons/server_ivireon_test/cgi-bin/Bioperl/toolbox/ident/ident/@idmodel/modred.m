function rsys = modred(sys,elim,option)
%MODRED  Model state reduction.
%   Requires Control System Toolbox.
%
%   RMOD = MODRED(MOD,ELIM) or RMOD = MODRED(MOD,ELIM,'mdc') reduces
%   the order of the state-space model (IDSS or IDGREY object) MOD
%   by eliminating the states specified in vector ELIM.
%   The state vector is partitioned into X1, to be kept, and X2,
%   to be eliminated,
%
%       A = |A11  A12|      B = |B1|    C = |C1 C2|
%           |A21  A22|          |B2|
%       .
%       x = Ax + Bu,   y = Cx + Du  (or discrete time counterpart).
%
%   The derivative of X2 is set to zero, and the resulting equations
%   solved for X1.  The resulting system has LENGTH(ELIM) fewer states
%   and can be envisioned as having set the ELIM states to be infinitely
%   fast.  The original and reduced models have matching DC gains
%   (steady-state response).
%
%   RMOD = MODRED(MOD,ELIM,'del') simply deletes the states X2.  This
%   typically produces a better approximation in the frequency domain,
%   but the DC gains are not guaranteed to match.
%
%   If MOD has been balanced with BALREAL and the gramians have M
%   small diagonal entries, you can reduce the model order by
%   eliminating the last M states with MODRED.
%
%   See also BALRED, BALREAL, IDSS.

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.4.2.6 $  $Date: 2008/10/02 18:48:16 $

if nargin<2
    disp('Usage: RMOD = MODRED(MOD,ELIM)')
    disp('       RMOD = MODRED(MOD,ELIM,OPTION)')
    return
end

if ~iscstbinstalled
    ctrlMsgUtils.error('Ident:general:cstbRequired','modred')
end

if nargin<3
    option = 'mdc';
end

if ~(isa(sys,'idss') || isa(sys,'idgrey'))
    ctrlMsgUtils.error('Ident:transformation:modredCheck1')
end

try
    sys1 = ss(sys);
catch E
    throw(E)
end

sys1 = modred(sys1,elim,option);
rsys = idss(sys1);
