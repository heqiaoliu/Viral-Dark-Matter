function h=hline(varargin)
%HLINE draws horizontal lines
%   HLINE(X) draws one horizontal line for each element in vector x
%   HLINE(AX,X) draws the lines to the axes specified in AX
%   HLINE(X,...) accepts HG param/value pairs for line objects
%   H=HLINE(...) returns a handle to each line created
%
%   Note:  Be sure to include the initial AX argument if there is any
%          chance that X could be a valid handle.

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/03/31 19:01:17 $


if isempty(varargin) || (ishghandle(varargin{1}) && length(varargin)==1)
    error('stats:hline:NotEnoughArgs','Not enough arguments');
end

if isscalar(varargin{1}) && ishghandle(varargin{1})
    ax=varargin{1};
    varargin=varargin(2:end);
else
    ax=gca;
end

x = varargin{1};
varargin=varargin(2:end);
if feature('HGUsingMATLABClasses')
    hh = specgraphhelper('createConstantLineUsingMATLABClasses','parent',ax,varargin{:});
    hh.Value = x;
else
    hh = graph2d.constantline(x,'parent',ax,varargin{:});
end
if nargout>0
    h=hh;
end
