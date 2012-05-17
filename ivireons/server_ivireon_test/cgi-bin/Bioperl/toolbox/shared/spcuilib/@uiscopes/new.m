function hScope = new(hScopeCfg, varargin)
%NEW      Launch new scope instance.
%

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/11/18 02:14:29 $

% If it is an hScopeCfg, it is returned unchanged
% If input is an hMPlayer, create a ScopeCfg from it
if ~isa(hScopeCfg, 'uiscopes.AbstractScopeCfg')
    hScopeCfg = uiscopes.ScopeCfg(hScopeCfg);
end

% Check if the JVM has been loaded and error out if it hasn't.  Make sure
% that we get the scope config object so that we know we have an AppName
% that we can get to populate the error message.
if ~usejava('jvm')
    error(generatemsgid('noJVM'), '%s requires Java to run.', hScopeCfg.AppName);
end

% Launch new scope by constructing a new ScopeApp object
hScope = uiscopes.Framework(hScopeCfg, varargin{:});

uiscopes.manager('add', hScope);

% Make it visiable
if isVisibleAtLaunch(hScopeCfg)
    visible(hScope);
end

% [EOF]
