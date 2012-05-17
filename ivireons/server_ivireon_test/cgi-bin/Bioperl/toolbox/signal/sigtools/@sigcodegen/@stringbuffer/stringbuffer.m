function this = stringbuffer(varargin)
%STRINGBUFFER Construct a stringbuffer object.
%   H = STRINGBUFFER Construct a stringbuffer object.
%
%   H = STRINGBUFFER(STR) Construct a stringbuffer object and call H.ADD(STR)
%   automatically.

%   Author(s): D. Orofino, J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/03/02 10:26:44 $

this = sigcodegen.stringbuffer;

if nargin > 0,
    this.add(varargin);
end

% [EOF]
