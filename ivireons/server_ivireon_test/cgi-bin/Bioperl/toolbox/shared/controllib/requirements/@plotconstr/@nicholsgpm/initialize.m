function initialize(Constr)
%INITIALIZE  Initializes Nichols Phase Margin Constraint objects

%   Author(s): A. Stothert
%   Revised:
%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:32:04 $

% Add generic listeners and mouse event callbacks
Constr.addlisteners;

% Add @nicholsphase specific listeners
p = [Constr.findprop('OriginPha') ; Constr.findprop('MarginPha')]; 
Listener = handle.listener(Constr, p, 'PropertyPostSet', @update);
Listener.CallbackTarget = Constr;
Constr.addlisteners(Listener);


