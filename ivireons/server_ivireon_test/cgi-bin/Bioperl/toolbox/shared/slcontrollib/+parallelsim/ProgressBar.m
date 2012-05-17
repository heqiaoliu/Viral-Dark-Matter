classdef ProgressBar < handle
% PROGRESSBAR  Singleton progress bar class
%
 
% Author(s): A. Stothert 23-Apr-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2008/05/31 23:25:27 $

%Public properties
properties
   isModal = false;
end

%Private properties
properties(Access = 'private')
   hFrame
   hBar
   hText
end

%Private methods
methods(Access = 'private')
   function this = ProgressBar
      this.build
   end
   function build(this)
      
      %Create widgets
      hFrame = javaObjectEDT('com.mathworks.mwswing.MJFrame',...
         ctrlMsgUtils.message('SLControllib:slcontrol:msgProgressTitle'));
      hFrame.setResizable(false)
      hFrame.setDefaultCloseOperation(com.mathworks.mwswing.MJFrame.DO_NOTHING_ON_CLOSE)
      hBar = javaObjectEDT('com.mathworks.mwswing.MJProgressBar');
      hBar.setIndeterminate(true)
      hText = javaObjectEDT('com.mathworks.mwswing.MJLabel', ...
         ctrlMsgUtils.message('SLControllib:slcontrol:msgProgressStatus'));
      
      %Layout widgets
      gbl = javaObjectEDT('java.awt.GridBagLayout');
      gbc = javaObjectEDT('java.awt.GridBagConstraints');
      cp  = javaObjectEDT(hFrame.getContentPane);
      cp.setLayout(gbl)
      gbc.anchor    = gbc.NORTHWEST;
      gbc.fill      = gbc.NONE;
      gbc.gridheight= 1;
      gbc.gridwidth = 1;
      gbc.gridx     = 0;
      gbc.gridy     = 0;
      gbc.insets    = javaObjectEDT('java.awt.Insets',5,5,5,5);
      gbc.weightx   = 1;
      gbc.weighty   = 0;
      cp.add(hText,gbc)
      gbc.fill      = gbc.BOTH;
      gbc.gridy     = 1;
      gbc.weighty   = 1;
      cp.add(hBar,gbc)
      hFrame.setBounds(650,460,300,90)
         
      %Store widget handles
      this.hFrame = hFrame;
      this.hBar   = hBar;
      this.hText  = hText;
   end
end

%Static public methods
methods(Static = true) 
   function inst = getInstance
      persistent theInstance
      if isempty(theInstance)
         theInstance = parallelsim.ProgressBar;
      end
      inst = theInstance;
   end
end

%Public methods
methods
   function hFrame = getFrame(this)
      %GETFRAME return the java frame of the progress bar dialog
      %
      % hFrame = this.getFrame;
      %
      % Outputs:
      %   hFrame - a MJFrame object
      %
      hFrame = this.hFrame;
   end
   function hBar = getProgressBar(this)
      %GETPROGRESSBAR return the progress bar widget
      %
      % hBar = this.getProgressBar;
      %
      % Outputs:
      %   hBar - a MJProgressBar object
      %
      hBar = this.hBar;
   end
   function show(this)
      %SHOW display the progress window
      %
      % this.show
      %
      % Note:
      %  1) Window can only be closed with this.hide
      %  2) If this.isModal is true the progress window is displayed with
      %  modal on, the window remains modal until this.hide is called
      %
      this.hFrame.setVisible(true)
      if this.isModal
         this.hFrame.setModal(true)
      end
   end
   function hide(this)
      %HIDE hide the progress window
      %
      % this.hide
      %
      this.hFrame.setVisible(false)
      this.hFrame.setModal(false)
   end
   function setStatus(this,status)
      %SETSTATUS sets the status string displayed in the progress window
      %
      % this.setStatus(str)
      %
      % Inputs:
      %   str - a string with the new status to display
      %
      this.hText.setText(status)
   end
   function setTitle(this,title)
      %SETTITLE sets the progress window title
      %
      % this.setTitle(str)
      %
      % Inputs:
      %   str - a string with the new title
      this.hFrame.setTitle(title)
   end
end

end
