function initSource(this, hApp, hReg, hCfg, varargin)
%INITSOURCE Initialize the source object.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/10/07 14:24:40 $

this.init(hApp, hReg, hCfg);

this.State = uiscopes.State;

if nargin>4
    this.ScopeCLI = varargin{1};
end

this.Type = hReg.Name;


% [EOF]
