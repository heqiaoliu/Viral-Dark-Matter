function ttype=type(t)
%TYPE Type of tree.
%   TTYPE=TYPE(T) returns the type of the tree T.  TTYPE is 'regression'
%   for regression trees and 'classification' for classification trees.
%
%   See also CLASSREGTREE.

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:20:15 $

ttype = t.method;
