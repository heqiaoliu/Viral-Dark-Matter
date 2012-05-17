classdef (Sealed = true) LoadFile < handle
    %LoadFile   Define the LoadFile class.
    
    %   Copyright 2009 The MathWorks, Inc.
    %   $Revision: 1.1.6.1 $  $Date: 2009/08/14 04:06:23 $

    properties (SetObservable)
        InitialDir;
    end
    
    properties
        Title;
        FilterSpec = {''};
        SelectedFile;
        SelectedPath       
    end
    
    methods

        function y = fullfile(h)
            %FULLFILE Returns concatenation of selected path and file            
            y = fullfile(h.SelectedPath, h.SelectedFile);
        end
        
        function notCancelled = select(h,saveFile)
            %SELECT Open file browser and wait until user selects file
            %   If the SAVEFILE argument is true, a "save file" dialog is opened
            %   instead of a "load file" dialog.  If omitted, SAVEFILE defaults
            %   to false (i.e., use a "load file" dialog).
            
            % Put up uigetfile box, opening it to the
            % last directory that the user pressed "ok",
            % or the initial directory
            
            % If .InitialDir is no longer valid, uigetfile automatically
            % substitutes the current directory - we want that behavior.
            % Note: .InitialDir should contain a trailing pathsep character
            
            if (nargin>1) && saveFile
                dlg = @uiputfile;
            else
                dlg = @uigetfile;
            end
            
            % Open file browser
            [filename, pathname] = feval(dlg, h.FilterSpec, h.Title, h.InitialDir);
            
            % Did user hit cancel?
            notCancelled = ~isequal(filename,0) && ~isequal(pathname,0);
            if notCancelled
                % Store path/file selection
                h.SelectedFile = filename;
                h.SelectedPath = pathname;
                h.InitialDir    = pathname;
            end
        end
        
        function setInitialDir(h, eventStruct)
            %SetInitialDir Sets initialDir property from preference listener.
            
            if isa(ev, 'event.PropertyEvent')
                pathStr = eventStruct.AffectedObject.(eventStruct.Source.Name);
            else
                pathStr = eventStruct.NewValue;
            end            
            
            % Must end with a file separator character
            if isempty(pathStr)
                pathStr = filesep;
            end
            if (pathStr(end) ~= filesep)
                pathStr = [pathStr filesep];
            end
            
            h.InitialDir = pathStr;
        end
    end
end

% [EOF]
