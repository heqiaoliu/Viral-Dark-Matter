function fullpath=resolvePath(fname)
% Helper function which changes a relative filename into an absolute name.
% Throws an error if the name cannot be resolved.

% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.6.4 $

    fp = which(fname);
    if ~isempty(fp)
        if ~exist(fp,'file')
            pGetResource('error','MATLAB:Comparisons:FileNotFound',fp);
        end
        % The file exists on the MATLAB path.
        fullpath = fp;
    else
        % Use "exist" to try to find it.
        if exist(fname, 'file')
            % It exists. Use fileattrib to get the full path to this file,
            % since we may have been given a relative path:
            [ok, info] = fileattrib(fname);
            if ok
                fullpath = info.Name;
                return;
            end
        end
        pGetResource('error','MATLAB:Comparisons:FileNotFound',fname);
    end
end

