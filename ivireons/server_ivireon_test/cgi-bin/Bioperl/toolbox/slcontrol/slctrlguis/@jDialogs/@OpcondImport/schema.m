function schema
% Defines properties for @OpcondImport an abstract class for import dialog
% creation

%   Author(s): John Glass
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $ $Date: 2006/11/17 14:04:46 $

% Register class 
pksc = findpackage('ctrldlgs');
pk = findpackage('jDialogs');
c = schema.class(pk,'OpcondImport',findclass(pksc,'abstrimport'));

% Basic properties
schema.prop(c,'OpPoint','MATLAB array');
schema.prop(c,'NxDesired','MATLAB array');
schema.prop(c,'importfcn','MATLAB array');
schema.prop(c,'Projects','MATLAB array');
schema.prop(c,'Listeners','MATLAB array');