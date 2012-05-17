function schema
%SCHEMA Schema for deadsateditor class

%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2008/10/31 06:13:37 $

% Construct class
hCreateInPackage   = findpackage('nlutilspack');
c = schema.class(hCreateInPackage, 'initmodeldialog');

schema.prop(c,'Owner','MATLAB array');
schema.prop(c,'jOwnerFrame','MATLAB array');
schema.prop(c,'jCheck','MATLAB array');
schema.prop(c,'jCombo','MATLAB array');
schema.prop(c,'jInfoArea','MATLAB array');
schema.prop(c,'jDialog','MATLAB array');

schema.prop(c,'Data','MATLAB array');


% array of listeners 
schema.prop(c,'Listeners','MATLAB array');