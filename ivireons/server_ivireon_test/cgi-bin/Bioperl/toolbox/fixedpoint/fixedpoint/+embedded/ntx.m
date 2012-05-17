function s = ntx(varargin)
% This function is for INTERNAL USE ONLY

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:20:24 $


% NTX Launch numerictype explorer for fixed-point wordsize estimation.
[hParent,userOpts,data] = parseArgs(varargin);
if isempty(hParent)
    % For debug, create a scope driver
    hParent = scopedriver;
end
ntx = embedded.ntxui.NTX(hParent,userOpts);

if ~isempty(data)
    updateBar(ntx,data);
end
if nargout > 0
    % Provide access to caller
    s.update  = @(y)updateBar(ntx,y);
    s.reset   = @()resetHist(ntx);
    s.options = @()getCurrentUserSettings(ntx);
    s.ntx     = ntx;
end

function [hParent,userOpts,data] = parseArgs(argList)
% Parse input arguments
%
% Supported input argument lists:
%  f()
%  f(data)
%  f(parent,userOpts)
%  f(parent,userOpts,data)
%
% Caller specifies a handle to a parent axis or uipanel;
% omit or set to empty to have a new figure created automatically

hParent = []; % create a new figure if left empty
userOpts = []; % no options specified if empty
data = []; % no data on first call if empty

N = numel(argList);
error(nargchk(0,3,N));
if N==1
    % (data)
    data = argList{1};
elseif N>1
    % (parent,userOpts)
    hParent = argList{1};
    userOpts = argList{2};
    if N>2
        % (parent,userOpts,data)
        data = argList{3};
    end
end

% [EOF]
