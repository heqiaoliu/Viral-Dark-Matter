function buildPanel(this)
%BUILDPANEL  Build the main GUI panel of a tuning method.

%   Author(s): R. Chen
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $  $Date: 2009/04/21 03:07:36 $

import java.awt.*;
import javax.swing.* ;
import javax.swing.border.*;
import java.util.* ;


%% Build Component Panels
% build compensator selection panel
CompSelectPanelHandles = this.buildCompSelectPanel;
% build specification panel
SpecPanelHandles = this.buildSpecPanel;
% put two panels together
Panel = javaObjectEDT('com.mathworks.mwswing.MJPanel',BorderLayout);
Panel.add(CompSelectPanelHandles.Panel,BorderLayout.NORTH);
Panel.add(SpecPanelHandles.Panel,BorderLayout.CENTER);

%% build button panel
MessagePanel = javaObjectEDT('com.mathworks.mwswing.MJPanel',GridBagLayout);
MessagePanel.setName('MessagePanel');

DesignButton = javaObjectEDT('com.mathworks.mwswing.MJButton',sprintf('Update Compensator'));
DesignButton.setName(strcat(this.Name,'_DesignBTN'))

DesignButtonPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel',GridBagLayout);

gbc           = GridBagConstraints;
gbc.anchor    = GridBagConstraints.NORTHWEST;
gbc.fill      = GridBagConstraints.BOTH;
gbc.gridheight= 1;
gbc.gridwidth = 1;
gbc.gridx = 0;
gbc.gridy = 0;
gbc.insets    = Insets(0,5,5,5);
gbc.weightx   = 1;
gbc.weighty   = 1;
DesignButtonPanel.add(MessagePanel,gbc);

gbc.gridx = 1;
gbc.gridy = 0;
gbc.anchor    = GridBagConstraints.NORTHEAST;
gbc.fill      = GridBagConstraints.NONE;
gbc.gridheight= GridBagConstraints.REMAINDER;
gbc.gridwidth = GridBagConstraints.REMAINDER;
gbc.weightx   = 0;
DesignButtonPanel.add(DesignButton,gbc)



% set button callback
h = handle(DesignButton,'callbackproperties');
h.ActionPerformedCallback = {@LocalDesign this};

%% Build Main Panel
MainPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel',BorderLayout);
MainPanel.add(Panel,BorderLayout.CENTER);
MainPanel.add(DesignButtonPanel,BorderLayout.SOUTH);

%% Set Properties
this.CompSelectPanelHandles = CompSelectPanelHandles;
this.SpecPanelHandles = SpecPanelHandles;
this.DesignButton = DesignButton;
this.MainPanel = MainPanel;
this.MessagePanel = MessagePanel;

%% Design Button Callback
function LocalDesign(hsrc, event, this) %#ok<INUSL>
% disable CETM
F=slctrlexplorer;
F.setBlocked(true,[]);
try
    % compute compensator
    C = computeCompensator(this);
    if ~isempty(C)
        try
            % Start transaction
            CurrentValue = this.TunedCompList(this.IdxC).save;
            TransAction = ctrluis.transaction(this.LoopData,'Name',sprintf('Automated Design: %s',xlate(this.Desc)),...
              'OperationStore','on','InverseOperationStore','on','Compression','on');
            % export
            tmp = this.TunedCompList(this.IdxC).save;
            tmp.Value = C;
            this.TunedCompList(this.IdxC).import(tmp);
            % Finish transaction
            this.Parent.Parent.EventManager.record(TransAction);
            % send out event
            this.LoopData.dataevent('all');
        catch ME
            this.TunedCompList(this.IdxC).import(CurrentValue);
            TransAction.Transaction.commit; % commit transaction before deleting wrapper
            delete(TransAction);
            this.utDisplayMessage('error',ltipack.utStripErrorHeader(ME.message));
        end
    end
catch ME
     this.utDisplayMessage('error',ltipack.utStripErrorHeader(ME.message));
end
% enable CETM
F.setBlocked(false,[]);


