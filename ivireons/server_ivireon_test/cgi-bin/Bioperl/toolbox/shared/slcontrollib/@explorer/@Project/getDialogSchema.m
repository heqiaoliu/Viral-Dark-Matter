function DialogPanel = getDialogSchema(this, manager)
% GETDIALOGSCHEMA  Construct the dialog panel

% Author(s): John Glass
% Revised:
% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2007/02/06 20:00:15 $

% First create the GUI panel
DialogPanel = awtcreate( 'com.mathworks.toolbox.control.project.ProjectPanel' );

% Get the handles to the important java components and set their action
% performed callbacks.  Also set their initial data.
TitleTextFieldUDD = DialogPanel.getTitleTextField;
awtinvoke( TitleTextFieldUDD, 'setText(Ljava/lang/String;)', this.Label );
h = handle( TitleTextFieldUDD, 'callbackproperties' );
h.ActionPerformedCallback = { @TitleTextFieldUpdate, this };
h.FocusLostCallback       = { @TitleTextFieldUpdate, this };

SubjectTextFieldUDD = DialogPanel.getSubjectTextField;
awtinvoke( SubjectTextFieldUDD, 'setText(Ljava/lang/String;)', this.Subject );
h = handle( SubjectTextFieldUDD, 'callbackproperties' );
h.ActionPerformedCallback = { @SubjectTextFieldUpdate, this };
h.FocusLostCallback       = { @SubjectTextFieldUpdate, this };

CreatedByTextFieldUDD = DialogPanel.getCreatedByTextField;
awtinvoke( CreatedByTextFieldUDD, 'setText(Ljava/lang/String;)', this.CreatedBy );
h = handle( CreatedByTextFieldUDD, 'callbackproperties' );
h.ActionPerformedCallback = { @CreatedByTextFieldUpdate, this };
h.FocusLostCallback       = { @CreatedByTextFieldUpdate, this };

DateModifiedFieldUDD = DialogPanel.getDateModifiedField;
awtinvoke( DateModifiedFieldUDD, 'setText(Ljava/lang/String;)', this.DateModified );

SimulinkModelTextFieldUDD = DialogPanel.getSimulinkModelTextField;
awtinvoke( SimulinkModelTextFieldUDD, 'setText(Ljava/lang/String;)', this.Model );

NotesTextAreaUDD = DialogPanel.getNotesTextArea;
awtinvoke( NotesTextAreaUDD, 'setText(Ljava/lang/String;)', this.Notes );
h = handle( NotesTextAreaUDD, 'callbackproperties' );
h.FocusLostCallback = { @NotesTextAreaUpdate, this };

L = [ handle.listener( this, findprop(this, 'Label'), ...
                       'PropertyPostSet', { @LocalUpdateTitle, this } ) ];
this.NodePropertyListeners = L;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Local Functions
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalUpdateTitle(es,ed,this)
TitleTextFieldUDD = this.Dialog.getTitleTextField;
awtinvoke( TitleTextFieldUDD, 'setText(Ljava/lang/String;)', this.Label );

function SubjectTextFieldUpdate(es,ed,this)
this.Subject = char(ed.getSource.getText);

function CreatedByTextFieldUpdate(es,ed,this)
this.CreatedBy = char(ed.getSource.getText);

function TitleTextFieldUpdate(es,ed,this)
this.Label = char(ed.getSource.getText);

% Update the title field in case Label change hasn't been accepted.
if ~strcmp(ed.getSource.getText, this.Label)
  awtinvoke( ed.getSource, 'setText(Ljava/lang/String;)', this.Label );
end

function NotesTextAreaUpdate(es,ed,this)
this.Notes = char(ed.getSource.getText);
