function schema
% SCHEMA  Defines properties for @siminputtable class

% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.6.8 $ $Date: 2008/09/15 20:36:29 $

% Find parent package
% Register class (subclass)
superclass = findclass(findpackage('sharedlsimgui'), 'table');
c = schema.class(findpackage('lsimgui'), 'siminputtable', superclass);

% Properties

% Buffer to store copiedData structure when a cut operation is performed.
% Used to recognize when a paste is from cut rather than copied data
schema.prop(c, 'cutrows','MATLAB array');   
schema.prop(c, 'name','string');   
schema.prop(c, 'visible','on/off');   
% Buffer to store copiedData structure when a cut/copy operation is performed.
schema.prop(c, 'copieddatabuffer', 'MATLAB array');
% Structure array defining the input signals that have been assigned to
% the systems(s)
schema.prop(c, 'inputsignals','MATLAB array'); 
% Handle to importselector editor (if created)
schema.prop(c, 'importSelector','handle'); 
% Handle to signal generator (if created)
schema.prop(c, 'signalgenerator','handle'); 
% Keep last calldata array (parent prop) in case the user enters invalid text
schema.prop(c, 'lastcelldata','MATLAB array'); 
% The interpolation status ('','zoh','foh')
p = schema.prop(c, 'interpolation','string');
p.FactoryValue = 'zoh';
% Definition of the time vector
p = schema.prop(c, 'Simsamples','double');
p.FactoryValue = 0;
p = schema.prop(c, 'Starttime','double');
p.FactoryValue = 0;
p = schema.prop(c, 'Interval','double');
p.FactoryValue = 1;
schema.prop(c, 'inputnames','MATLAB array');
schema.prop(c, 'guistate','handle');