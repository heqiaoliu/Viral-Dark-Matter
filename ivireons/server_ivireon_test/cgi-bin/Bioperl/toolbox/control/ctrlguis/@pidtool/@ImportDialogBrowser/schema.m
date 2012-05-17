function schema
% Defines properties for @abstrimimport an abstract class for import dialog
% creation

%   Author(s): R. Chen
%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:21:55 $

% Register class 
pksc = findpackage('ctrldlgs');
pk = findpackage('pidtool');
c = schema.class(pk,'ImportDialogBrowser',findclass(pksc,'abstrimport'));

% Basic properties
schema.prop(c,'Tuner','MATLAB array');
