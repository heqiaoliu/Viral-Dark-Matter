function Views = getviews(this, varargin)

% Copyright 2004 The MathWorks, Inc.

%% Find the views associated with viewcontainer which are the children
%% of this node
Views = setdiff(this.find('-depth',1),this);
if nargin>1
    Views = Views(varargin{1});
end
    