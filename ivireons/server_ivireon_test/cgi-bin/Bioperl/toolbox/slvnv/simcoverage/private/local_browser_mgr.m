function varargout = local_browser_mgr(method,varargin)
%LOCAL_BROWSER_MGR - Manage instantiating a web browser 
%for the coverage tool.
%

%   Copyright 1990-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $

    persistent hBrowser;
    
    if nargin<1
        method = 'get';
    end
    
    switch(method)
    case 'get'
        varargout{1} = hBrowser;
    case 'displayFile'
        filePath = varargin{1};
        url = cvi.ReportUtils.file_path_2_url(filePath );
        
        if ~isempty(hBrowser)
            % Use a try-catch in case the browser was closed
            try
                valid = hBrowser.isValid;
                if ~valid
                    hBrowser = [];
                end
            catch
                hBrowser = [];
            end
        end
        
        if isempty(hBrowser)
            [status,hBrowser,loc] = web(url, '-new'); %#ok
        else
            try
                hBrowser.setCurrentLocation(url);
            catch
                    hBrowser = [];
            end
        end

        if nargout>0
            varargout{1} = hBrowser;
        end
    case 'jump2anchor'
        if ~isempty(hBrowser)
            currloc = hBrowser.getCurrentLocation;
            locRoot = strtok(currloc,'#');
            hBrowser.setCurrentLocation([locRoot '#' name]);
        end
    case 'rootCovFile'
        if ~isempty(hBrowser)
            currFileLoc = char(hBrowser.getCurrentLocation);
            baseFileName = cvi.ReportUtils.file_url_2_path(currFileLoc);
            if (~isempty(findstr(baseFileName,'_main.html')))
                baseFileName = find_base_contents_name(baseFileName);
            end
            varargout{1} = baseFileName;
        else
            varargout{1} = [];
        end
        
    otherwise
        assert(false,'Unrecognized method');
    end
    
    
function mainTarget = find_base_contents_name(topFileLoc)

    % Return empty if nothing is found
    mainTarget = '';

    topFileLoc = cvi.ReportUtils.file_url_2_path(topFileLoc);
    
    fid = fopen( topFileLoc, 'r');
    

    while 1
        strLine = fgetl(fid);
        if ~ischar(strLine) 
            break; 
        end
        if findstr(strLine,'<frame name="mainFrame" src="')
                        startIdx = findstr( strLine, 'src="') + 5;
            mainTarget = strtok(strLine(startIdx:end),'"');  
            break;
        end

    end
    fclose(fid);

    if isempty(mainTarget)
        mainTarget = topFileLoc;
    end



    