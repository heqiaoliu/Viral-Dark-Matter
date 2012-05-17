function obj = pGetInstance
;%#ok Undocumented
%Return a singleton.

%  Copyright 2007 The MathWorks, Inc.

persistent checker;
if isempty(checker)
    % Create and initialize a new singleton.
    checker = distcomp.typechecker;
    checker.pInit();
end

obj = checker;
