function schema
% SCHEMA  Defines properties for @lsimguistate class

% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.6.7 $ $Date: 2009/11/09 16:22:16 $

% Register class 
c = schema.class(findpackage('lsimgui'), 'lsimguistate');

% Properties
   
% @inputtable object: Needed so that selection dependent summary data can be displayed
schema.prop(c, 'inputtable','handle');
% Structure of java handles describing main GUI frame
p = schema.prop(c, 'Handles', 'MATLAB array');
p.FactoryValue = struct;
% Handle to @simplot
schema.prop(c, 'Simplot','handle'); 
% Handle to initial state table
schema.prop(c, 'initialtable','handle');
% Handle to time import dialog
schema.prop(c, 'TimeImportDialog','MATLAB array');
p = schema.prop(c, 'CurrentTab', 'double');
p.FactoryValue = 1;
schema.prop(c, 'Visible',    'on/off');  
% Private attributes
p = schema.prop(c, 'Listeners', 'handle vector');
set(p, 'AccessFlags.PublicGet', 'on', 'AccessFlags.PublicSet', 'on');

