function fcns = menus_cbs(hFDA)
%MENUS_CBS  Handles all the callbacks executed by the uimenus and
%           toolbar pushbuttons and togglebuttons.

%   Author(s): R. Losada, P. Pacheco, P. Costa
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.100.4.10 $  $Date: 2007/12/14 15:21:16 $ 


%persistent fcns;
%if isempty(fcns),
% "Export" the handles to all local functions via a structure.
% The caller will get this, and grab the handles they need.
% This will allow callers to gain direct access to local functions.
%

% Using strings because functions are not local, strings are faster.

fcns                   = siggui_cbs(hFDA);
fcns.new_cb            = @new_cb;
fcns.open_cb           = {fcns.method, hFDA, 'load'}; 
fcns.save_cb           = {fcns.method, hFDA, 'save'};
fcns.saveas_cb         = {fcns.method, hFDA, 'saveas'};
% fcns.importfromfile_cb = {fcns.method,hFDA,@importfromfile_cb};
fcns.export_cb         = {fcns.method, hFDA, 'export'};
fcns.print_cb          = {fcns.event, hFDA, 'Print'};
fcns.printprev_cb      = {fcns.event, hFDA, 'PrintPreview'};
fcns.fullviewanalysis_cb = {fcns.event, hFDA, 'FullViewAnalysis'};
fcns.exit_cb          = {@exit_cb, hFDA};
fcns.convertstruct    = {fcns.method, hFDA, 'convert'};
fcns.convert2sos      = {@sos_cb, hFDA};
fcns.reordersos       = {fcns.method, hFDA, 'sos'};
% fcns.filterspecs_cb   = @filterspecs_cb;
% fcns.savecoeffs_cb    = @savecoeffs_cb;
% fcns.savespecs_cb     = @savespecs_cb;
%end

%---------------------------------------------------------------------
function savecoeffs_cb(hcbo,eventStruct)

warning(generatemsgid('GUIWarn'),'savecoeffs_cb not yet implemented');

%---------------------------------------------------------------------
function savespecs_cb(hcbo,eventStruct)

warning(generatemsgid('GUIWarn'),'savespecs_cb not yet implemented');

%---------------------------------------------------------------------
function new_cb(hcbo,eventStruct)
%NEW_CB Callback for the New menu item and pushbutton.

% Launch a completely new tool
fdatool;

% %---------------------------------------------------------------------
% function importfromfile_cb(hFDA)
% % Import a filter from a text-file.
% 
% % Get any optional (plug-in) file formats
% optformat = addplugins('dummyflag', 'fdaregister', 'fdapluginstruct', 'importfile');
% 
% % Default Coefficient file reader
% filterspecs = {'*.fcf; *.txt;','FDATool coefficient file (*.fcf,*.txt)';};
% filereaders{1} = @fcfileread;
% 
% if ~isempty(optformat),
%     for n = 1:length(optformat{:}),
%         filterspecs = vertcat(filterspecs,{optformat{:}(n).filterspec{:}});
%         filereaders = vertcat(filereaders,{optformat{:}(n).fcn});
%     end
% end
% 
% % Call the utility to launch the dialog and call the reader.
% filtobj = importfromtxtfile(filterspecs,filereaders);
% 
% % Update the filter in FDATool.
% if ~isempty(filtobj)
%     opts.source = 'Imported';
%     sendstatus(hFDA,'Importing Filter from file');
%     hFDA.setfilter(filtobj,opts);
% end

%---------------------------------------------------------------------
function sos_cb(hcbo, eventStruct, hFDA)

Hd = sos(getfilter(hFDA));

opts.mcode = 'Hd = sos(Hd);';

hFDA.setfilter(Hd, opts);

%---------------------------------------------------------------------
function exit_cb(hcbo,eventStruct, hFDA)
%EXIT_CB Callback for the Exit menu item or the "X" at top-right corner.

if strcmpi(get(hFDA.FigureHAndle, 'tag'), 'initializing')
    
    % If we are still in the initialization do not close.
    d = dbstack;
    if length(d) == 1
        delete(hFDA.FigureHandle);
    end
else

    flags = getflags(hFDA);

    % If launched from DSPBlks, we need to undo & hide
    if flags.calledby.dspblks
        set(hFDA,'Visible','Off');
    elseif flags.forceclose
        close(hFDA, 'force');
    else
        % Close the GUI
        close(hFDA);
    end
end

% %------------------------------------------------------------------------
% function filtobj = importfromtxtfile(filterspecscell,filereaders)
% % Utility to launch the dialog and call a file reader.
% 
% filtobj = [];
% dlgStr = 'Import Filter From File';
% 
% % Put up the file selection dialog
% [filename, pathname,idx] = lcluigetfile(dlgStr,filterspecscell);
% 
% if ~isempty(filename),
%     deffile = [pathname filename];
%     
%     try    
%         filtobj = feval(filereaders{idx},deffile);
%     catch
%         str = filterspecscell{idx,2}; str(end-13:end)=[];
%         msg = ['The file you are attempting to import does not appear to be an ',str '.'];
%         error(generatemsgid('SigErr'),msg);
%     end
% end

% %------------------------------------------------------------------------
% function [filename, pathname,idx] = lcluigetfile(dlgStr,fileformat)
% % Local UIGETFILE: Return an empty string for the "Cancel" case
% 
% [filename, pathname,idx] = uigetfile(fileformat,dlgStr);
% 
% % filename is 0 if "Cancel" was clicked
% if filename == 0, filename = ''; end


% [EOF] menus_cbs.m
