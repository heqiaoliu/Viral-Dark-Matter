function initialize(Constr)
%INITIALIZE  Initializes Nichols Closed-Loop Peak Gain Constraint objects

%   Author(s): Bora Eryilmaz
%   Revised:
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:32:23 $

% Add generic listeners and mouse event callbacks
Constr.addlisteners;

% Add @nicholsphase specific listeners
p = [Constr.findprop('OriginPha') ; Constr.findprop('PeakGain')];
Listener = handle.listener(Constr, p, 'PropertyPostSet', @update);
Listener.CallbackTarget = Constr;
Constr.addlisteners(Listener);
