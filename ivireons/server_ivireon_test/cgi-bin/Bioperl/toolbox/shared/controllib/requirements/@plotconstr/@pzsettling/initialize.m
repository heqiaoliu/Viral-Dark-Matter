function initialize(Constr)
%INITIALIZE   Initializes settling-time constraint.

%   Author(s): N. Hickey
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:33:43 $

% Add generic listeners and mouse event callbacks
Constr.addlisteners;

% Add @pzsettling-specific listeners
p = [Constr.findprop('Ts'); Constr.findprop('SettlingTime')]; 
PropL = handle.listener(Constr,p,'PropertyPostSet',@update);
PropL.CallbackTarget = Constr;
Constr.addlisteners(PropL);
