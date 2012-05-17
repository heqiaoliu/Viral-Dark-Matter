function [varargout] = mcrversion
% MCRVERSION Return the version number of the MCR.
%
% The MCR version number consists of three digits, separated by
% decimal points. This function returns each digit as a separate output
% variable.  The update number (3rd digit) is optional.  If not coded, update
% is returned as 0.
%
%    [major, minor, update] = mcrversion;
%
% Major, minor and update are returned as integers. If the version number ever
% increases to more than three digits, simply call mcrversion with more
% outputs:
%
%    [major, minor, update, point] = mcrversion;
%
% However, at this time, all outputs past "update" will be returned as zeros.

% Copyright 2010 The MathWorks, Inc.

    % Get the MCR version number from mcrversion.ver in toolbox/compiler.

    versionFile = fullfile(matlabroot, 'toolbox', 'compiler', ...
                           'mcrversion.ver');

    if ~exist(versionFile, 'file')
        error('Compiler:MissingMCRVersionFile', ...
              'MCR version file \n  ''%s''\n not found.', versionFile);
    end

    [major, minor, update] = textread(versionFile, '%d%d%d', 'delimiter', '.');
    if nargout >= 0
        varargout{1} = major;
    end
    if nargout > 1
        varargout{2} = minor;
    end
    if nargout > 2
        varargout{3} = update;
    end
    for k=4:nargout
        varargout{k} = 0;
    end

