function linkType = rmicustabcinterface
%RMICUSTABCINTERFACE - Example custom requirement link type
%
% This file implements a requirements link type that maps to "ABC" files.
% You can use this link type to map a line or item within an ABC
% file to a Simulink or Stateflow object.
%
% You must register a custom requirement link type before using it.
% Once registered, the link type will be reloaded in subsequent
% sessions until you unregister it.  The following commands
% perform registration and registration removal.
%
% Register command:   >> rmi register rmicustabcinterface
% Unregister command: >> rmi unregister rmicustabcinterface
%
% There is an example document of this link type contained in the
% requirement demo directory to determine the path to the document
% invoke:
%
% >> which demo_req_1.abc

%  Copyright 1984-2009 The MathWorks, Inc.
%  $Revision: 1.1.6.3 $  $Date: 2009/09/28 20:49:17 $

    % Create a default (blank) requirement link type
    linkType = ReqMgr.LinkType;
    linkType.Registration = mfilename;

    % Label describing this link type
    linkType.Label = 'ABC  file (for demonstration)';

    % File information
    linkType.IsFile = 1;
    linkType.Extensions = {'.abc'};

    % Location delimiters
    linkType.LocDelimiters = '>@';
    linkType.Version = '';             % not needed

    % Uncomment the functions that are implemented below
    linkType.NavigateFcn = @NavigateFcn;
    linkType.ContentsFcn = @ContentsFcn;


function NavigateFcn(filename,locationStr)
    if ~isempty(locationStr)
        findId=0;
        switch(locationStr(1))
        case '>'
            lineNum = str2num(locationStr(2:end));
            openFileToLine(filename, lineNum);
        case '@'
            openFileToItem(filename,locationStr(2:end));
        otherwise
            openFileToLine(filename, 1);
        end
    end


function openFileToLine(fileName, lineNum)
    if lineNum > 0
        err = javachk('mwt', 'The MATLAB Editor');
        if isempty(err)
            editorservices.openAndGoToLine(fileName, lineNum);
        end
    else
        edit(fileName);
    end


function openFileToItem(fileName, itemName)
    reqStr = ['Requirement:: "' itemName '"'];
    lineNum = 0;
    fid = fopen(fileName);
    i   = 1;
    while lineNum == 0
        lineStr = fgetl(fid);
        if ~isempty(strfind(lineStr, reqStr))
            lineNum = i;
        end;
        if ~ischar(lineStr), break, end;
        i = i + 1;
    end;
    fclose(fid);
    openFileToLine(fileName, lineNum);


function [labels, depths, locations] = ContentsFcn(filePath)
    % Read the entire file into a variable
    fid = fopen(filePath,'r');
    contents = char(fread(fid)');
    fclose(fid);

    % Find all the requirement items
    fList1 = regexpi(contents,'\nRequirement:: "(.*?)"','tokens');

    % Combine and sort the list
    items = [fList1{:}]';
    items = sort(items);
    items = strcat('@',items);

    if (~iscell(items) && length(items)>0)
     locations = {items};
     labels = {items};
    else
     locations = [items];
     labels = [items];
    end

    depths = [];


    
