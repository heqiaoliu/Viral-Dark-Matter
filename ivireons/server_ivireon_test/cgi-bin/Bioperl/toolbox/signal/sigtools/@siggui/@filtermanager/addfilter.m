function b = addfilter(this, filtobj, name, fs, src)
%ADDFILTER   Add a filter to the manager.

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2007/12/14 15:18:33 $

b = [];
overwrite = false;

if isstruct(filtobj)
    s = filtobj;
    
    % Add a force flag for the tests.
    if nargin < 3
        name = 'noforce';
    end
    
    % current_filt is a required field.
    if ~isfield(s, 'current_filt')
        error(generatemsgid('InvalidParam'),'Invalid structure');
    end
    
    % If currentName is not there, fill in a space holder.
    if ~isfield(s, 'currentName')
        s.currentName = 'Filter';
    end
    
    allnames = getnames(this);

    if any(strcmpi(allnames, s.currentName))
        
        trimmedallnames = allnames;

        for indx = 1:length(trimmedallnames)
            while ~isempty(str2num(trimmedallnames{indx}(end)))
                trimmedallnames{indx}(end) = [];
            end
        end

        while ~isempty(str2num(s.currentName(end)))
            s.currentName(end) = [];
        end
        
        similarindx = find(strncmpi(trimmedallnames, s.currentName, length(s.currentName)));

        allnums = [];
        for indx = 1:length(similarindx)
            ni = allnames{similarindx(indx)};
            numindx = 0;
            while ~isempty(str2num(ni(end-numindx:end)))
                numindx = numindx+1;
            end
            if numindx > 0
                allnums = [allnums str2num(ni(end-numindx+1:end))];
            end
        end
        
        if isempty(allnums)
            availablenums = 2;
        else
            availablenums = setdiff(2:max(allnums)+1, allnums);
        end
        
        s.currentName = sprintf('%s%d', s.currentName, availablenums(1));
    end
       
    if ~strcmpi(name, 'force')
        newname = inputdlg({'Enter filter name to be stored in the Filter Manager'}, ...
            'Store Filter:', 1, {s.currentName});
        shouldcontinue = true;
        if isempty(newname)
            return;
        end

        while any(strcmpi(newname, allnames)) && shouldcontinue
            answer = questdlg(sprintf('A filter called ''%s'' already exists.  Do you want to replace it?', ...
                newname{1}), ...
                'Store Filter:', 'Yes', 'No', 'Yes');
            
            % If they say they want to replace, continue, otherwise ask for
            % more information.
            if strcmpi(answer, 'Yes')
                shouldcontinue = false;
                overwrite = true;
            else
                newname = inputdlg({'Enter filter name to be stored in the Filter Manager'}, ...
                    'Store Filter:', 1, newname);
                
                if isempty(newname)
                    return;
                end

            end
        end

        if isempty(newname{1})
            return;
        end
        s.currentName = newname{1};
    end
    
    % We don't want to mess around with FVTool.
    if isfield(s, 'fvtool')
        s = rmfield(s, 'fvtool');
    end
    
    if isfield(s, 'sidebar')
        
        % Remove all extra panels, we want to be efficient.
        keep = {'currentpanel', 'design', 'mfilt', s.sidebar.currentpanel};
        
        fn = fieldnames(s.sidebar);
        fn = setdiff(fn, keep);
        for indx = 1:length(fn)
            s.sidebar = rmfield(s.sidebar, fn{indx});
        end
        
        % Don't mess with the static response.
        if isfield(s.sidebar, 'design')
            s.sidebar.design = rmfield(s.sidebar.design, 'StaticResponse');
        end
    end
else

    % We can also call this with the necessary fields.
    if nargin < 3, name = 'Filter'; end
    if nargin < 4, fs   = 1;  end
    if nargin < 5, src  = ''; end

    if isa(filtobj, 'dfilt.basefilter')
        s.version       = 1.1;
        s.current_filt  = filtobj;
        s.currentName   = name;
        s.currentFs     = fs;
        s.filterMadeBy  = src;
    else
        error(generatemsgid('InternalError'),'Filters must extend dfilt.basefilter');
    end
end

if overwrite
    
    allnames = getnames(this);

    indx2rep = find(strcmpi(allnames, s.currentName));
    
    this.Data.replaceelementat(s, indx2rep);
    send(this, 'NewData');
    b = indx2rep;
else
    this.Data.addelement(s);
    send(this, 'NewData');
    
    b = length(this.Data);
end

% [EOF]
