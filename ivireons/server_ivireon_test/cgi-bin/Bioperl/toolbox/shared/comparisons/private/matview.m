function matview(filename,varname,basevarsuffix)
%MATVIEW Display a variable from a MAT-file in the Variable Editor
%   MATVIEW(filename,varname) opens the Variable Editor showing the value
%   of the specified variable in the specified MAT-file.

% Copyright 2007-2010 The MathWorks, Inc.
% $Revision: 1.1.6.5 $

    if nargin<3
        basevarsuffix = '';
    end
    
    try
        fullname = resolvePath(filename);
    catch E
        if strcmp(E.identifier,'MATLAB:Comparisons:FileNotFound')
            % Didn't find the file, but try again, this time explicitly
            % supplying an extension.
            try
                fullname = resolvePath([filename '.mat']);
            catch F
                % Still didn't find it.  Throw the *original* error message,
                % which won't include our extra ".mat" extension.
                rethrow(E);
            end
        else
            rethrow(E);
        end
    end
    [~,shortname] = fileparts(fullname);

    s = load('-mat',fullname,varname);
    
    % Generate a variable name based on the file name.  This is
    % deterministic and will produce the same variable name every time for
    % a given file.
    basename = genvarname([shortname '_file_contents' basevarsuffix]);
    refname = [basename '.' varname];
    
    % If the variable already exists, it's because we've previously viewed
    % other entries in this file.  Check whether they're still open in the
    % Variable Editor.
    create = true;
    if evalin('base',['exist(''' basename ''')'])
        if evalin('base',['isstruct(' basename ')'])
            create = false;
            % Take a local copy of the structure.  MATLAB will avoid making
            % copies of the actual fields, since we're not going to modify
            % their values.
            local = evalin('base',basename);
            fields = fieldnames(local);
            for i=1:numel(fields)
                thisfield = [basename '.' fields{i}];
                isopen = com.mathworks.mlservices.MLArrayEditorServices.isEditable(thisfield);
                if ~isopen
                    % This one is no longer open in the Variable Editor.  Delete
                    % the field from the structure.
                    local = rmfield(local,fields{i});
                end
            end
            local.(varname) = s.(varname);
            assignin('base',basename,local);
        end
    end
    
    if create
        % Variable doesn't exist (or isn't a structure).  Create it.
        assignin('base',basename,s);
    end
    
    openvar(refname);
end




