function initialize(Constr)
%INITIALIZE   Initializes root-locus natural frequency constraint object

%   Author(s): N. Hickey
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:33:21 $

% Add generic listeners and mouse event callbacks
Constr.addlisteners;

% Add @pzfrequency-specific listeners
p = [Constr.findprop('Ts');...
        Constr.findprop('Frequency');...
        Constr.findprop('Type')]; 
PropL = handle.listener(Constr,p,'PropertyPostSet',@update);
PropL.CallbackTarget = Constr;
Constr.addlisteners(PropL);
