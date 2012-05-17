classdef FreqScopeCfg < uiscopes.AbstractScopeCfg
%

% Author(s): A. Stothert
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2010/04/11 20:41:09 $

% FREQSCOPECFG configuration object for all frequency domain scopes
%

properties(GetAccess = protected, SetAccess = protected)
   ConfigurationFile = '';
   HiddenTypes       = {};
   MaskType          = '';
   HelpMapFile       = fullfile(docroot,'toolbox','slcontrol','slcontrol.map');
end


methods
   function obj = FreqScopeCfg(MaskType, DlgPos, varargin)
      % FREQSCOPECFG constructor
      %
      
      %Call super class constructor
      obj@uiscopes.AbstractScopeCfg(varargin{:});
      
      %Construct Scope Command Line object for this type of scope
      obj.ScopeCLI = checkpack.checkblkviews.CheckBlockScopeCLI(varargin{:});
      
      %Set Cfg mask type
      obj.MaskType = MaskType;
      
      %Set scope configuration based on mask type
      obj.setConfigurationFile;
      
      %Set position
      obj.Position = DlgPos;
   end
   function appName = getAppName(this)
      
      switch this.MaskType
         case 'Checks_LinearStepResponse'
            appName = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtLinStepApplicationName');
         case 'Checks_Sigma'
            appName = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtSigmaApplicationName');
         case 'Checks_Margins'
            appName = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtMarginsApplicationName');
         case 'Checks_PZMap'
            appName = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtPZMapApplicationName');
         case 'Checks_Nichols'
            appName = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtNicholsApplicationName');
         otherwise
            %Default to bode
            appName = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtBodeApplicationName');
      end
   end
   function cfgFile = getConfigurationFile(this)
      cfgFile = this.ConfigurationFile;
   end
   function helpArgs = getHelpArgs(this, key) %#ok<INUSD,MANU>
      helpArgs = {};
   end
   
   function hiddenTypes = getHiddenTypes(this) %#ok<MANU>
      
      %Hide source, visuals, and tools for now
      %hiddenTypes = {'Sources', 'Visuals', 'Tools'};
      hiddenTypes = {};
   end
   
   function uiInstaller = createGUI(this, uiMgr) %#ok<INUSD>
      
      %Block specific help. Note explicitly create help widget for each
      %case so that topicIDs can be tested for using GrubX
      switch this.MaskType
         case 'Checks_LinearStepResponse'
            mHelp = uimgr.uimenu('BlockHelp', ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:menuLinStepCheckBlkHelp'));
            mHelp.WidgetProperties = {...
               'callback', @(hSrc,hData) scdguihelp('step_response_plot_block','HelpBrowser')};
         case 'Checks_Sigma'
            mHelp = uimgr.uimenu('BlockHelp', ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:menuSigmaCheckBlkHelp'));
            mHelp.WidgetProperties = {...
               'callback', @(hSrc,hData) scdguihelp('max_singular_value_plot_block','HelpBrowser')};
         case 'Checks_Margins'
            mHelp = uimgr.uimenu('BlockHelp', ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:menuMarginsCheckBlkHelp'));
            mHelp.WidgetProperties = {...
               'callback', @(hSrc,hData) scdguihelp('gain_phase_margin_plot_block','HelpBrowser')};
         case 'Checks_PZMap'
            mHelp = uimgr.uimenu('BlockHelp', ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:menuPZMapCheckBlkHelp'));
            mHelp.WidgetProperties = {...
               'callback', @(hSrc,hData) scdguihelp('pole_zero_plot_block','HelpBrowser')};
         case 'Checks_Nichols'
            mHelp = uimgr.uimenu('BlockHelp', ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:menuNicholsCheckBlkHelp'));
            mHelp.WidgetProperties = {...
               'callback', @(hSrc,hData) scdguihelp('nichols_plot_block','HelpBrowser')};
         otherwise
            %Default to bode
            mHelp = uimgr.uimenu('BlockHelp', ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:menuBodeCheckBlkHelp'));
            mHelp.WidgetProperties = {...
               'callback', @(hSrc,hData) scdguihelp('bode_plot_block','HelpBrowser')};
      end
            
      %About help menu
      mAbout = uimgr.uimenu('About', '&About Simulink Control Design');
      mAbout.WidgetProperties = {...
         'callback', @(hSrc, hData) localAbout(hSrc)};
      
      uiInstaller = uimgr.uiinstaller( {...
         mHelp,  'Base/Menus/Help/Application'; ...
         mAbout, 'Base/Menus/Help/About'});
   end
   
   function fcn = getCloseRequestFcn(this,hScope) %#ok<MANU>
      fcn = @(hSrc,hData) localClose(hScope);
   end
   
end % public methods

methods(Access = protected)
   function setConfigurationFile(this)
      %SETCONFIGURATIOBFILE set scope configuration based on block mask
      %type
      %
      
      switch this.MaskType
         case 'Checks_LinearStepResponse';
            cfgFile = fullfile(matlabroot,'toolbox','slcontrol','slctrlguis','@slctrlblkdlgs','linstepscope.cfg');
         case 'Checks_Sigma';
            cfgFile = fullfile(matlabroot,'toolbox','slcontrol','slctrlguis','@slctrlblkdlgs','sigmascope.cfg');
         case 'Checks_Margins';
            cfgFile = fullfile(matlabroot,'toolbox','slcontrol','slctrlguis','@slctrlblkdlgs','marginsscope.cfg');
         case 'Checks_PZMap'
            cfgFile = fullfile(matlabroot,'toolbox','slcontrol','slctrlguis','@slctrlblkdlgs','pzmapscope.cfg');
         case 'Checks_Nichols'
            cfgFile = fullfile(matlabroot,'toolbox','slcontrol','slctrlguis','@slctrlblkdlgs','nicholsscope.cfg');
         otherwise
            %Default to bode
            cfgFile = fullfile(matlabroot,'toolbox','slcontrol','slctrlguis','@slctrlblkdlgs','bodescope.cfg');
      end
      this.ConfigurationFile = cfgFile;
   end
end % protected methods
end

function localAbout(hSrc)
%Helper function to display info about SCD

verstruct = ver('slcontrol');
verstring = sprintf( '%s %s\nCopyright 2004-%s, The MathWorks, Inc.', ...
   verstruct.Name, verstruct.Version, verstruct.Date(end-3:end) );

%Get java handle to figure so we can center msg on figure
hFig = get(get(hSrc,'Parent'),'Parent');
ctrlMsgUtils.SuspendWarnings('MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
frm = get(hFig,'JavaFrame');
if ~isempty(frm)
    frm = javax.swing.SwingUtilities.getWindowAncestor(frm.getAxisComponent);
else
    frm = [];
end

% Thread-safe message dialog.
jObj = javaObjectEDT('com.mathworks.mwswing.MJOptionPane');
javaMethodEDT('showMessageDialog', jObj, frm, verstring,...
   sprintf('About %s', verstruct.Name), ...
   javax.swing.JOptionPane.PLAIN_MESSAGE );
end

function localClose(hScope)
%Helper function to hide the scope, the scope source manager deletes the
%scope when the corresponding Simulink block is deleted

set(hScope.Parent,'Visible','off');
end