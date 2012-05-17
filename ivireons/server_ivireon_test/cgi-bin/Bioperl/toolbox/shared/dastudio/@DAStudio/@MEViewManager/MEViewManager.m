function this = MEViewManager()

%   Copyright 2009 The MathWorks, Inc.

this = DAStudio.MEViewManager;
this.ActiveDomainName = 'Other';
% This is default domain.
this.Domains = DAStudio.MEViewDomain(this, 'Other');
this.SuggestionMode = 'auto';