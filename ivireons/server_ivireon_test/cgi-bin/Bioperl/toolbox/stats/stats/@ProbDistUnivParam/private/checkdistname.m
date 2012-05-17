function [emsg,distname,spec] = checkdistname(distname)
%CHECKDISTNAME Check distribution name and get information about it.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/03/22 04:42:03 $

if isstruct(distname)
    % It's okay to pass in the distribution structure in place of the name
    try
        spec = distname;
        distname = spec.code;
        emsg = '';
    catch me
        spec = '';
        distname = '';
        emsg = 'Distribution name must be a character string.';
    end
    return
end

spec = '';
if ~ischar(distname) || size(distname,1)~=1
    emsg = 'Distribution name must be a character string.';
    return
end

% Check for abbreviations that are not just initial strings
distNames = {'extreme value' 'generalized extreme value' 'generalized pareto'...
             'negative binomial' 'discrete uniform' 'weibull'};
distAbbrevs = {'ev' 'gev' 'gp' 'nbin' 'unid' 'wbl'};
dist = lower(distname);
i = strmatch(dist,distAbbrevs,'exact');
if ~isempty(i)
    dist = distNames{i};
end

% Get information about this distribution
spec = dfswitchyard('dfgetdistributions',dist);

% Should get exactly one
if numel(spec) > 1
    emsg = sprintf('Ambiguous distribution name: ''%s''.',distname);
    spec = spec(1:0);
elseif isempty(spec)
    emsg = sprintf('Unknown distribution name: ''%s''.',distname);
else
    emsg = '';
    distname = spec.code;
end
