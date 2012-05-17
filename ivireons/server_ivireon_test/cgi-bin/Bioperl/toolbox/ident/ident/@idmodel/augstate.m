function sys = augstate(sys)
%AUGSTATE  Appends states to the outputs of a state-space model.
%   Requires Control System Toolbox.
%
%   AMOD = AUGSTATE(MOD)  appends the states to the outputs of
%   the state-space model MOD given as an IDSS or IDGREY object.
%   The resulting model AMOD is an IDSS object, describing the
%   following system:
%      .                       .
%      x  = A x + B u
%
%     |y| = [C] x + [D] u
%     |x|   [I]     [0]
%
%   This command is useful to close the loop on a full-state
%   feedback gain  u = Kx.  After preparing the plant with
%   AUGSTATE,  you can use the FEEDBACK command to derive the
%   closed-loop model.
%
%   Covariance information is lost in the transformation.
%
%   The noise inputs are first eliminated. To include those,
%   first convert them to measured inputs by NOISECNV.


%    Copyright 1986-2008 The MathWorks, Inc.
%    $Revision: 1.3.4.5 $  $Date: 2008/10/02 18:47:53 $

if ~(isa(sys,'idss') || isa(sys,'idgrey'))
    ctrlMsgUtils.error('Ident:transformation:augstateCheck1')
end

if ~iscstbinstalled
    ctrlMsgUtils.error('Ident:general:cstbRequired','augstate')
end

try
    sys1 = ss(sys('m'));
    %nx = size(sys,'nx');
catch E
    throw(E)
end
sys1 = augstate(sys1);
sys = idss(sys1);
