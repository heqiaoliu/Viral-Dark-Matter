function varargout = codeblock(varargin)
% Constructor for the codeblock object.
% Recursively traverse momento hierarchy and create a parellel
% hierarchy of code objects. Each code object encapsulates 
% the constructor and helper functions.

%   Copyright 2003-2007 The MathWorks, Inc.

% Syntax: codegen.codeblock(momento)
%         codegen.codeblock(momento,code_parent)

hThis = codegen.codeblock;
constructObj(hThis,varargin{:});
if nargout ~= 0
    varargout{1} = hThis;
end