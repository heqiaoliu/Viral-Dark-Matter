function signals = gettowsscopes(h, varargin)
%GETSCOPESDATA   Get the scopesData.

%   Author(s): G. Taillefer
%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/11/13 17:57:13 $

signals = initsignals(varargin{:});

scopes = find_system(h.daobject.getFullName, ...
	'LookUnderMasks','all',...
	'BlockType','Scope',...
	'SaveToWorkspace','on');

for i = 1:length(scopes)
	path = fxptds.getpath(scopes{i});
	scopeobj = get_param(path, 'Object');
	numports = str2double(scopeobj.NumInputPorts);
	isoneresult = numports < 2;
	wsvarname = char(get_param(path, 'SaveName'));	
    try
        % This check is put in place to prevent cases where an m-file with the same name as the variable gets executed and returns an output that does not
        % make sense. The exist command returns 1 if it finds a variable in the base workspace with the name wsvarname.
        if (evalin('base',['exist(''' wsvarname ''',''var'')']) == 1)
            wsdata = evalin('base', wsvarname);
            signals = addsignals(h, signals, path, wsvarname, wsdata, isoneresult);
        end
    catch fpt_exception %#ok<NASGU>
                        % some variables might nor exist in the base workspace. Ignore
                        % error and continue.
    end
end

% [EOF]
