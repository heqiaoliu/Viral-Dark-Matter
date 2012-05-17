function updateCache(hGroup)
%UPDATECACHE Update private caches.
%   Updates property caches for key binding id's and functions,
%   only if they are empty.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2009/05/23 08:12:28 $

% Update key id and key fcn caches
% cachedKeys:
%   cell-array of individual key name strings
%   must pull apart any cell-array of strings in registrations
%   into individual strings
%
% cachedIds:
%   cell-array of individual keypress fcn handles
%   must replicate function handles if KeyId was a cell-array
%   of key id strings

% storage for creating cache, updated by nested function
cachedKeys = {};
cachedFcns = {};

iterator.visitImmediateChildren(hGroup,@buildKeyCache);

% Retain cached key ids and fcns in properties
hGroup.cachedKeys = cachedKeys;
hGroup.cachedFcns = cachedFcns;

    function buildKeyCache(hBinding)
        % Nested function
        if (strcmpi(hBinding.Enabled,'on') && strcmpi(hBinding.Visible, 'on'))
            keyId = hBinding.KeyId;
            if ischar(keyId)
                % single id string
                cachedKeys = [cachedKeys {keyId}];
                cachedFcns = [cachedFcns {hBinding.Fcn}];
            else
                % cell array of strings
                for i=1:numel(keyId)
                    % copy each string from cell array
                    cachedKeys = [cachedKeys keyId(i)]; %#ok
                    % replicate fcn entry
                    cachedFcns = [cachedFcns {hBinding.Fcn}]; %#ok
                end
            end % char or cell array
        end % enabled binding
    end % nested fcn

end

% [EOF]
