function [filename,ext,user_canceled] = imputfile
%IMPUTFILE Save Image dialog box.  
%   [FILENAME, EXT, USER_CANCELED] = IMPUTFILE displays the Save Image
%   dialog box for the user to fill in and returns the full path to the
%   file selected in FILENAME.  Additionally the file extension is returned
%   in EXT.  If the user presses the Cancel button, USER_CANCELED will
%   be TRUE. Otherwise, USER_CANCELED will be FALSE.
%   
%   The Save Image dialog box is modal; it blocks the MATLAB command line
%   until the user responds.
%   
%   See also IMFORMATS, IMTOOL, IMGETFILE, IMSAVE.

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2009/12/02 06:43:29 $

s = javachk('swing');
if ~isempty(s)
    error(s.identifier,s.message)
end

filename      = '';
ext           = '';
user_canceled = false;

persistent file_chooser;

import com.mathworks.mwswing.MJFileChooser;

% Create file chooser if necessary;
need_new_file_chooser = ~isa(file_chooser,'MJFileChooser');
if need_new_file_chooser
    file_chooser = createFileChooser;
end

% Show file chooser
returnVal = file_chooser.showSaveDialog(com.mathworks.mwswing.MJFrame);
if (returnVal == MJFileChooser.APPROVE_OPTION)
    selected_file = file_chooser.getSelectedFile();
    filename = char(javaMethodEDT('getPath',selected_file));
else
    user_canceled = true;
    return;
end

% Get selected file format
file_filter = file_chooser.getFileFilter();
selected_description = javaMethodEDT('getDescription',file_filter);

% get image format descriptions
[format_descriptions format_extensions] = iptui.parseImageFormats;

% Find user selected format
compareFcn = @(in_str) strcmp(in_str,selected_description);
selected_format = cellfun(compareFcn,format_descriptions);

% Return associated file extension
ext_array = format_extensions{selected_format};
ext = ext_array{1};


%----------------------------------------
function file_chooser = createFileChooser
% Parse formats available in IMFORMATS and create filters that include
% writable formats. Use filters to initialize file chooser.

import com.mathworks.toolbox.images.ImformatsFileFilter;

% Create file chooser
file_chooser = javaObjectEDT('com.mathworks.mwswing.MJFileChooser',...
    java.lang.String(pwd));

% Set dialog properties
file_chooser.setDialogType(javax.swing.JFileChooser.SAVE_DIALOG);
file_chooser.setShowOverwriteDialog(true);

% Construct/Set dialog title
file_chooser.setDialogTitle('Save Image');

% Parse formats from IMFORMATS (plus DICOM)
[desc ext read_fcns write_fcns] = iptui.parseImageFormats;
nformats = length(desc);

% Initialize our ImformatsFileFilter class
initializeImformatsFileFilter;

% Add one ChoosableFileFilter for each valid format
excluded_exts = {'bmp','gif','hdf','pcx','pnm','xwd','dcm','rset'};
for i = 1:nformats
    format_is_writable = ~isempty(write_fcns{i});
    format_is_excluded = any(ismember(ext{i},excluded_exts));
    
    % Only add valid formats (java is zero based)
    if format_is_writable && ~format_is_excluded
        file_chooser.addChoosableFileFilter(ImformatsFileFilter(i-1));
    end
end

% Remove the 'accept all files' filter
accept_all_filter = file_chooser.getAcceptAllFileFilter();
file_chooser.removeChoosableFileFilter(accept_all_filter);

% Make the first type the default
valid_filters = file_chooser.getChoosableFileFilters();
file_chooser.setFileFilter(valid_filters(1));

