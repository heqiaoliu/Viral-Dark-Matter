function schema
%  SCHEMA  Defines properties for @corrview class

%  Author(s):  
%  Copyright 1986-2006 The MathWorks, Inc.
%  $Revision: 1.1.6.3 $ $Date: 2006/11/29 21:52:38 $

% Register class (subclass)
superclass = findclass(findpackage('wrfc'), 'view');
c = schema.class(findpackage('tsguis'), 'corrview', superclass);

% Class attributes
schema.prop(c, 'Curves', 'MATLAB array'); % Handles of HG lines

%% Selection lines
schema.prop(c, 'SelectionCurves', 'MATLAB array');

%% List of selected observation indices
schema.prop(c, 'SelectedPoints', 'MATLAB array');

%% Selection context menu handles
p = schema.prop(c, 'Menus', 'MATLAB array');
p.FactoryValue = struct('delete',[],'remove',[],'keep',[]);