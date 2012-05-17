function varargout = html_info_mgr(method,varargin)
%HTML_INFO_MGR - Function for managing data linked with the IceBrowser
%
%  HTML_INFO_MGR('load',FILELOC,DATA) Load data, DATA, for the 
%  specified browser location, FILELOC.  If DATA is omitted
%  the html file FILELOC is parsed for its persistent data. If
%  is also omitted the current browser location is parsed for
%  data.
%
%  VAL = HTML_INFO_MGR('get',FIELD,ROW,COL) Output the persistent
%  data elements: DATA.FIELD(ROW,COL).  If the COL index is omitted
%  the output will be DATA.FIELD(ROW,:) if both ROW and COL are
%  omitted the output is DATA.FIELD and if FIELD is omitted the
%  output is DATA.
%
%  HTML_INFO_MGR('set',WRITEBACK,VALUE,FIELD,ROW,COL) Set the persistent
%  data element DATA.FIELD(ROW,COL) to VALUE.  If the COL index is 
%  omitted set the elements DATA.FIELD(ROW,:) to VALUE, if both ROW 
%  and COL are omitted then DATA.FIELD is set to VALUE. If WRITEBACK
%  is nonempty and nonzero then the persistent data is re-encoded and
%  written to back to the HTML file.
%
%  HTML_INFO_MGR('childpage',MAINFILELOC,CHILDFILELOC) Indicate that
%  the html page CHILDFILELOC is related to MAINFILELOC and should 
%  share the same persistent data.
%
%  Special Considerations:
%
%  All methods other than 'load' test if the current location of
%  the help browser matches the cached value from the most recent
%  load or is a child page of the cached value.  If not, the current

%   Copyright 1990-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.10 $  $Date: 2009/07/03 14:41:27 $


	persistent infoStruct fileLoc childPages;

	if isempty(method) || ~ischar(method) 
		error('SLVNV:simcoverage:html_info_mgr:NontextualMethod','HTML_INFO_MGR requires a textual method');
	end

	switch(method)
	case 'load',
		fileLoc = varargin{1};
		
		% Clean up fileLoc
        fileLoc = cvi.ReportUtils.file_url_2_path(fileLoc);
		
		infoStruct = varargin{2};

	case 'get',
	    [infoStruct,fileLoc] = refresh_if_needed(infoStruct,fileLoc,childPages);
        if isempty(infoStruct)
            varargout{1} = [];
            return;
        end
        
	    cellVar = getfield(infoStruct,varargin{1});%#ok
		switch(nargin)
		case 2,
			varargout{1} = cellVar;
		case 3,
			varargout{1} = cellVar(varargin{2},:);
		case 4,
			varargout{1} = cellVar(varargin{2},varargin{3});
		end
		
	case 'set',
	    [infoStruct,fileLoc] = refresh_if_needed(infoStruct,fileLoc,childPages);
		switch(nargin)
		case 3,
			infoStruct = varargin{2};
		case 4,
			infoStruct = setfield(infoStruct,varargin{3},varargin{2}); %#ok
		case 5,
		    dataSet = getfield(infoStruct,varargin{3}); %#ok
		    dataSet(varargin{4},:) = varargin{2};
		    infoStruct = setfield(infoStruct,varargin{3},dataSet); %#ok
		end
		
		% Writeback if needed
		if (varargin{1})
            [status,hBrowser,currFileLoc] = web;
            fileName = cvi.ReportUtils.file_url_2_path(currFileLoc);
            if ispc
                fileName = strrep(fileName,'/','\');
            end
		    cv('HtmlWriteData',fileName,infoStruct);
		end


	case 'childpage'
		fileLoc = varargin{1};
		if isempty(childPages)
		    childPages{1} = fileLoc;
		    return;
		end
        if ~any(strcmp(fileLoc,childPages))
            childPages{end+1} = fileLoc;
        end
            
	otherwise,
		error('SLVNV:simcoverage:html_info_mgr:UnknownMethod','Unknown method');
	end



function [infoStruct,fileLoc] = refresh_if_needed(infoStruct,fileLoc,childPages)

    infoStruct = [];

    % XXX - This is using an undocumented webbrowser API
    activeBrowser = com.mathworks.mde.webbrowser.WebBrowser.getActiveBrowser;
    if isempty(activeBrowser)
        return;
    end

    [status,hBrowser,currFileLoc] = web;
    
    currFileLoc = cvi.ReportUtils.file_url_2_path(currFileLoc);
	reloadData = 0;
	
    % Check for the special case where the data is part of model_cov.html and
    % the current location is model_main.html
    if numel(currFileLoc)>=10 && strcmp(currFileLoc((end-9):end),'_main.html')
        currFileLoc = find_base_contents_name(currFileLoc);
    end
    
    if isempty(infoStruct) 
        reloadData = 1;
        fileLoc = currFileLoc;
    elseif ~strcmp(fileLoc,currFileLoc)
		if isempty(childPages)
            reloadData = 1;
            fileLoc = currFileLoc;
		else
        	if ~any(strcmp(fileLoc,childPages))
            	reloadData = 1;
            	fileLoc = currFileLoc;
        	end
		end
    end 
    
    if reloadData
        infoStruct = get_html_data(fileLoc);
    end


function data = get_html_data(fileName)

    fileName = cvi.ReportUtils.file_url_2_path(fileName);
	data = cv('HtmlReadData',fileName);


function mainTarget = find_base_contents_name(topFileLoc)

    % Return empty if nothing is found
    mainTarget = '';

    % Strip off the browser specific location info
    topFileLoc = cvi.ReportUtils.file_url_2_path(topFileLoc);

    fid = fopen( topFileLoc, 'r');
    
    strLine = fgetl(fid);
    while ischar(strLine)
        if(~isempty(strLine) && ~isempty(findstr(strLine,'<frame name="mainFrame" src="')))
            startIdx = findstr( strLine, 'src="') + 5;
            mainTarget = strtok(strLine(startIdx:end),'"');  
            mainTarget = strrep(mainTarget,'file:///','');
            break; 
        end
        strLine = fgetl(fid);
    end
        
    if isempty(mainTarget)
        mainTarget = topFileLoc;
    end

