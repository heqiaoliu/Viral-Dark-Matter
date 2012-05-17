function schema
% SCHEMA  Defines properties for @initialselector class

% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:26:10 $

% Register class 
c = schema.class(findpackage('sharedlsimgui'), 'initialselector');

% Properties

% Structure of java handles describing import data GUI frame
schema.prop(c, 'importhandles', 'MATLAB array');
% workspace @varbrowser
schema.prop(c, 'workbrowser', 'handle');
schema.prop(c, 'frame','com.mathworks.mwswing.MJDialog');



