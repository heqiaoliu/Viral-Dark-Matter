function [filename,user_canceled] = imgetfile
%IMGETFILE Open Image dialog box.  
%   [FILENAME, USER_CANCELED] = IMGETFILE displays the Open Image dialog
%   box for the user to fill in and returns the full path to the file
%   selected in FILENAME. If the user presses the Cancel button,
%   USER_CANCELED will be TRUE. Otherwise, USER_CANCELED will be FALSE.
%   
%   The Open Image dialog box is modal; it blocks the MATLAB command line
%   until the user responds. The file types listed in the dialog are all
%   formats listed in IMFORMATS plus DICOM.
%   
%   See also IMFORMATS, IMTOOL, IMPUTFILE, UIGETFILE.

%   Copyright 2003-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.11 $  $Date: 2009/09/28 20:24:33 $
    
s = javachk('swing');
if ~isempty(s)
    error(s.identifier,s.message)
end

filename      = '';
user_canceled = false;

persistent file_chooser;

import com.mathworks.mwswing.MJFileChooser;

% Create file chooser if necessary;
need_new_file_chooser = ~isa(file_chooser,'MJFileChooser');
if need_new_file_chooser
    file_chooser = createFileChooser;
end

fileExistsOnFileSystem = @(filename) exist(filename,'file') == 2; 

while ~(fileExistsOnFileSystem(filename) || user_canceled)
    % Show file chooser
    returnVal = file_chooser.showOpenDialog(com.mathworks.mwswing.MJFrame);
    if (returnVal == MJFileChooser.APPROVE_OPTION)
        selected_file = file_chooser.getSelectedFile();
        filename = char(javaMethodEDT('getPath',selected_file));        
    else
        filename = '';
        user_canceled = true;
    end
end


%----------------------------------------
function file_chooser = createFileChooser
% Parse formats available in IMFORMATS and create filters that include
% these formats plus DICOM. Use filters to initialize file chooser.

import com.mathworks.toolbox.images.ImformatsFileFilter;

% Create file chooser
file_chooser = javaObjectEDT('com.mathworks.mwswing.MJFileChooser',...
    java.lang.String(pwd));

% Set dialog type
file_chooser.setDialogType(javax.swing.JFileChooser.OPEN_DIALOG);

% Set dialog title
file_chooser.setDialogTitle('Open Image');

% get image format descriptions
desc = iptui.parseImageFormats;
nformats = length(desc);

% Initialize our ImformatsFileFilter class
initializeImformatsFileFilter;

% Create all_images_filter
all_images_filter = ...
    ImformatsFileFilter(ImformatsFileFilter.ACCEPT_ALL_IMFORMATS);
file_chooser.addChoosableFileFilter(all_images_filter);

% Add one ChoosableFileFilter for each format
for i = 1:nformats
    % java is zero based
    file_chooser.addChoosableFileFilter(ImformatsFileFilter(i-1));
end

% Put accept all files at end
accept_all_filter = file_chooser.getAcceptAllFileFilter();
file_chooser.removeChoosableFileFilter(accept_all_filter);
file_chooser.addChoosableFileFilter(accept_all_filter);

% Make default be all_images_filter
file_chooser.setFileFilter(all_images_filter);
