function bundle = getMessageData(id)
% getMessageData  Create a resource bundle from an xlate message
% file. id is the Product:component
%
 
% Copyright 2007-2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:11:33 $

persistent Listener

if isempty(Listener)
    r = handle(0);
    Listener = handle.listener(r,r.findprop('Language'),'PropertyPreSet',@LocalClearMessageDataBase);
end

exp = '^([A-Z][a-zA-Z0-9]*):([a-z][a-zA-Z0-9]*)$';
toks = regexp(id,exp,'tokens','once');

if(length(toks)==2)
    product = char(toks{1});
    component = char(toks{2});
    xlatefile = LocalGetMsgFile(product,component);

    identifiers = {sprintf('%s:%s',product,component),'loaded'};

    fid = fopen(xlatefile);

    % Get the first line in file
    cl = fgetl(fid);

    % Find the identifiers
    while ~isequal(cl,-1)
        if strncmp('<(',cl,2)
            % Key
            idx = findstr(cl,')');
            identifiers{end+1,1} = sprintf('%s:%s:%s',product,component,cl(idx(1)+1:end));
        end
        % Get next line in file
        cl = fgetl(fid);
    end
    fclose(fid);

    % Get the data
    for ct = 1:size(identifiers,1)
        % Use colon in front to return full string
        identifiers{ct,2} = DAStudio.message([':',identifiers{ct,1}]);
    end

    % Create the resource bundle
    bundle = com.mathworks.toolbox.shared.controllib.messagesystem.CustomResource;
    bundle.setContents(identifiers);
%     bundle.setContents( slcontrol.matlab2java(identifiers) );
else
    error('Message:BadID','Bad ID')
end



%%
function xlatefiles = LocalFindDirs(MessageDirs,CurrentLang)

xlatefiles = {};
for ct = 1:length(MessageDirs)
    SubDirs = dir(MessageDirs{ct});
    validSubDirs = find([SubDirs.isdir]&~strcmp({SubDirs.name},'..')&~strcmp({SubDirs.name},'.')&~strcmp({SubDirs.name},'CVS'));
    SubDirs = SubDirs(validSubDirs);
    for ct2 = 1:length(SubDirs)
       xlatefiles{end+1,1} =  fullfile(MessageDirs{ct},SubDirs(ct2).name,CurrentLang,'xlate');
    end
    
end

%%
function LocalClearMessageDataBase(es,ed)
MsgDB = com.mathworks.toolbox.shared.controllib.messagesystem.MessageDataBase;
MsgDB.clear;



%%
function xlatefile = LocalGetMsgFile(product, component)

[noProdFlag, MsgDir] = lookForMessageDIR(product);

if noProdFlag
    error('Message:InvalidID','Invalid message ID.')
else
    xlatefile =  fullfile(MsgDir,'messages',component,'en','xlate');
 end
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function [noProdFlag, MsgDir] = lookForMessageDIR(product)

persistent MsgDirectories;
noProdFlag = true;
MsgDir = [];

if isempty(MsgDirectories)
    MsgDirectories = lookForMessageDirectories;    
end

if isfield(MsgDirectories, product)
    MsgDir = MsgDirectories.(product);
    noProdFlag = false;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function MsgDirectories = lookForMessageDirectories

prodFiles = which('messageProductNameKey', '-all');

for i = 1:length(prodFiles)
    proddir = fileparts(prodFiles{i});
    msgdir = fullfile(proddir,'messages');
    if exist(msgdir,'dir')
        % add the product to MsgDirectories
        curDir = cd(proddir);
        prodKey = messageProductNameKey;                    
        if isvarname(prodKey)
            MsgDirectories.(prodKey) = proddir;
        else
            continue;
        end
        cd(curDir);
    end
end
    

    
    