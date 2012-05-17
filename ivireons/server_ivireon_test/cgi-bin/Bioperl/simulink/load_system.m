function varargout=load_system(sys)
%LOAD_SYSTEM Invisibly load a Simulink model.
%   LOAD_SYSTEM('SYS') loads the specified system without making the
%   model window visible.  If the specified system is 'built-in',
%   no action is taken.  The model name can be entered as a full
%   path, partial path or just the model name. The .mdl extension
%   is optional.
%
%   NOTE: Old style M-file models must be on the MATLAB
%   path, and they will always make the model window visible.
%
%   See also OPEN_SYSTEM.

%   Copyright 1990-2008 The MathWorks, Inc.
%   $Revision: 1.11.2.13 $

if strcmp(sys,'built-in')
    return;
end

% Check whether this is an old M-file model.
sysInput = sys;
[path,sys,ext] = fileparts(sys);
is_mfile = strcmpi(ext,'.m');

if isempty(ext) && isempty(path)
    name_on_path = which(sys);
    if ~isempty(name_on_path)
        [~,~,ext] = fileparts(name_on_path);
        if strcmpi(ext,'.m')
            is_mfile = true;
        end
    end
end
   
if is_mfile
    feval(sys);
    % set the version the latest version
    simver(get_param(0,'Version'));
    % run the preload callback in the base workspace
    evalin('base', get_param(sys,'PreloadFcn'));
else
    open_system(sysInput, 'loadonly');
end

if nargout
    varargout{1} = get_param(sys,'Handle');
end

% [EOF] load_system.m
