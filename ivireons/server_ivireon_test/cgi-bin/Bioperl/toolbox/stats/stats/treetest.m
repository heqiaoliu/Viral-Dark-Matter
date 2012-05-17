function [varargout] = treetest(Tree,varargin)
%TREETEST Obsolete function
%   
%   TREETEST will be removed in a future release. Use CLASSREGTREE/TEST instead.
%
%   See also CLASSREGTREE/TEST.

%   Copyright 1993-2009 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:17:52 $

if nargin==0
    error('stats:treetest:TooFewInputs',...
          'At least one input required.')
end

if ~isa(Tree,'classregtree')
    if isa(Tree,'struct')
        Tree = classregtree(Tree);
    else
        error('stats:treetest:BadTree',...
              'First argument must be a decision tree.');
    end
end

[varargout{1:max(1,nargout)}] = test(Tree,varargin{:});
