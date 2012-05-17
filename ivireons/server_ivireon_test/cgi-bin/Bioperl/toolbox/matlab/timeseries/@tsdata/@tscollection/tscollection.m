function h = tscollection(varargin)

% Copyright 2004-2006 The MathWorks, Inc.

h = tsdata.tscollection;
if nargin==0
    return
end
if nargin==1 && isa(varargin{1},'tscollection') 
    h.tsValue = varargin{1};
elseif nargin==1 && isa(varargin{1},'tsdata.tscollection')
    h.tsValue = varargin{1}.tsValue;
else
    h.tsValue = tscollection(varargin{:});
end


