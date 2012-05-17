function type = findType( tree )
%FINDTYPE given a a fileTree determines
%
% findType(tree) requires tree to not have comments.

%   Copyright 2009 The MathWorks, Inc.


if isa(tree, 'char')
    tree = mtree(tree,'-file');
end

if ~isa(tree,'mtree')
    error('MATLAB:codetools:NotATree','The input was not a mtree type.');
end

if isnull(tree)
    type = internal.matlab.codetools.reports.matlabType.Script;
    return
end

treeRoot = root(tree);
if iskind(treeRoot,'FUNCTION')
    type = internal.matlab.codetools.reports.matlabType.Function;
elseif iskind(treeRoot,'CLASSDEF')
    type = internal.matlab.codetools.reports.matlabType.Class;
elseif iskind(treeRoot, 'ERR')
    type = internal.matlab.codetools.reports.matlabType.Unknown;
else
    type = internal.matlab.codetools.reports.matlabType.Script;
end
end


