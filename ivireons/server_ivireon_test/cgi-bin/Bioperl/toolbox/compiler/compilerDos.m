function [varargout] = compilerDos(cmd, varargin)
%
% compilerDos is a helper function which contains code to wrap
% the dos command with pushd/popd if the currently working directory
% is specified by a UNC name.
%
    cwd = pwd;
    if (strncmp(cwd,'\\', 2))
        %
        % Looks current directory is  UNC name.
        % Use pushd to force cmd.exe into correct place.
        %
        explain = sprintf('%s','Using pushd/popd, disregard cmd.exe warnings about UNC directory pathnames.');
        cmd = [ 'pushd "' cwd '" & ' cmd ' & popd'];
    else
        explain = '';
    end
    prevState = warning('off', 'MATLAB:UIW_DOSUNC');
    if nargout==0
        disp(explain);
        dos(cmd,varargin{:});        
    else 
        if nargout==1
            disp(explain);
            varargout{1} = dos(cmd,varargin{:});
        else
            [varargout{1},result] = dos(cmd,varargin{:});
            if size(explain,2)~=0
                explain = [explain '\n'];
            end
            varargout{2} = [explain result];
        end        
    end
    warning(prevState);
