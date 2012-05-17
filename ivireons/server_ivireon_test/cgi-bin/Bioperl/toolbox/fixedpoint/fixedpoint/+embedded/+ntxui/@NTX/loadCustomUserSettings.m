function loadCustomUserSettings(ntx,s)
% Load custom user settings
%
% This function can overwrite any number of default user settings,
% including none of them when no custom settings are provided.
%
% Settings for hBodyPanel must be in the .Body structure,
% and each setting is a field of the structure within that.
%
% Settings for hDialogPanel must be in the .Info structure,
% and each setting is a field of the structure within that.
%
% This is a bit permissive, in that any field already present in userdata
% could be overwritten.  We could further limit this in the future to be
% just the fields that are in the default user settings.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $     $Date: 2010/04/21 21:21:42 $

if isempty(s)
    return
end
if ~isstruct(s) || ~isscalar(s)
    % Internal message to help debugging. Not intended to be user-visible.
    error(generatemsgid('InvalidUserSettings'), ...
        'User settings must be specified as a scalar structure');
end
if ~all(isfield(s,{'Body','Info'}))
    % Internal message to help debugging. Not intended to be user-visible.
    error(generatemsgid('InvalidUserSettings'), ...
        'User settings must have .Body and .Info fields');
end

% Copy values from local struct to userdata based on the name of each
% structure field.  Unrecognized structure fields generate an error.
%
% Do it first for BodyData (histogram application)
sb = s.Body;
f = fieldnames(sb); % fields of user struct
for i = 1:numel(f)
    f_i = f{i};
    ntx.(f_i) = sb.(f_i);
end

% Then do it for dialog data
dp = ntx.dp;
si = s.Info;
f = fieldnames(sb); % fields of user struct
for i = 1:numel(f)
    f_i = f{i};
    dp.(f_i) = si.(f_i);
end
