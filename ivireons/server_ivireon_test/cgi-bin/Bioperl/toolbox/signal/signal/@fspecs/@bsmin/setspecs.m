function setspecs(this, varargin)
%SETSPECS   Set the specs.

%   Author(s): R. Losada
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/01/25 23:08:28 $

% If Apass2 not specified, make equal to Apass1 if the later is specified
if length(varargin) > 4 && length(varargin) < 7,
    % If Apass not specified set default
    if length(varargin) < 6,
        varargin{6} = this.Astop;
    end
    varargin{7} = varargin{5};
end

aswfs_setspecs(this,varargin{:});

% [EOF]
