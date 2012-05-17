function outfig = treedisp(Tree,varargin)
%TREEDISP Obsolete function
%   
%   TREEDISP will be removed in a future release. Use CLASSREGTREE/VIEW instead.
%
%   See also CLASSREGTREE/VIEW.

%   Copyright 1993-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:17:49 $

if isa(Tree,'struct')
    Tree = classregtree(Tree);
end

view(Tree,varargin{:});
