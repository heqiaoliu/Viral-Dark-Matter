function this = MEViewDomain(manager, name)
% Manages Domains for view management.

%   Copyright 2009 The MathWorks, Inc.

this = DAStudio.MEViewDomain;
% Name of this domain.
this.Name = name;
% Manager managing this domain.
this.ViewManager = manager;
% Current view for this domain.
this.ActiveView = [];