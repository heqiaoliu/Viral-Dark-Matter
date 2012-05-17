function data = setid(data)
%SETID set the Identification tag of a data set
% This is just a temporary tag to be used inside estimation algorithms

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.4.2 $ $Date: 2008/04/28 03:18:30 $

ut = data.Utility;
if isfield(ut,'Idn')
    id = ut.Idn;
else
    id = [];
end
if isempty(id) && isfield(ut,'last')
    data.Utility.Idn = datenum(ut.last);
end
