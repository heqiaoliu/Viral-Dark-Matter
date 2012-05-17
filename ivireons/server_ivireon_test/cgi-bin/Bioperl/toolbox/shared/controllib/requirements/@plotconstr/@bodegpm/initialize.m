function initialize(Constr)
%INITIALIZE  Initializes Bode phase Margin Constraint objects

%   Author(s): A. Stothert
%   Revised:
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:31:30 $

% Add generic listeners and mouse event callbacks
Constr.addlisteners;

% Add @bodegpm specific listeners
p = [...
   Constr.findprop('MarginGain') ; ...
   Constr.findprop('MarginPha'); ...
   Constr.findprop('PhaseEnabled'); ...
   Constr.findprop('GainEnabled')]; 
Listener = handle.listener(Constr, p, 'PropertyPostSet', @update);
Listener.CallbackTarget = Constr;
Constr.addlisteners(Listener);
