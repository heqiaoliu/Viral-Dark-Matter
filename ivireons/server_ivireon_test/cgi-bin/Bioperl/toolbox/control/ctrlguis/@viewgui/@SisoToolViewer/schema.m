function schema
%SCHEMA  Defines properties for @SisoToolViewer class

%  Author(s): P. Gahinet
%  Copyright 1986-2003 The MathWorks, Inc.
%  $Revision: 1.3.4.2 $  $Date: 2005/12/22 17:44:31 $

% Register class
pkg = findpackage('viewgui');
c = schema.class(pkg, 'SisoToolViewer', findclass(pkg, 'ltiviewer'));

% Class attributes
%%%%%%%%%%%%%%%%%%%
p = schema.prop(c, 'Parent', 'handle');
p.Description = 'Handle of SISO Tool database.';

schema.prop(c, 'RealTimeData', 'MATLAB array');

p = schema.prop(c, 'RealTimeEnable', 'on/off');
p.Description = 'Enables dynamic response update during mouse edits of the compensators.';
p.FactoryValue = 'on';

p = schema.prop(c, 'SystemInfo', 'MATLAB array');
p.Description = 'Struct array defining the available loop transfers';

