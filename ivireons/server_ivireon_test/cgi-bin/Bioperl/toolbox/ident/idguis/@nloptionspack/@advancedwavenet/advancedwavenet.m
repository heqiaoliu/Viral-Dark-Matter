function this = advancedwavenet(nloptionsobj)
% object for advanced properties of wavenet
% nloptionsobj: handle to nl options object whose parent contains the
% advanced button

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/11/17 13:31:45 $

this = nloptionspack.advancedwavenet;
this.Parent = nloptionsobj;
nloptionspack.configureAdvancedPropertiesObject(this);
