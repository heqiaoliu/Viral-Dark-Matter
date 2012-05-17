function [y,isvalid] = getappdata(h,name)
%GETAPPDATA Get value of application-defined data from a UIMgr node.
%   VALUE = GETAPPDATA(H, NAME) gets the value of the
%   application-defined data with name specified by NAME in the
%   UIMgr object with handle H.  If the application-defined data does
%   not exist, an empty matrix will be returned in VALUE.
%
%   If NAME is a cell-array of strings, VALUE is a cell-array of values.
% 
%   VALUES = GETAPPDATA(H) returns all application-defined data
%   for the UIMgr object with handle H.
%
%   [VALUE,ISVALID] = GETAPPDATA(H,NAME) returns TRUE for ISVALID
%   if the application-defined data exists.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $  $Date: 2008/02/02 13:12:21 $

d=h.AppData;
if nargin<2
    % Get all fields
    isvalid=true;
    y=d;
else
    % Get specified field
    isvalid = isfield(d,name);
    cellResult = iscell(name);
    if ~cellResult
        if isvalid
            y=d.(name);
        else
            y=[];
        end
    else
        y = cell(1, numel(isvalid));
        for i=1:numel(isvalid)
            if isvalid(i)
                y{i}=d.(name{i});
            else
                y{i}=[];
            end
        end
    end
end

% [EOF]
