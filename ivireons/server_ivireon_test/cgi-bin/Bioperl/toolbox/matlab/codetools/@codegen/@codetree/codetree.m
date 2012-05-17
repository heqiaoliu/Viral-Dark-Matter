function hThis = codetree(varargin)
% Given an object, construct a code tree. Optionally notify the caller when
% the momento object's creation is created.

% Copyright 2006 The MathWorks, Inc.

hThis = codegen.codetree;
% Generate the momento object
hMomento = codegen.momento(varargin{:});
send(hThis,'MomentoComplete');

hThis.CodeRoot = codegen.codeblock(hMomento);
hThis.VariableTable = codegen.variabletable;
name = get(hThis.CodeRoot,'Name');
if isempty(name)
    name = 'object';
end
name = strrep(name,'.','_');   % Avoid use of dots in function name
function_name = sprintf('create%s',name);
hThis.Name = function_name;