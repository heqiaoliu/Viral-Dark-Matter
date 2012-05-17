function schema
% Defines properties for @abstrimimport an abstract class for import dialog
% creation

%   Author(s): John Glass
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2005/12/22 17:41:45 $

% Register class 
pksc = findpackage('ctrldlgs');
pk = findpackage('sisogui');
c = schema.class(pk,'ImportDialogBrowser',findclass(pksc,'abstrimport'));

% Basic properties
p = schema.prop(c,'ImportDialog','handle');
