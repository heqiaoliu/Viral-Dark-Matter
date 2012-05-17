function tsList = getTimeSeries(h,varargin)
%get a cell array of all timeseries members of this logs node.

%   Copyright 2004-2005 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $ $Date: 2005/06/27 22:58:09 $

%% Interface method to get the list of @timeseries to be plotted.
if nargin==1
    [tsList,Names]= h.tstoolUnpack;
end

%{
else
    v = varargin{1};
    if ischar(v) || isnumeric(v)
        tsList = utgetTsHandle(h.Tscollection,v);
    elseif iscell(v)
        for k = 1:length(v)
            tsList{k} = utgetTsHandle(h.Tscollection,v{k});
        end
    else
        tsList = {};
    end
end
%}
