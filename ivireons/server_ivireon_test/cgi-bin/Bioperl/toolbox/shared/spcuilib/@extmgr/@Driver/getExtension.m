function hExtension = getExtension(this,varargin)
%GETEXTENSION Return handle to extension instance.
%   getExtension(H,TYPE,NAME) returns handle to the extension specified by
%   TYPE and NAME strings.
%
%   getExtension(H,HREG) specifies the TYPE and NAME via the Register
%   object HREG.
%
%   Returns empty if no extension with matching type/name is found.

% Copyright 2006-2007 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2007/03/13 19:46:07 $

hExtension = getExtension(this.ExtensionDb, varargin{:});

% [EOF]
