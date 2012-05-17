function allowpcode(type)
%EML.ALLOWPCODE Control code generation from P-files.
%   This function controls code generation from P-files. By default,
%   P-files are not compiled. This command can be used to change this
%   default behavior.
%
%   Syntax:
% 
%   EML.ALLOWPCODE('<type>') 
%    The <type> argument is a string that controls P-file compilation. The
%    following types may be specified:
%       plain  Specifies that P-files may be compiled.
% 
%   Example:
%       eml.allowpcode('plain'); % enable P-file compilation
%
%   See also eml/ceval.

%   Copyright 2006-2010 The MathWorks, Inc.

switch type
    case 'plain'
    otherwise
        error('eml:allowpcode:typeError', 'Unrecognized allowpcode type');
end
