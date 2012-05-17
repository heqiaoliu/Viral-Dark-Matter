function schema
% Defines properties for control design configuration wizard.

%   Author(s): John Glass
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2007/12/14 15:28:35 $

% Register class 
pk = findpackage('jDialogs');
c = schema.class(pk,'PickToolPanel');

% Basic properties
schema.prop(c,'Panel','MATLAB array');