function [hThis] = codeargument(varargin)

% Copyright 2003-2006 The MathWorks, Inc.

hThis = codegen.codeargument;
% By default, the active variable is itself:
hThis.ActiveVariable = hThis;
if nargin>0
   for n = 1:2:length(varargin)
      set(hThis,varargin{n},varargin{n+1});  
   end
end
