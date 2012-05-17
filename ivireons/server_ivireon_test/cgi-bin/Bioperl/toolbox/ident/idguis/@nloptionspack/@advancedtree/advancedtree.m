function this = advancedtree(nloptionsobj)
% object for advanced properties of treepartition
% nloptionsobj: handle to nl options object whose parent contains the
% advanced button

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/11/17 13:31:43 $

this = nloptionspack.advancedtree;
this.Parent = nloptionsobj;

nloptionspack.configureAdvancedPropertiesObject(this);
