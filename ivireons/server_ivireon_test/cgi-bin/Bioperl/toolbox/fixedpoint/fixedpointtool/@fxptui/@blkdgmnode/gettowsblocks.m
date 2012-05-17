function signals = gettowsblocks(h, varargin)
%GETWORKSPACEDATA   Get the workspaceData.

%   Author(s): G. Taillefer
%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/11/13 17:57:11 $

signals = initsignals(varargin{:});

paths = find_system(h.daobject.getFullName, ...
	'FollowLinks', 'on', ...
	'LookUnderMasks','all',...
	'BlockType','ToWorkspace');

for i = 1:length(paths)
    wsvarname = char(get_param(paths{i}, 'VariableName'));
    try
        % This check is put in place to prevent cases where an m-file with the same name as the variable gets executed and returns an output that does not
        % make sense. The exist command returns 1 if it finds a variable in the base workspace with the name wsvarname.
        if (evalin('base',['exist(''' wsvarname ''',''var'')']) == 1)
            wsdata = evalin('base', wsvarname);
            signals = addsignals(h, signals, paths{i}, wsvarname, wsdata, 1);
        end
    catch fpt_exception %#ok<NASGU> 
                        % Some variables will not be available in the base workspace,
                        % ignore error and continue. 
    end
end


% [EOF]
