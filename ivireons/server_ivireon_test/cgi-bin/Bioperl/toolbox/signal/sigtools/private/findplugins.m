function plugins = findplugins(filename)
%FINDPLUGINS Finds plug-ins

%   Author(s): P. Pacheco, J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.5.4.6 $  $Date: 2008/04/21 16:32:03 $

[p, filename, ext] = fileparts(filename);
if isempty(ext), ext = '.m'; end

filename = [filename ext];

all_plugins = which('-all',filename);
[p, filename, ext] = fileparts(filename);

plugins     = {};

for i = 1:length(all_plugins)

    % Open the file
    fid  = fopen(all_plugins{i}, 'r');
    if fid ~= -1
        
        % Read in the file contents
        file = setstr(fread(fid)');
        fclose(fid);
                
        idx = min(findstr(file, '='));
        
        structname = deblank(file(9:idx-1));
        structname = fliplr(deblank(fliplr(structname)));

        % Remove the function prototype
        idx = findstr(file, char(10));
        if ~isempty(idx)
        	file(1:idx(1)) = [];
        end
        try

            
            % Clear out the structure from previous registrations so that
            % optional fields do not get used in the current registration.
            clear(structname);
            eval(file);
            pluginStruct = eval(structname);
            
            % Remove unsupported plugins.
            supported = true;
            if isfield(pluginStruct,'supportedplatforms'),
                platform = computer;
                supported = any(strcmpi(platform,pluginStruct.supportedplatforms));
            end
            al = true;
            if isfield(pluginStruct, 'licenseavailable'),
                al = pluginStruct.licenseavailable;
            end
            if supported && al,
                plugins{end+1} = pluginStruct;
            end
            
        catch ME %#ok<NASGU> 
            % NO OP, we do not want to warn, because we would get the same warning
            % for each object that tried to load the plug-in file
        end
    end
end

% [EOF]
