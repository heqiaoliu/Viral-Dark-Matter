function  domain = createDomain(this, domainName)
% Creates a new domain

%   Copyright 2009 The MathWorks, Inc.

% It should not exist already.
domain = find(this.Domains, 'Name', domainName);
% Check if this domain really exists. If not, create it at run time.
if isempty(domain)
	% Create it now and give it to the manager.
    domain = DAStudio.MEViewDomain(this, domainName);
	if isempty(this.Domains)
        this.Domains = domain;
    else
        this.Domains(end + 1) = domain;
    end
end