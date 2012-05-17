function h = settimeseriesnames(h,oldname,newname)
%SETTIMESERIESNAMES  Change the name of the selected time series object.
%
% TSC = SETTIMESERIESNAMES(TSC,OLD,NEW) replaces the name of time series OLD with
% name NEW in the tscollection object TSC. 
%

%   Copyright 2005-2007 The MathWorks, Inc.
%

if isempty(oldname) || ~isvarname(newname)
    error('tscollection:settimeseriesname:badsyntax',...
        'You must specify a non-empty old name and a valid new name as the second and third arguments of settimeseriesnames, respectively.')
end
if ~ischar(oldname) || ~ischar(newname)
    error('tscollection:settimeseriesname:onlychars',...
        'Both the old name and the new name must be strings.')
end
if any(strcmp(oldname,gettimeseriesnames(h)))  
    tmp = getts(h,oldname);
    tmp.Name = newname;
    h = setts(h,tmp,newname);
    h = removets(h,oldname);
else
    error('tscollection:settimeseriesname:badmember',...
        'Time series ''%s'' is not a member of the tscollection.',oldname)
end