function node = createTstoolNode(ts,varargin)
%CREATETSTOOLNODE  Create a node for the timeseries object in the tstool
%tree. 
%
%   CREATETSTOOLNODE(TS,H) where H is the parent node object. Information
%   from H is required to check against existing node with same name.

%   Author(s): Rajiv Singh, James Owen
%   Copyright 2004-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $ $Date: 2006/06/27 23:06:15 $

len = length(get(ts,'Events'));
tsH = tsdata.timeseries(ts);
if len>0
    for i=1:len
        str(i) = {tsH.events(i).name};
    end
    
    if length(unique(str))~=len
        error(xlate('Unable to load object. The events names are not unique.'))
    end
end
node = tsH.createTstoolNode(varargin{:});
