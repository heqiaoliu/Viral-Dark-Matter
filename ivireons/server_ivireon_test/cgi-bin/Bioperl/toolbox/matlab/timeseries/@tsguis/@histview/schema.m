function schema
%  SCHEMA  Defines properties for @freqview class

%  Author(s):  
%  Copyright 1986-2006 The MathWorks, Inc.
%  $Revision: 1.1.6.4 $ $Date: 2006/06/27 23:10:34 $

% Register class (subclass)
superclass = findclass(findpackage('wrfc'), 'view');
c = schema.class(findpackage('tsguis'), 'histview', superclass);

% Class attributes
% Watermark lines
schema.prop(c, 'WatermarkCurves', 'MATLAB array');
% Handles of HG lines
schema.prop(c, 'Curves', 'MATLAB array');
% Handles of selected frequency range rectangles
schema.prop(c, 'SelectionPatch', 'MATLAB array');
% Selected frequency ranges
schema.prop(c, 'SelectedInterval', 'MATLAB array');
% View menus
% Selected frequency ranges
schema.prop(c, 'Menus', 'MATLAB array');
