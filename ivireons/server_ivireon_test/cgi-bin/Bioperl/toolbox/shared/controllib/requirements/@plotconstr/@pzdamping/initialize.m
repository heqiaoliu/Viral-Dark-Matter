function initialize(Constr)
%INITIALIZE   Initializes root-locus damping constraint object

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:33:06 $

% Add generic listeners and mouse event callbacks
Constr.addlisteners;

% Add @pzdamping-specific listeners
p = [Constr.findprop('Ts'); Constr.findprop('Damping')]; 
PropL = handle.listener(Constr,p,'PropertyPostSet',@update);
PropL.CallbackTarget = Constr;
Constr.addlisteners(PropL);
