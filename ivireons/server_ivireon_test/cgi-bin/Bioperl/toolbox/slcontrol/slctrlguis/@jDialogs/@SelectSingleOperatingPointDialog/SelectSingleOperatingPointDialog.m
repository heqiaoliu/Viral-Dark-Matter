function this = SelectSingleOperatingPointDialog(frame,opnames)
% Defines properties for @SelectSingleOperatingPointDialog class

%   Authors: John Glass
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.4 $ $Date: 2008/12/04 23:27:59 $

% Construct the object
this = jDialogs.SelectSingleOperatingPointDialog;

% Create the hash table with the dialog strings
keystrcell = {'DialogTitle',xlate('Operating Point Selection');...
              'InstructLabel' xlate('Please select a single operating point to be used for compensator design:');...
              'OK', xlate('OK');...
              'Cancel', xlate('Cancel')};
          
strhash = cell2hashtable(slcontrol.Utilities,keystrcell);

% Build the dialog
this.Handles.Dialog = javaObjectEDT('com.mathworks.toolbox.slcontrol.Dialogs.SelectSingleOperatingPointDialog',frame,opnames,strhash);

% Set the callbacks
h = handle( this.Handles.Dialog.getOKButton, 'callbackproperties');
h.ActionPerformedCallback = {@LocalOKCallback,this};

h = handle( this.Handles.Dialog.getCancelButton, 'callbackproperties');
h.ActionPerformedCallback = {@LocalCancelCallback,this};

h = handle( this.Handles.Dialog,'callbackproperties');
h.WindowClosingCallback = {@LocalCancelCallback,this};

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalOKCallback(es,ed,this)

% Return the selected index
this.SelectedIndex = this.Handles.Dialog.getSelectionCombo.getSelectedIndex + 1;
javaMethodEDT('dispose',this.Handles.Dialog);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalCancelCallback(es,ed,this)

% Return the selected index
this.SelectedIndex = [];
javaMethodEDT('dispose',this.Handles.Dialog);