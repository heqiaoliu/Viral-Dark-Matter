function Tree=treefit(X,y,varargin)
%TREEFIT Obsolete function
%   
%   TREEFIT will be removed in a future release. Use CLASSREGTREE instead.
%
%   See also CLASSREGTREE.

%   Copyright 1993-2007 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:17:50 $

Tree = classregtree(X,y,varargin{:});