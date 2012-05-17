function hOut = addNode(this, varargin)
% Overloaded addNode so that uitreenodes are connected

%   Copyright 2004-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2008/08/20 22:59:34 $

leaf = commonAddNode(this,varargin{:});
if nargout>0
    hOut = leaf;
end
