%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [prodNotFound, catalogInfo] = getMessageCatalogInfo(pKey, cKey)
%  This is a shared function between DAStudio.message and 
%  DAStudio.batchMessage.  It should never be called directly.

%   Copyright 2008 The MathWorks, Inc.

mlock;
persistent messageCatalogDatabase;

prodNotFound = true;
catalogInfo = [];
cwd = pwd;

if isempty(messageCatalogDatabase)
    messageCatalogDatabase = buildMessageCatalogDatabase;
end

try

    catalogInfo = messageCatalogDatabase.(pKey).(cKey);
    prodNotFound = false;
    if isempty(catalogInfo.fcnHndl)
        
        cd(catalogInfo.xlateDir);
            
        % cache the handle to this function so that we do not have to cd again
        catalogInfo.fcnHndl = @getMsgStringFromId;
            
        if ( exist('setSLDiagnostic.m','file') || ...
             exist('setSLDiagnostic.p','file') )
            catalogInfo.treatAsSimulinkError = setSLDiagnostic;
        end
        cd(cwd);
    
        %update the persistent catalog database
        messageCatalogDatabase.(pKey).(cKey) = catalogInfo;
    end
    
catch %#ok
    
    if isfield(messageCatalogDatabase, pKey)
        prodNotFound = false; % at this point we have found the product
        if isfield(messageCatalogDatabase.(pKey), cKey)
            % we had an error make the catalogInfo cache invaldi
            messageCatalogDatabase.(pKey).(cKey) = [];
        end
    end
    cd(cwd);
end

end % getCatalogInfo

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function messageCatalogDatabase = buildMessageCatalogDatabase

    messageCatalogDatabase = struct;
    
    prodList = which('messageProductNameKey', '-all');

    for i = 1:length(prodList)
        
        prodDir = fileparts(prodList{i});
        prodName = getMessageProductNameKey(prodDir);
        if ~isvarname(prodName), continue; end
        
        msgDir = fullfile(prodDir,'messages');
        if ~exist(msgDir,'dir'), continue; end
         
        compList = dir(msgDir);
        compList = compList([compList.isdir]);
 
        for j = 1:length(compList)
            compName = compList(j).name;
            if ~isvarname(compName), continue; end
 
            compDir = fullfile(msgDir,compName);
            if ( ~exist(fullfile(compDir,'getMsgStringFromId.m'), 'file') && ...
                 ~exist(fullfile(compDir,'getMsgStringFromId.p'), 'file') )
                continue;
            end
            
            catalogInfo = createEmptyCatalogInfo;
            catalogInfo.xlateDir = compDir;
            messageCatalogDatabase.(prodName).(compName) = catalogInfo;
        end
    end
    
end % function buildMessageCatalogDatabase

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this function lets us execute a messageProductNameKey without checking
% out a license no matter what directory the function is in.
function pKey = getMessageProductNameKey(prodDir)
    pKey = '';

    fid = fopen(fullfile(prodDir,'messageProductNameKey.m'),'r');
    if fid < 0, return, end;

    %skip down to the function definition
    while 1
        fcnLine = fgetl(fid);
        if findstr(lower(fcnLine),'function'), break, end
    end

    fcnStr = '';
    while 1
        fcnLine = fgetl(fid);            % Read next line in file.
        if ~ischar(fcnLine), break, end  % Breaks out at end of file.
        dotsIndex = findstr(fcnLine,'...');
        if isempty(dotsIndex),
            fcnStr=[fcnStr fcnLine sprintf('\n')]; %#ok
        else
            % We're removing the "..." and literally concatenating the
            % two affected lines to make one line
            % Note: this will remove the "..."s inside any quoted strings
            fcnLine(dotsIndex:dotsIndex+2) = [];
            fcnStr=[fcnStr fcnLine]; %#ok
        end
    end
    fclose(fid);

    if ~isempty(fcnStr)
        try
            eval(fcnStr);
            pKey = retval;
        catch %#ok<CTCH>
            pKey = '';
        end
    end
end % function getMessageProductKeyInDir

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function catalogInfo = createEmptyCatalogInfo
    catalogInfo = struct('xlateDir','',...
                         'treatAsSimulinkError',false,...
                         'fcnHndl',[]);
end
