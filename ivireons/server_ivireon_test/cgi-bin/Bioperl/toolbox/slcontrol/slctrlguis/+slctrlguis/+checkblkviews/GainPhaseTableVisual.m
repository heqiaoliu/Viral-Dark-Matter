classdef GainPhaseTableVisual < handle
   % GAINPHASETABLEVISUAL class for displaying gain and phase margin
   % information in a tabular format on the CheckMarginsDlg visual
   %
   
   % Author(s): A. Stothert 22-Mar-2010
   % Copyright 2010 The MathWorks, Inc.
   % $Revision: 1.1.8.3 $ $Date: 2010/05/10 17:57:43 $
   
   properties
      %JAVACOMPONENT handle to the java panel
      JavaComponent
      
      %TXTAREA handle to the html text widget contained in the java component
      txtArea
      
      %DATA array of LTI objects whose Gain & Phase Margin data is displayed
      Data
      
      %VISUAL handle to the visual component this display is a part of
      hVis
   end
   
   methods
      function obj = GainPhaseTableVisual(hVis,hParent)
         %Constructor
         
         %Set properties
         obj.hVis = hVis;
         
         %Construct the display widgets
         obj.build(hParent);
         
         %Update the display
         obj.refresh;
      end
      function reset(this)
         %RESET clear the displayed information
         
         this.Data = [];
         this.refresh;
      end
      function update(this,sys,t)
         %UPDATE update the displayed information with data from a new
         %system
         
         if isempty(this.Data)
            this.Data = struct('System',sys,'time',t);
         else
            this.Data = vertcat(this.Data, ...
               struct('System',sys,'time',t));
         end
         this.refresh
      end
   end% public methods
   
   methods(Access = 'private')
      function build(this,hParent)
         %Construct the widgets for the display
         DescPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel');
         Info = javaObjectEDT('com.mathworks.toolbox.control.explorer.HTMLStatusArea');
         DescPanel.setLayout(javaObjectEDT('java.awt.BorderLayout',10,10));
         DescPanel.add(Info,java.awt.BorderLayout.CENTER);
         
         [~, jComp] = javacomponent(DescPanel,[.1,.1,.9,.9],hParent);
         set(jComp,'units','normalized')
         set(jComp,'position',[0.025 0.025 0.95 0.95])
         
         this.JavaComponent = jComp;
         this.txtArea       = Info;
         this.Data          = [];
      end
      function refresh(this)
         %REFRESH Redraw the displayed gain and phase margin information
         
         %Get the GPM bounds defined in the block... Would prefer using 
         %application data source but it may not yet be defined so use
         %scope constructor arguments
         hBlk = this.hVis.Application.ScopeCfg.ScopeCLI.Args{1}{2}; 
         hReqs = getbounds(getFullName(hBlk));
         hReq = [hReqs{:}];
         if isempty(hReq)
            %No requirements defined, set bound values as if everything is
            %valid
            gpmType = 'none';
            GM      = -inf;
            PM      = -inf;  
         else
            gpmType = hReq.getData('type');
            GM = hReq.getData('ydata');
            PM = hReq.getData('xdata');
         end
         DisplayUnits = struct(...
            'Gain',      hBlk.MagnitudeUnits, ...
            'Phase',     hBlk.PhaseUnits, ...
            'Frequency', hBlk.FrequencyUnits);
                  
         %Add display for any GPM requirements
         strData = '<BODY style="font-family:Sans Serif; font-size:11">';
         
         %Add instruction to run simulation if don't have any data
         if isempty(this.Data)
            strData = strcat(strData,ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtMarginsTableRunSim'));
         end
         
         %Create table to display computed GPM
         strData = strcat(strData,'<table border="1" align="center" width="100%">');
         %Create table header row
         bgcolor = sprintf('%x',255*get(get(this.JavaComponent,'Parent'),'BackgroundColor'));
         strData = sprintf('%s<tr>',strData);
         strData = sprintf('%s<td rowspan="2" bgcolor="#%s">%s</td>',...
            strData,bgcolor,ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtMarginsTableLinTime'));
         strData = sprintf('%s<td align="center" colspan="2" bgcolor="#%s">%s</td>',...
            strData,bgcolor,ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtMarginsTableGM'));
         strData = sprintf('%s<td align="center" colspan="2" bgcolor="#%s">%s</td>',...
            strData,bgcolor,ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtMarginsTablePM'));
         strData = strcat(strData,'</tr>');
         strData = sprintf('%s<tr>',strData);
         strData = sprintf('%s<td align="center" bgcolor="#%s">%s</td>',...
            strData,bgcolor,sprintf('%s (%s)',ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtMarginsTableGM'),DisplayUnits.Gain));
         strData = sprintf('%s<td align="center" bgcolor="#%s">%s</td>',...
            strData,bgcolor,ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtMarginsTableGMCrossover',DisplayUnits.Frequency));
         strData = sprintf('%s<td align="center" bgcolor="#%s">%s</td>',...
            strData,bgcolor,sprintf('%s (%s)',ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtMarginsTablePM'),DisplayUnits.Phase));
         strData = sprintf('%s<td align="center" bgcolor="#%s">%s</td>',...
            strData,bgcolor,ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtMarginsTablePMCrossover',DisplayUnits.Frequency));
         strData = strcat(strData,'</tr>');
         %Populate table
         if isempty(this.Data)
            strData = strcat(strData,'<tr bgcolor="white"><td></td><td></td><td></td><td></td><td></td></tr>');
         else
            %Create row for each linear system
            for ct = 1:numel(this.Data)
               sys = this.Data(ct).System;
               if strcmp(hBlk.FeedbackSign,'+1')
                  %allmargin assumes -ve feedback, so switch loop sign.
                  sys = -1*sys;
               end
               s = allmargin(sys);
               
               strData = strcat(strData,'<tr>');
               
               if isempty(s.GMFrequency)
                  gmStr  = '--';
                  gmfStr = '--';
               else
                  gmStr  = localMat2Str(unitconv(s.GainMargin,'abs',DisplayUnits.Gain),GM,s.Stable);
                  gmfStr = localMat2Str(unitconv(s.GMFrequency,'rad/s',DisplayUnits.Frequency));
               end
               if isempty(s.PMFrequency)
                  pmStr  = '--';
                  pmfStr = '--';
               else
                  pmStr  = localMat2Str(unitconv(s.PhaseMargin,'deg',DisplayUnits.Phase),PM,s.Stable);
                  pmfStr = localMat2Str(unitconv(s.PMFrequency,'rad/s',DisplayUnits.Frequency));
               end
               strData = sprintf('%s<td align="center">t=%s</td><td align="center">%s</td><td align="center">%s</td><td align="center">%s</td><td align="center">%s</td>',...
                  strData, num2str(this.Data(ct).time,4), gmStr, gmfStr, ...
                  pmStr, pmfStr);
               strData = strcat(strData,'</tr>');
            end
         end
         strData = strcat(strData,'</table>');
         
         %Create list to display GPM bounds
         if strcmp(gpmType,'none')
            strData = sprintf('%s<BR>%s<BR>',strData,ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtMarginsTableNoBounds'));
         else
            strData = sprintf('%s%s<BR><UL>',strData,ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtMarginsTableHasBounds'));
            switch gpmType
               case 'gain'
                  strData = sprintf('%s<LI>%s %g (%s)</LI>',...
                     strData,ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtMarginsTableGMBound'),GM,DisplayUnits.Gain);
               case 'phase'
                  strData = sprintf('%s<LI>%s %g (%s)</LI>',...
                     strData,ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtMarginsTablePMBound'),PM,DisplayUnits.Phase);
               case 'both'
                  strData = sprintf('%s<LI>%s %g (%s)</LI><LI>%s %g (%s)</LI>',strData,...
                     ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtMarginsTableGMBound'),GM,DisplayUnits.Gain,...
                     ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtMarginsTablePMBound'),PM,DisplayUnits.Phase);
            end
            strData = strcat(strData,'</UL>');
         end
         
         %Push the new data to the text area
         strData = strcat(strData,'</BODY>');
         this.txtArea.setContent(strData);
      end
   end %private methods

end %classdef

function str = localMat2Str(Data,bnd,Stable)
%Helper function to convert a vector of data into a string to display.
%Elements of the data vector less than a bound are displayed in red.

if nargin < 2, bnd = -inf; Stable = true; end
nData   = numel(Data);
nDigits = 4;

if Stable
   %For bound purposes stable systems always have +ve margins
   %see srorequirement.gainphasemargin
   fcnBndCheck = @(x) abs(x) < bnd;
else
   %For bound purposes unstable systems always have -ve margins
   fcnBndCheck = @(x) x < bnd;
   Data = -1*abs(Data);
end

str = '';
if nData > 1
   str = '[';
end
if fcnBndCheck(Data(1))
   str = sprintf('%s<B style="color:red">%s</B>',str,num2str(Data(1),nDigits));
else
   str = sprintf('%s%s',str,num2str(Data(1)));
end
for ct=2:nData
   if fcnBndCheck(Data(ct))
      str = sprintf('%s, <B style="color:red">%s</B>',str,num2str(Data(ct),nDigits));
   else
      str = sprintf('%s, %s',str,num2str(Data(ct),nDigits));
   end
end
if nData > 1
   str = strcat(str,']');
end
end