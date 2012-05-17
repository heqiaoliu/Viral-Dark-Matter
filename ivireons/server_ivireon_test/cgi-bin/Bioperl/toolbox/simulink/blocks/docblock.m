function varargout=docblock(varargin)
%DOCBLOCK  Simulink documentation block
%   DOCBLOCK manages the Simulink documentation block
%
%   The DocBlock can edit HTML and RTF files as well as plain text.  Do
%   SET_PARAM(BLKH,'DocumentType','HTML') or use the "Mask Parameters"
%   dialog to change the type of document associated with the block.
%
%   On PC systems, RTF and HTML files will be opened in Microsoft (TM)
%   Word.  Otherwise, the document content will be opened in the MATLAB
%   editor.  To change this behavior, use the commands:
%
%   DOCBLOCK('setEditorHTML',EDITCMD)
%   DOCBLOCK('setEditorDOC',EDITCMD)
%   DOCBLOCK('setEditorTXT',EDITCMD)
%
%   where EDITCMD is a string to be evaluated at the command line to launch
%   a custom application.  The special token %<FileName> will be replaced
%   with the full path to the file.  For example, to use Mozilla Composer
%   as your HTML editor, use the command:
%
%   docblock('setEditorHTML','system(''/usr/local/bin/mozilla -edit "%<FileName>" &'');')
%
%   To return to the default behavior, use an empty string ('') as EDITCMD
%
%   To get the current edit command settings, type:
%
%   EDITCMD = DOCBLOCK('getEditorHTML')
%   EDITCMD = DOCBLOCK('getEditorDOC')
%   EDITCMD = DOCBLOCK('getEditorTXT')
%
%   Custom editor commands persist between MATLAB sessions.
%

%   Copyright 1990-2009 The MathWorks, Inc.

%DocBlock parameters:
%      DeleteFcn		  "docblock('close_document',gcb);"
%      PreSaveFcn	      "docblock('save_document',gcb);"
%      OpenFcn		      "docblock('edit_document',gcb);"

%Enhancements:
% Install listeners on the editor so that when document is saved, changes are pushed to model
% Put inports on block to allow it to be hooked to a signal

if nargin==0
	varargout{1} = addToSystem;
elseif nargout==0
    try
        feval(varargin{:});
    catch ME
        warning(ME.identifier,'%s',ME.message);
    end
else
    try
        [varargout{1:nargout}]=feval(varargin{:});
    catch ME
        warning(ME.identifier,'%s',ME.message);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fName=getBlockFileName(blkName)
%Every block has a unique file name associated with it.
%This function returns that file.
%
% PRIVATE: This function is not guaranteed to remain stable

blkHandle = get_param(blkName,'handle');

try
	docExt = lower(get_param(blkName,'DocumentType'));
catch ME1 %#ok
	%This probably means that we have an old-style block which needs to be
	%upgraded.
    try
        convert_legacy_block(blkName);
    catch ME2
        warning('docblock:convertLegacyBlock','%s',ME2.message);
    end
	docExt = 'txt';
end

if strcmp(docExt,'text')
	docExt = 'txt';
end

fName = fullfile(tempdir,['docblock-',...
    strrep(sprintf('%0.12g',blkHandle),'.','-'),...
    '.',docExt]);

% Update the table of names every time we generate a name
internalFilenameToBlockHandle('set', fName, blkHandle);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = filename2blockhandle(fName) %#ok called from VnV code
% getBlockFileName(blkName) provides a deterministic filename for a given
% block. VnV features require the reverse procedure: given the filename get
% the block. To provide this sort of backword resolution, this manager
% function will maintain a table of blocknames.

result = internalFilenameToBlockHandle('get', fName);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = internalFilenameToBlockHandle(method, fName, blkHandle)

persistent namesTable;

if ~isa(namesTable, 'containers.Map')
    namesTable = containers.Map;
end

result = [];
switch method
    case 'get'
        if namesTable.isKey(fName)
            sid = namesTable(fName);
            if ~isempty(sid)
                result = Simulink.ID.getHandle(sid);
            end
        end
    case 'set'
        namesTable(fName) = Simulink.ID.getSID(blkHandle);
    case 'remove'
        namesTable.remove(fName);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function breaklink(blkName) %#ok called from legacy block callblock
%This is not used anymore.  Left around for legacy DocBlocks which still
%call docblock('breaklink') with their CopyFcn

%noop

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fileName=edit_document(blkName) %#ok called from block callback
%CALLBACK: used as OpenFcn
%Creates the text file and opens it in the user's selected editor

if nargin<1
    blkName = gcb;
end

try
    fileName = getBlockFileName(blkName);
catch ME
    fileName = '';
    warning('docblock:getTempFileName','%s',ME.message);
    return;
end

if exist(fileName,'file')
    %the file is already open - update the block
    try
        file2blk(blkName,fileName);
    catch ME
        warning(ME.identifier,'%s',ME.message);
    end
    dirtyModel = false;
else
    try
        blk2file(blkName,fileName);
    catch ME
        warning(ME.identifier,'%s',ME.message);
    end
    %the file does not exist - create it

    dirtyModel = true;
end

try
    open_document(fileName,blkName);
catch ME
    warning(ME.identifier,'%s',ME.message);
end

if dirtyModel
    %Dirty the model in order to encourage saving later on
    %Note: dirty the model AFTER opening it in the editor to make sure
    %that the warning dialog is not buried under the newly-opened editor.
    setDirty(blkName,'Changes to DocBlock may not be saved.  Unlock block diagram "%s"?');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function errMsg = open_document(fileName,varargin)

errMsg = '';
switch fileName(end-2:end)
	case {'rtf','doc'}
		docViewer = getEditorDOC;

        if ~isempty(docViewer)
            docViewer = strrep(docViewer,'%<FileName>',strrep(fileName,'''',''''''));
            try
                evalin('base',docViewer);
            catch ME
                errMsg = sprintf('Unable to launch DOC editor (command: "%s")\n\t%s',...
                    docViewer,ME.message);
            end
        elseif ispc
            errMsg = open_word(fileName);
        else
            open_editor(fileName,varargin{:});
        end
	case {'tml','htm'}
		htmlViewer = getEditorHTML;

        if ~isempty(htmlViewer)
            htmlViewer = strrep(htmlViewer,'%<FileName>',strrep(fileName,'''',''''''));
            try
                evalin('base',htmlViewer);
            catch ME
                errMsg = sprintf('Unable to launch HTML viewer (command: "%s")\n\t%s',...
                    htmlViewer,ME.message);
            end
        elseif ispc
            errMsg = open_word(fileName);
        else
            open_editor(fileName,varargin{:});
        end
    otherwise
		txtViewer = getEditorTXT;

        if ~isempty(txtViewer)
            txtViewer = strrep(txtViewer,'%<FileName>',strrep(fileName,'''',''''''));
            try
                evalin('base',txtViewer);
            catch ME
                errMsg = sprintf('Unable to launch text viewer (command: "%s")\n\t%s',...
                    txtViewer,ME.message);
            end
        else
            open_editor(fileName,varargin{:});
        end
end

if ~isempty(errMsg)
    open_editor(fileName,varargin{:});
	error('docblock:EditDocument','%s',errMsg);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function open_editor(fileName,varargin)
%This will open the MATLAB text editor and establish a file listener

try
    edit(fileName);
catch ME
    warning('docblock:TextEditorError','%s',ME.message);
end

if ~isempty(varargin)
    blkName = varargin{1};
    try
        blkHandle = get_param(blkName,'handle');
        blkObj = get_param(blkName,'Object');

        propName = 'DocBlockEditorFileListener';
        p = findprop(blkObj,propName);
        if isempty(p)
            p = schema.prop(blkObj,propName,...
                'com.mathworks.toolbox.simulink.docblock.EditorFileListener');
            p.AccessFlags.Serialize = 'off';
            p.AccessFlags.Copy = 'off';
        end

        fListen = get(blkObj,propName);
        if isempty(fListen)
            fListen = com.mathworks.toolbox.simulink.docblock.EditorFileListener(blkHandle,fileName);
            set(blkObj,propName,fListen);
        end
    catch ME
        warning('DocBlock:FileListenerAddError','%s',ME.message);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function errMsg = open_word(fileName)
% Open MS Word document.  If opened, then refocus.

errMsg = '';
try
    hWord = getWordObject();
catch ME
    errMsg = sprintf('Could not create Word activeX server\n\t%s',...
        ME.message);
    return;
end

% Make Word window visible
try
    hWord.Visible = true;
catch ME
    errMsg = sprintf('Could not open Word\n\t%s',...
        ME.message);
    return;
end

% See if the document is already open
hDocs = hWord.documents;
openCount = hDocs.count;
    
found = false;
i = 0;
while (~found && (i < openCount))
    i = i + 1;

    hDoc = hDocs.Item(i);
    if strcmpi(hDoc.FullName, fileName)
        % Bring window to the front
        try
            if (strcmpi(hDocs.Parent.WindowState, 'wdWindowStateMinimize'))
                hDocs.Parent.WindowState = 'wdWindowStateNormal';
            end
            hWord.Activate;
            hDocs.Item(i).Activate;
        catch ME
            errMsg = sprintf('Could not bring window up to the front\n\t%s',...
                ME.message);
            return;
        end
    end

end

if ~found 
    try
        hDoc = hDocs.Open(fileName, [], 0);
        hWord.Activate;
    catch ME
        errMsg = sprintf('Could not open file "%s"\n\t%s',...
            fileName,...
            ME.message);
    end
end


%Turn dirty flag off so Word doesn't query when closing
try
    hDoc.Saved = 1;
catch ME %#ok
    %noop, this is not a critical error.  don't report it.
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = getWordObject()

persistent hWord

% Check if hWord is valid
try
    hWord.Version;
catch ME %#ok
    % now try if Word already running
    try
        hWord = actxGetRunningServer('word.application'); 
    catch Me %#ok
        hWord = actxserver('word.application');
    end
end

out = hWord;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function setEditorTXT(editorCmd)  %#ok called from command line
%Sets the command used to edit text pages.
%The substring "%<FileName>" will be replaced with the full path name

%Direct M-code access to the java prefs mechanism is undocumented and may
%change in the future.  Beware!
com.mathworks.services.Prefs.setStringPref('docblock.editor.txt',editorCmd);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function editorCmd = getEditorTXT
%Returns the command used to edit text files.  See also getEditorTXT

%Direct M-code access to the java prefs mechanism is undocumented and may
%change in the future.  Beware!
editorCmd = char(com.mathworks.services.Prefs.getStringPref('docblock.editor.txt'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function setEditorHTML(editorCmd)  %#ok called from command line
%Sets the command used to edit HTML pages.
%The substring "%<FileName>" will be replaced with the full path name

%Direct M-code access to the java prefs mechanism is undocumented and may
%change in the future.  Beware!
com.mathworks.services.Prefs.setStringPref('docblock.editor.html',editorCmd);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function editorCmd = getEditorHTML
%Returns the command used to edit HTML files.  See also getEditorHTML

%Direct M-code access to the java prefs mechanism is undocumented and may
%change in the future.  Beware!
editorCmd = char(com.mathworks.services.Prefs.getStringPref('docblock.editor.html'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function setEditorDOC(editorCmd)  %#ok called from command line
%Sets the command used to edit .doc and .rtf pages.
%The substring "%<FileName>" will be replaced with the full path name

%Direct M-code access to the java prefs mechanism is undocumented and may
%change in the future.  Beware!
com.mathworks.services.Prefs.setStringPref('docblock.editor.doc',editorCmd);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function editorCmd = getEditorDOC
%Returns the command used to edit .doc and .rtf files.
%See also getEditorDOC

%Direct M-code access to the java prefs mechanism is undocumented and may
%change in the future.  Beware!

editorCmd = char(com.mathworks.services.Prefs.getStringPref('docblock.editor.doc'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function save_documents(mdlRoot) %#ok called from command line
%Saves all documents in a model
%Utility function - not called by the block

%disp('Saving docblock documents!');
if nargin<1
    mdlRoot = bdroot(gcs);
end

%find all subsystems
list = find_system(mdlRoot, 'LookUnderMasks', 'all', ...
                   'Variants', 'AllVariants', ...
                   'MaskType','DocBlock');

for i=1:length(list)
    save_document(list{i});   %perform potential save operation
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fileName = save_document(blkName) %called from block callback
%CALLBACK: used as PreSaveFcn
% Must not error, or else model can not be saved

try
    fileName = getBlockFileName(blkName);
catch ME
    fileName = '';
    warning('docblock:getTempFileName','%s',ME.message);
    return;
end

if exist(fileName,'file')
    try
        saveDirtyEditorFile(fileName);
    catch ME
        warning(ME.identifier,'%s',ME.message);
    end

    try
        file2blk(blkName,fileName);
    catch ME
        warning(ME.identifier,'%s',ME.message);
    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function close_documents(mdlRoot) %#ok called from command line
%Closes all documents in the model
%Utility function - not called by the block

if nargin<1
    mdlRoot = bdroot(gcs);
end

%find all subsystems
list = find_system(mdlRoot,'LookUnderMasks', 'all', ...
                   'Variants', 'AllVariants', ...
                   'MaskType','DocBlock');

modelDirtied = false;
for i=1:length(list)
    modelDirtied = max(modelDirtied,close_document(list{i}));
end

if modelDirtied
    %@ENHANCEMENT: should turn off save listeners
    save_system(mdlRoot);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function modelDirtied = close_document(blkName)
%closes documents if they are open in the editor
%deletes documents
%called by the block's DeleteFcn (called at model close time)
% Must not error, or else model can not be closed

modelDirtied = false;
if nargin<1
    try
        blkName = gcb;
    catch %#ok
        warning('docblock:noCurrentBlock','No current block');
        return;
    end
end

save_document(blkName);
try
    fileName = getBlockFileName(blkName);
catch ME
    warning('docblock:getTempFileName','%s',ME.message);
    return;
end

if exist(fileName,'file')
    try
        closeEditorFile(fileName);
        delete(fileName);
    catch ME
        warning('docblock:close_document','%s',ME.message);
    end
end

%Manage the life cycle of the file listener
propName = 'DocBlockEditorFileListener';
try
    blkObj = get_param(blkName,'Object');
    p = findprop(blkObj,propName);
    if ~isempty(p)
        fListen = get(blkObj,propName);
        if ~isempty(fListen)
            fListen.dispose();
            set(blkObj,propName,[]);
        end
    end
catch ME
    warning('DocBlock:FileListenerRemoveError','%s',ME.message);
end

% remove from map
internalFilenameToBlockHandle('remove', fileName);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function uncompress_rtf_document(blk)
%Uncompress rtf document for a given block

close_document(blk);
[content,format] = getContent(blk);
if strcmpi(format,'RTF_ZIP')
    content = uncompressRTFData(content);
    setContent(blk,content,'RTF');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function uncompress_rtf_documents(mdlRoot) %#ok called from command line
%Uncompress all rtf documents in a model
%Utility function - not called by the block

if (nargin<1)
    mdlRoot = bdroot(gcs);
end

%find all subsystems
list = find_system(mdlRoot,'LookUnderMasks', 'all', ...
                   'Variants', 'AllVariants', ...
                   'MaskType', 'DocBlock');

for i=1:length(list)
    uncompress_rtf_document(list{i});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function compress_rtf_document(blk)
%Compress rtf document for a given block

close_document(blk);
[content,format] = getContent(blk);

if strcmpi(format,'RTF')
    try
        content = compressRTFData(content);
        setContent(blk,content,'RTF_ZIP');
    catch me
        if strcmp(me.identifier,'docblock:foundascii')
            setContent(blk,content,'RTF');
        else
            rethrow(me);
        end
    end
        
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function compress_rtf_documents(mdlRoot) %#ok called from command line
%Compress all rtf documents in a model
%Utility function - not called by the block

if (nargin<1)
    mdlRoot = bdroot(gcs);
end

%find all subsystems
list = find_system(mdlRoot, 'LookUnderMasks', 'all', ...
                   'Variants', 'AllVariants', ...
                   'MaskType', 'DocBlock');

for i=1:length(list)
    compress_rtf_document(list{i});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fileName = blk2file(blkName,fileName)
%   DOCBLOCK('blk2file',BLKNAME)
%   Writes block contents to a file without creating listeners.
%  DOCBLOCK('blk2file',BLKNAME,FILENAME)
%   File name can optionally be specified.
%%

if nargin<2
    try
        fileName = getBlockFileName(blkName);
    catch ME
        fileName = '';
        warning('docblock:getTempFileName','%s',ME.message);
        return;
    end
end

[content,format] = getContent(blkName);

if isempty(content)
    %Support legacy RTWData DocBlock
    try
        rd = get_param(blkName,'RTWdata');
        if ~isempty(rd) && isstruct(rd)
            %struct2string - LEGACY SUPPORT
            sFields = fieldnames(rd);
            content = '';
            for i=1:length(sFields)
                if strncmp(sFields{i},'document_text',13)
                    theText = unicode2native(rd.(sFields{i}));
                    content = [content,theText]; %#ok expanding, no way to 
                                                 %determine final size
                end
            end
        else
            content = xlate('Type your documentation here');
        end
    catch ME
        content = ME.message;
        warning('docblock:getRTWData','%s',ME.message);
    end
else
    if strcmpi(format,'RTF_ZIP')
        content = uncompressRTFData(content);
    end
end

try
    [wfid,errMsg] = fopen(fileName,'w');
catch ME
    wfid = -1;
    errMsg = ME.message;
end

if wfid<0
	warning('docblock:createTempFile','%s',errMsg);
	return;
end

footerType = 0;
switch fileName(end-2:end)
	case {'rtf'}
		if isempty(findstr(content(1:min(128,length(content))),'{\rtf'))
			fwrite(wfid,['{\rtf\ansi\deff0',char(10),...
				'{\fonttbl{\f0\froman Tms Rmn;}}',char(10),...
				'{\stylesheet{\fs20 \snext0Normal;}}',char(10),...
				'\widoctrl\ftnbj \sectd\linex0\endnhere \pard\plain \fs20 '],...
				'char*1');
			footerType = 2;
		end
	case {'tml','htm'}
        %Word expects an HTML header and will treat the file as plain text
        %if it doesn't have one
		if isempty(findstr(content(1:min(128,length(content))),'<html'))
			fwrite(wfid,['<html><head></head><body>',char(10)],'char*1');
			footerType = 1;
		end
	%otherwise
		%Text file - no special formatting needed
end

%deliver the payload
try
    fwrite(wfid,content,'char*1');
catch ME
    warning('docblock:writeBlockToFile','%s',ME.message);
end

%write a special footer for the doctype if necessary
switch footerType
	case 2 %RTF
		fwrite(wfid,'}','char*1');
	case 1 %HTML
		fwrite(wfid,'</body></html>','char*1');
end

fclose(wfid);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function file2blk(blkName,fileName)
%Writes the contents of a file to the block
%Should never cause an error.


if nargin<2
    try
        fileName = getBlockFileName(blkName);
    catch ME
        warning('docblock:getTempFileName','%s',ME.message);
        return;
    end
end

try
    [rfid, message] = fopen(fileName,'r');
catch ME
    rfid = -1;
    message = ME.message;
end

if rfid<0
    warning('docblock:createTempFile','%s',message);
    return;
else
    try
        content = fread(rfid,inf,'char*1=>char')';
    catch ME
        warning('docblock:file2blk','%s',ME.message);
        fclose(rfid);
        return;
    end

    fclose(rfid);
end

switch fileName(end-2:end)
    case {'rtf'}
        try
            content = compressRTFData(content);
            format = 'RTF_ZIP';
        catch me
            if strcmp(me.identifier,'docblock:foundascii')
                setContent(blk,content,'RTF');
                format = 'RTF';
            else
                rethrow(me);
            end
        end
    case {'tml','htm'}
        format = 'HTML';
    otherwise
        format = 'TXT';
end
setContent(blkName,content,format);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function closeEditorFile(fileName)


try
    editorDoc = editorservices.find(fileName);
    if ~isempty(editorDoc)
        editorDoc.closeNoPrompt;
    end
    
catch ME
    warning('docblock:closeDocument',ME.message);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function saveDirtyEditorFile(fileName)
%SAVEDIRTYEDITORFILE(FILENAME)

try
    editorDoc = editorservices.find(fileName);
    if ~isempty(editorDoc)
        editorDoc.save;
    end
    
catch ME
    warning('docblock:saveDirtyEditorFile','%s',ME.message);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function convert_legacy(mdlName) %#ok called from command line, obsolete
%Convert classic docblocks to new-style
%Utility function - not called by the block

if nargin<1
    mdlName = bdroot(gcb);
end

sysList = find_system(mdlName, 'LookUnderMasks', 'all', ...
                      'Variants', 'AllVariants', ...
                      'BlockType', 'SubSystem');

% from the subsystem list, find the subsystems that have a pspec_txt field
% associated with it. If present, determine if a save operation is needed.
for i=1:length(sysList)
    s = get_param(sysList{i},'RTWDATA');
    if isfield(s,'document_text')
		%@BUG: DO THIS RIGHT!
		convert_legacy_block(sysList{i});
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function convert_legacy_block(blkName)

if nargin<1
	blkName = gcb;
end

try
	oldECoderFlag = get_param(blkName,'ECoderFlag');
catch ME %#ok
	oldECoderFlag = '';
end

try
	oldDocumentType = get_param(blkName,'DocumentType');
catch ME %#ok
	oldDocumentType = 'Text';
end

set_param(blkName,...
	'MaskType','DocBlock',...
	'ShowName','off',...
	'CopyFcn','',...
	'OpenFcn','docblock(''edit_document'',gcb);',...
	'PreSaveFcn','docblock(''save_document'',gcb);',...
	'DeleteFcn','docblock(''close_document'',gcb);',...
	'CopyFcn','docblock(''copy_document'',gcb);',...
    'UserDataPersistent','on',...
	'MaskDescription','Use this block to save long descriptive text with the model.  Double-clicking the block will open an editor.',...
	'MaskPromptString','RTW Embedded Coder Flag|Editor Type',...
	'MaskStyleString','edit,popup(Text|RTF|HTML)',...
	'MaskTunableValueString','off,on',...
	'MaskEnableString','on,on',...
	'MaskVisibilityString','on,on',...
	'MaskToolTipString','on,on',...
	'MaskValueString','|Text',...
	'MaskVariables','ECoderFlag=@1;DocumentType=&2;',...
	'MaskDisplay','plot([.8 0 0 1 1 .8 .8 1],[1 1 0 0 .8 1 .8 .8]);text(.5,.6,''DOC'',''horizontalalignment'',''center'');text(.95,.05,get_param(gcb,''DocumentType''),''verticalalignment'',''bottom'',''horizontalalignment'',''right'');',...
	'MaskIconFrame','off',...
	'MaskIconOpaque','on',...
	'MaskIconRotate','none',...
	'MaskIconUnits','autoscale');

set_param(blkName,'ECoderFlag',oldECoderFlag);
set_param(blkName,'DocumentType',oldDocumentType);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function blkName = addToSystem(sysName)

if nargin<1
	sysName = gcs;
end

if isempty(sysName)
	sysName = new_system;
	open_system(sysName);
	sysName = get_param(sysName,'name');
end

libName = 'simulink';
libH = find_system(0,...
	'searchdepth',1,...
	'type','block_diagram',...
	'blockdiagramtype','library',...
	'Name','simulink');
if isempty(libH)
	load_system(libName);
end

dBlk = find_system(libName,...
	'MaskType','DocBlock');

if isempty(dBlk)
	blkName = '';
	warning('docblock:noDocBlock','Could not find Doc block - not added');
	return;
else
	dv = datevec(now);
	blkName = sprintf('%s/DocBlock-%0.4i-%0.2i-%0.2i:%0.2i-%0.2i-%0.2f',...
		sysName,...
		dv(1),dv(2),dv(3),dv(4),dv(5),dv(6));
	add_block(dBlk{1},blkName);
end

if isempty(libH)
	close_system(libH);
end
set_param(0,'CurrentSystem',sysName);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function wasDirtySet = setDirty(blkHandle,dlgPrompt)
%Note that this function is called from a java EditorFileListener with no
%second argument.

try
    %If the DocBlock is in a linked SubSystem, we want to set the
    %reference library dirty and display the locked library
    %warning dialog.
    blkParent = get_param(blkHandle,'Parent');
    if ~strcmp(get_param(blkParent,'Type'),'block_diagram')
        parentLinkStatus = get_param(blkParent,'LinkStatus');
        % {'none'  'resolved'  'unresolved'  'implicit'}
        %"restore" and "propagate" are write-only actions for LinkStatus
        %"none","inactive", and "unresolved" will have an empty ReferenceBlock
        if any(strcmp({
                'resolved'
                'implicit'
                },parentLinkStatus))
            blkHandle = get_param(blkParent,'ReferenceBlock');
            %Switch the block handle to be the reference block, so
            %the root of the block is the library block_diagram
        end
    end
catch ME
    warning('docblock:InvalidHandle','%s',ME.message);
    return;
end


try
    rootSys = bdroot(blkHandle);
catch ME
    warning('docblock:InvalidHandle','%s',ME.message);
    return;
end

try
    set_param(rootSys,'dirty','on');
    wasDirtySet = true;
catch ME1 %#ok
    wasDirtySet = false;

    if nargin<2
        dlgPrompt = 'Attempt to modify locked library "%s".';
    end

    optUnlock = 'Unlock';
    optCancel = 'Ignore';
    optSelected = questdlg(sprintf(dlgPrompt,rootSys),...
        'Read-Only DocBlock',...
        optUnlock,optCancel,optCancel);
    switch optSelected
        case optUnlock
            try
                set_param(rootSys,'lock','off');
                set_param(rootSys,'dirty','on');
                wasDirtySet = true;
            catch ME2
                warndlg(sprintf('Unable to unlock block diagram.\n\n(%s)',ME2.message),...
                    'Read-Only DocBlock',...
                    'modal');
            end
        %case optIgnore
        %Idea: Use fileattrib to make the file read-only?
        otherwise %optCancel
            %Noop, for now.
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [content,format] = getContent(blkName)
% need save as hooks?

try
    %
    % read from the file if the file is updated.
    % 
    mdlFileName = get_param(bdroot(blkName), 'FileName');
    docblockFileName = getBlockFileName(blkName);    
    if exist(docblockFileName, 'file') == 2
        if ~(exist(mdlFileName, 'file') == 2)
            % if model is new and has not been saved.
            file2blk(blkName, docblockFileName);
        else            
            d = dir(mdlFileName);
            mdlFileTime = d.datenum;
            d = dir(docblockFileName);
            if mdlFileTime < d.datenum
                file2blk(blkName, docblockFileName);
            end        
        end    
    end
    
    docBlockUserData = get_param(blkName,'UserData');
    
    if ~isstruct(docBlockUserData)
        % If we have characters outside ASCII, then we may have to convert
        % to unicode.  Note.  When we add pictures in RTF, binary data are
        % escaped to their HEX value.
        startExtendedASCII = 128;
        endExtendedASCII = 255;
        if ~isempty(find(docBlockUserData>startExtendedASCII & ...
                         docBlockUserData<endExtendedASCII,1))
            % User defined encoding
            encoding = get_param(0,'CharacterEncoding'); % best guess
            
            % Convert string to UTF16
            content = native2unicode(double(docBlockUserData), encoding);
        else
            % UTF16 encoding
            content = docBlockUserData;
        end
        format = 'UNDEF';
    else
        % UTF16 encoding
        content = docBlockUserData.content;
        if ~isfield(docBlockUserData,'format')
            format = 'UNDEF';
        else
            format = docBlockUserData.format;
        end
    end
    
    % force content to be always 1xN character array
    content = reshape(content,1,[]);
    
    if strcmpi(format,'UNDEF')
        if ~isempty(findstr(content(1:min(128,length(content))),'{\rtf'))
            format = 'RTF';
        end
    end
    
catch ME
    content = ME.message;
    format  = 'UNDEF';
    warning('docblock:getContent','%s',ME.message);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function setContent(blkName,content,format)

docblockVersion = 1.2;

try
    % Save it is a structure.  Also save version info
    docBlockUserData.version = docblockVersion;
    docBlockUserData.content = content;
    docBlockUserData.format  = format;

    %If writing to a locked model, this will cause an error
    set_param(blkName,...
        'RTWdata',[],...                %provided to clear out legacy docblocks
        'UserDataPersistent','on',...
        'UserData',docBlockUserData);
catch ME
%    Don't make this block with an interactive dialog.  We don't want to
%    interrupt the "save" process with dozens (hundreds?) of warning
%    dialogs.
%    warndlg(sprintf('Unable to save DocBlock changes to model.\n\n(%s)',lasterr),...
%        'DocBlock Save Error');
    warning('docblock:SetParam','%s',ME.message);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function compData = compressRTFData(data)
% Compress RTF contents only (ASCII data required)

if any(data>255)
    error('docblock:foundascii','Found non-ascii characters');
end

hOutStream         = java.io.ByteArrayOutputStream();
hDeflaterOutStream = java.util.zip.DeflaterOutputStream(hOutStream);
hDeflaterOutStream.write(uint8(data)); % RTF data = ASCII only
hDeflaterOutStream.close;
compData = typecast(hOutStream.toByteArray,'uint8');
hOutStream.close;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data = uncompressRTFData(compData)
% Uncompress RTF contents
hInStream         = java.io.ByteArrayInputStream(compData);
hInflaterInStream = java.util.zip.InflaterInputStream(hInStream);
hOutStream        = java.io.ByteArrayOutputStream();

import com.mathworks.mlwidgets.io.InterruptibleStreamCopier
isc = InterruptibleStreamCopier.getInterruptibleStreamCopier;
isc.copyStream(hInflaterInStream,hOutStream);
data = char(uint8(hOutStream.toByteArray))'; % RTF data = ASCII only
hOutStream.close;

