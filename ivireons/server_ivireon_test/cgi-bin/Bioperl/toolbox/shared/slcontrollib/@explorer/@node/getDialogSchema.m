function ScrollPanel = getDialogSchema(this, manager)
% GETDIALOGSCHEMA Constructs the default dialog panel

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2010 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2010/03/22 04:19:51 $

DialogPanel = com.mathworks.mwswing.MJPanel;
Button      = com.mathworks.mwswing.MJButton( 'Hello World!' );
ScrollPanel = com.mathworks.mwswing.MJScrollPane( DialogPanel );
DialogPanel.add( Button );

this.Handles.Button = Button;
set( handle(Button, 'callbackproperties'), 'ActionPerformedCallback', { @LocalUpdate, this } );

% --------------------------------------------------------------------------- %
function LocalUpdate(~, ~, ~)
disp('Hello There!')
