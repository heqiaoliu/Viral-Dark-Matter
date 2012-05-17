function animationmenu(h, menuObj);
%ANIMATIONMENU  Animation menu callback for multipath figure object.

%   Copyright 1996-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/02/14 16:07:04 $

h.setanimation;

% Refreshing snapshot will cause animation to start if mode is switched
% from non-animating to animating.
h.refreshsnapshot;
