function CheckCompilerCompatible(h)

% Copyright 2004-2008 The MathWorks, Inc.

    % Get language setting from configset
    GenCPP = rtwprivate('rtw_is_cpp_build', h.ModelName);

    if GenCPP && IsCompilerLCC(h)
        DAStudio.error('RTW:makertw:lccNotCPPcompiler');
    end;


function result = IsCompilerLCC(h)

    [pathstr, namestr] = fileparts(h.CompilerEnvVal);
    result = ~isempty(strfind(namestr, 'lcc'));
