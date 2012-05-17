function schema
%  SCHEMA  Defines properties for @freqview class

%  Author(s):  
%  Copyright 1986-2006 The MathWorks, Inc.
%  $Revision: 1.1.6.4 $ $Date: 2006/06/27 23:11:17 $

% Register class (subclass)
superclass = findclass(findpackage('wrfc'), 'view');
c = schema.class(findpackage('tsguis'), 'specview', superclass);

% Class attributes
% Watermark lines
schema.prop(c, 'WatermarkCurves', 'MATLAB array');
% Handles of HG lines
schema.prop(c, 'Curves', 'MATLAB array');
% Handles of selected frequency range rectangles
schema.prop(c, 'SelectionPatch', 'MATLAB array');
% Selected frequency ranges
schema.prop(c, 'SelectedInterval', 'MATLAB array');
% Context menus for selection intervals
schema.prop(c,'Menus','MATLAB array');
