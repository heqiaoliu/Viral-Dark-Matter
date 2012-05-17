function schema
% SCHEMA  
% Defines the class of diagnostic viewers based on the Model Explorer.
%
% A Diagnostic Viewer (DV) displays messages in a window based on the Model
% Explorer. It is designed to work with Simulink's nag (error and warning
% message) controller (slsfnagctlr). 
% 
%  Usage:
%
%    dv = DAStudio.DiagView(); % Creates a dv instance.
%    dv.convertNagsToUDD(nags) % Populates dv with nags.
%    dv.Visible = true;        % Makes dv visible.
%    dv.flushMsgs;             % Clears nags from viewer.
%    dv.Visible = false;       % Hides dv.
%
% Copyright 2008 The MathWorks, Inc.
  
  pkg = findpackage('DAStudio');
  cls = schema.class ( pkg, 'DiagViewer');
  
  % Allows multiple instances of the Diagnostic Viewer, each with a
  % unique name to facilitate identification.
  schema.prop(cls, 'Name', 'string');
  
  % Static method for finding a DV instance by name.
  m = schema.method(cls,'findInstance', 'static');
  m.signature.varargin = 'off';
  m.signature.inputTypes={'string'};
  m.signature.outputTypes={'handle'};
  
  % Static method for finding the DV instance whose window currently
  % has the system's input focus. This method is used by menu and 
  % button callbacks to determine the DV instance to which they apply.
  m = schema.method(cls,'findActiveInstance', 'static');
  m.signature.varargin = 'off';
  m.signature.inputTypes={};
  m.signature.outputTypes={'handle'};

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % Create the DV Window.
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  m = schema.method(cls, 'createExplorer');
  m.signature.varargin = 'off';
  m.signature.inputTypes={'handle'};
  m.signature.outputTypes={};
  
  % DAStudio.Explorer object that serves as the
  % Diagnostic Viewer's window.
  schema.prop(cls, 'Explorer', 'handle');
 
  % Text that appears in the title bar of the Diagnostic Viewer's
  % window.
  schema.prop(cls, 'Title', 'string');  
  
  m = schema.method(cls, 'getPosition');
  m.signature.varargin = 'off';
  m.signature.inputTypes = {'handle'};
  m.signature.outputTypes = {'MATLAB array'};
  
  m = schema.method(cls, 'setPosition');
  m.signature.varargin = 'off';
  m.signature.inputTypes = {'handle', 'MATLAB array'};
  m.signature.outputTypes = {};
  
  m = schema.method(cls, 'createExplorer');
  m.signature.varargin = 'off';
  m.signature.inputTypes={'handle'};
  m.signature.outputTypes={};
  
  m = schema.method(cls, 'createNullMsg');
  m.signature.varargin = 'off';
  m.signature.inputTypes={'handle'};
  m.signature.outputTypes={'handle'};
 
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % Configure the DV's message list view
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  m = schema.method(cls, 'getMessageListViewHeight');
  m.signature.varargin = 'off';
  m.signature.inputTypes = {'handle'};
  m.signature.outputTypes = {'int'};
  
  m = schema.method(cls, 'setMessageListViewHeight');
  m.signature.varargin = 'off';
  m.signature.inputTypes = {'handle', 'int'};
  m.signature.outputTypes = {};
  
  % The following methods allow the DV to control its Explorer
  % instances processing of Model Explorer sleep/wake events. See the
  % DV's createExplorer and updateWindow methods for more information.
  m = schema.method(cls, 'ignoreMESleepWakeEvents');
  m.signature.varargin = 'off';
  m.signature.inputTypes = {'handle'};
  m.signature.outputTypes = {};
  
  m = schema.method(cls, 'processMESleepWakeEvents');
  m.signature.varargin = 'off';
  m.signature.inputTypes = {'handle'};
  m.signature.outputTypes = {};
  
  m = schema.method(cls, 'sleepExplorer');
  m.signature.varargin = 'off';
  m.signature.inputTypes = {'handle'};
  m.signature.outputTypes = {};
  
  m = schema.method(cls, 'wakeExplorer');
  m.signature.varargin = 'off';
  m.signature.inputTypes = {'handle'};
  m.signature.outputTypes = {};

  
  % Specifies whether the list view height is initialized.
  % The list view height is initialized the first time the DV
  % is displayed in a session. The user can then change the height
  % without further interference from the DV.
  schema.prop(cls, 'msgListViewHeightInitialized', 'bool');
  

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % Show the DV Window
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % Controls the visibility of the DV. Setting this property
  % to true makes the DV visible; to false, invisible.
  schema.prop(cls,'Visible','bool');
  
  % Listener for changes in the DV's Visible property. Performs
  % the work of making the DV visible or invisible.
  p = schema.prop(cls,'hVisListener','handle');
  p.AccessFlags.PublicSet = 'off';
  p.AccessFlags.PrivateSet = 'on';

  m = schema.method(cls, 'installWindowPostShowListener');
  m.signature.varargin = 'off';
  m.signature.inputTypes = {'handle'};
  m.signature.outputTypes = {};
  
  % Pointer to method that handles a Model Explorer PostShow
  % event. See installWindowPostShowListener.
  p = schema.prop(cls,'hPostShowListener','handle');
  p.AccessFlags.PublicSet = 'off';
  p.AccessFlags.PrivateSet = 'on';
  
  m = schema.method(cls, 'installPropListChangedListener');
  m.signature.varargin = 'off';
  m.signature.inputTypes = {'handle'};
  m.signature.outputTypes = {};
  
  % Pointer to method that handles a Model Explorer PropListChanged
  % event. See installPropListChangedListener.
  p = schema.prop(cls,'hPropListChangedListener','handle');
  p.AccessFlags.PublicSet = 'off';
  p.AccessFlags.PrivateSet = 'on';
  
  m = schema.method(cls, 'updateWindow');
  m.signature.varargin = 'off';
  m.signature.inputTypes={'handle'};
  m.signature.outputTypes={};

  m = schema.method(cls,'isVisible');
  m.signature.varargin = 'off';
  m.signature.inputTypes={'handle'};
  m.signature.outputTypes={'bool'};
  
  m = schema.method(cls,'deleteWindow');
  m.signature.varargin = 'off';
  m.signature.inputTypes={'handle'};
  m.signature.outputTypes = {};

  m = schema.method(cls,'isClosed');
  m.signature.varargin = 'off';
  m.signature.inputTypes={'handle'};
  m.signature.outputTypes={'bool'};

  m = schema.method(cls, 'toFront');
  m.signature.varargin = 'off';
  m.signature.inputTypes={'handle'};
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % Close the DV Window
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  m = schema.method(cls, 'installWindowCloseListener');
  m.signature.varargin = 'off';
  m.signature.inputTypes = {'handle'};
  m.signature.outputTypes = {};
  
  % Pointer to method that handles a Model Explorer
  % PostClosed event. See installWindowCloseListner method.
  p = schema.prop(cls,'hCloseListener','handle');
  p.AccessFlags.PublicSet = 'off';
  p.AccessFlags.PrivateSet = 'on';
  
  % Pointer to method that handles an Explorer ObjectBeingDestroyed
  % event. See installWindowDeleteListener method.
  p = schema.prop(cls,'WindowDeleteListener','handle');
  p.AccessFlags.PublicSet = 'off';
  p.AccessFlags.PrivateSet = 'on';
  
  m = schema.method(cls,'close', 'static');
  m.signature.varargin = 'off';
  m.signature.inputTypes={};
  m.signature.outputTypes={};
  
  
  m = schema.method(cls, 'clickCloseButton');
  m.signature.varargin = 'off';
  m.signature.inputTypes={'handle'};
  m.signature.outputTypes={};
  
  m = schema.method(cls, 'isCloseButtonEnabled');
  m.signature.varargin = 'off';
  m.signature.inputTypes={'handle'};
  m.signature.outputTypes={'bool'};

  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                                                                    
  % Add nags to the Diagnostic Viewer                                        
  %                                                                    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  
  m = schema.method(cls, 'convertNagsToUDDObject');
  m.signature.varargin = 'off';
  m.signature.inputTypes = {'handle', 'MATLAB array'};
  m.signature.outputTypes = {};
  
  m = schema.method(cls, 'convertNagToUDDObject');
  m.signature.varargin = 'off';
  m.signature.inputTypes = {'handle', 'MATLAB array'};
  m.signature.outputTypes = {};
  
  m = schema.method(cls,'sortMessagesByType');
  m.signature.varargin = 'off';
  m.signature.inputTypes={'handle'};
  
  m = schema.method(cls, 'getMsg');
  m.signature.varargin = 'off';
  m.signature.inputTypes={'handle', 'int'};
  
  % Array of messages displayed by the Diagnostic Viewer.
  % Messages are instances of DAStudio.DiagMsg class.
  % This property is set by the DV's convertNagsToUDDObject
  % method, which is invoked by slsfnagctlr.
  schema.prop(cls,'Messages','handle vector');
  
  % Empty message to display when h.Messages is empty.
  schema.prop(cls,'NullMessage','handle');
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % Remove nags from the DV.
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % Remove all nags.
  m = schema.method(cls, 'flushMsgs');
  m.signature.varargin = 'off';
  m.signature.inputTypes={'handle'};
  
  % Remove specified nag.
  m = schema.method(cls, 'popDiagnosticMsg');
  m.signature.varargin = 'off';
  m.signature.inputTypes={'handle', 'MATLAB array'};

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % Select Messages
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
  m = schema.method(cls, 'installMsgSelectionListener');
  m.signature.varargin = 'off';
  m.signature.inputTypes = {'handle'};
  m.signature.outputTypes = {};
  
  m = schema.method(cls, 'selectDiagnosticMsg');
  m.signature.varargin = 'off';
  m.signature.inputTypes={'handle', 'handle'};

  p = schema.prop(cls, 'selectedMsg', 'handle');
  p.AccessFlags.PublicSet = 'on';
  p.AccessFlags.PrivateSet = 'off';
    
  p = schema.prop(cls,'MsgSelectionListener', 'handle');
  p.AccessFlags.PublicSet = 'off';
  p.AccessFlags.PrivateSet = 'on';
    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % Open Messages
  %
  % Methods and properties for opening a message. Opening is an action
  % defined by the message itself, e.g., open a dialog that can be used to
  % fix an error. The default open action is to highlight and select the
  % the object associated with the message.
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % Executes the open action defined by the currently selected message.
  % This method is invoked by the message object's exploreAction method,
  % which is invoked in turn by the Model Explorer when a user double
  % clicks the node in the list view corresponding to the message.
  m = schema.method(cls, 'openMessage');
  m.signature.varargin = 'off';
  m.signature.inputTypes = {'handle', 'handle'};
  m.signature.outputTypes = {};
  
  % Executes the open action defined by the currently selected message.
  % This method is invoked by the callback for the DV's Open button.
  m = schema.method(cls, 'openSelectedMsg', 'static');
  m.signature.varargin = 'off';
  m.signature.inputTypes = {};
  m.signature.outputTypes = {};
  
  % Index of the currently open message.
  schema.prop(cls,'rowOpen','int');
  
  % Allows tests to determine whether an open message
  % button click succeeded.
  schema.prop(cls,'isMessageOpen','bool');
  
  m = schema.method(cls, 'clickOpenButton');
  m.signature.varargin = 'off';
  m.signature.inputTypes={'handle'};
  m.signature.outputTypes={};
  
  m = schema.method(cls, 'isOpenButtonEnabled');
  m.signature.varargin = 'off';
  m.signature.inputTypes={'handle'};
  m.signature.outputTypes={'bool'};

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % Highlight Blocks
  %
  % The following methods and properties handle highlighing and
  % dehighlighting of blocks associated with the message currently 
  % selected in the DV's window.
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % Highlights blocks associated with the current message. Invoked by
  % the DV's message selection change handler (see 
  % installMsgSelectionListener).
  m = schema.method(cls,'hiliteBlocks');
  m.signature.varargin = 'off';
  m.signature.inputTypes={'handle', 'NReals'};
  
  % Removes highlights from previously highlit blocks. Invoked by
  % the DV's message selection change handler (see 
  % installMsgSelectionListener).
  m = schema.method(cls,'dehilitBlocks');
  m.signature.varargin = 'off';
  m.signature.inputTypes={'handle'};
  
  % Removes highlights from the ancestors of the model associated with
  % the current message. Invoked when the Diagnostic Viewer is rendered
  % invisible (see dv.installVisibleListener).
  m = schema.method(cls,'dehilitModelAncestors');
  m.signature.varargin = 'off';
  m.signature.inputTypes={'handle'};
  
    % Model associated with this Diagnostic Viewer
  % Used by dehilitModelAncestors.
  p = schema.prop(cls,'modelH','NReals');
  p.AccessFlags.PublicSet = 'on';
  p.AccessFlags.PrivateSet = 'on';
  
  % dv.hiliteBlocks method uses this property to records blocks that
  % it has highlighted. This allows dv.dehilitBlocks to know which
  % blocks to dehighlight.
  p = schema.prop(cls,'prevHilitObjs', 'NReals');
  p.AccessFlags.PublicSet = 'on';
  p.AccessFlags.PrivateSet = 'off';
  
  % Used by dv.hiliteBlocks and dv.dehiliteBlocks to remember which
  % colors were used to highlight blocks.
  p = schema.prop(cls,'prevHilitClrs','string vector');
  p.AccessFlags.PublicSet = 'on';
  p.AccessFlags.PrivateSet = 'off';
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % Jump to Error Sources
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  m = schema.method(cls, 'hypergate');
  m.signature.varargin = 'off';
  m.signature.inputTypes={'handle'};
  
  m = schema.method(cls, 'hyperlink');
  m.signature.varargin = 'on';
  m.signature.inputTypes={'handle', 'string'};
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % Show and Hide Message List View Columns
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % Stores names of the message properties currently displayed
  % in the message list at the top of the Diagnostic Viewer.
  p = schema.prop(cls,'msgListProps','string vector');
  p.AccessFlags.PublicSet = 'on';
  p.AccessFlags.PrivateSet = 'on';
  
  % Stores names of message properties in the order they are to be
  % displayed in the list view.
  p = schema.prop(cls,'msgListPropsOrder','string vector');
  p.AccessFlags.PublicSet = 'on';
  p.AccessFlags.PrivateSet = 'on';
  
  % Associate a property show action with the property's name.
  p = schema.prop(cls, 'propShowActions', 'MATLAB array');
  p.AccessFlags.PublicSet = 'on';
  p.AccessFlags.PrivateSet = 'on';
  
  % Returns the show action associated with a property.
  m = schema.method(cls, 'getPropShowAction');
  m.signature.varargin = 'off';
  m.signature.inputTypes={'handle', 'string'};
  m.signature.outputTypes={'handle'};

  % Message column

  p = schema.prop(cls,'showMessageAction','handle');
  p.AccessFlags.PublicSet = 'off';
  p.AccessFlags.PrivateSet = 'on';

  m = schema.method(cls, 'showMessage');
  m.signature.varargin = 'off';
  m.signature.inputTypes={'handle', 'bool'};

  m = schema.method(cls, 'isMessageVisible');
  m.signature.varargin = 'off';
  m.signature.inputTypes={'handle'};
  m.signature.outputTypes={'bool'};


  % Source column

  p = schema.prop(cls,'showSourceAction','handle');
  p.AccessFlags.PublicSet = 'off';
  p.AccessFlags.PrivateSet = 'on';

  m = schema.method(cls, 'showSource');
  m.signature.varargin = 'off';
  m.signature.inputTypes={'handle', 'bool'};

  m = schema.method(cls, 'isSourceVisible');
  m.signature.varargin = 'off';
  m.signature.inputTypes={'handle'};
  m.signature.outputTypes={'bool'};

  % Reported

  p = schema.prop(cls,'showReportedAction','handle');
  p.AccessFlags.PublicSet = 'off';
  p.AccessFlags.PrivateSet = 'on';

  m = schema.method(cls, 'showReported');
  m.signature.varargin = 'off';
  m.signature.inputTypes={'handle', 'bool'};

  m = schema.method(cls, 'isReportedVisible');
  m.signature.varargin = 'off';
  m.signature.inputTypes={'handle'};
  m.signature.outputTypes={'bool'};

  % Summary column

  p = schema.prop(cls,'showSummaryAction','handle');
  p.AccessFlags.PublicSet = 'off';
  p.AccessFlags.PrivateSet = 'on';

  m = schema.method(cls, 'showSummary');
  m.signature.varargin = 'off';
  m.signature.inputTypes={'handle', 'bool'};

  m = schema.method(cls, 'isSummaryVisible');
  m.signature.varargin = 'off';
  m.signature.inputTypes={'handle'};
  m.signature.outputTypes={'bool'};


  m = schema.method(cls, 'updateListView', 'static');
  m.signature.varargin = 'off';
  m.signature.inputTypes={};
  m.signature.outputTypes={};
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % Get Help
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  m = schema.method(cls,'showHelp', 'static');
  m.signature.varargin = 'off';
  m.signature.inputTypes={};
  m.signature.outputTypes={};
  
  m = schema.method(cls, 'clickHelpButton');
  m.signature.varargin = 'off';
  m.signature.inputTypes={'handle'};
  m.signature.outputTypes={};
  
  m = schema.method(cls, 'isHelpButtonEnabled');
  m.signature.varargin = 'off';
  m.signature.inputTypes={'handle'};
  m.signature.outputTypes={'bool'};
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % Delete this Diagnostic Viewer instance.
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
  m = schema.method(cls, 'destroy');
  m.signature.varargin = 'off';
  m.signature.inputTypes={'handle'};
  m.signature.outputTypes={};


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % Methods used to test the Diagnostic Viewer.
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  
  m = schema.method(cls, 'getGUIFullPathText');
  m.signature.varargin = 'off';
  m.signature.inputTypes={'handle'};
  m.signature.outputTypes={'string'};
  
  m = schema.method(cls, 'getMessageListViewText');
  m.signature.varargin = 'off';
  m.signature.inputTypes={'handle'};
  m.signature.outputTypes={'MATLAB array'};
  
  m = schema.method(cls, 'selectMessageListViewRow');
  m.signature.varargin = 'off';
  m.signature.inputTypes={'handle', 'int'};
  m.signature.outputTypes={};
  
  m = schema.method(cls, 'getMessageBrowserText');
  m.signature.varargin = 'off';
  m.signature.inputTypes={'handle'};
  m.signature.outputTypes={'string'};


end





