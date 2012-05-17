classdef PreScaleTool < handle
   % @PreScaleTool class definition

   %   Author(s): P. Gahinet, C. Buhr
   %   Copyright 1986-2008 The MathWorks, Inc.
   %	 $Revision: 1.1.6.3 $  $Date: 2008/06/13 15:13:52 $
   properties 
      Figure
      ScaleViewPanel
      ScaleViewEditor
   end
   
   methods
      %%
      function this = PreScaleTool(sys,xfocus)
         % Constructor
         ni = nargin;
        
         % Build GUI components
         build(this)
         % Lay things out
         layout(this)
             
         % Check if focus is specified
         if ni>1 && ~isempty(xfocus)
             % Set the target system to operate on
             this.ScaleViewPanel.setSystem(sys,xfocus);
         else
             this.ScaleViewPanel.setSystem(sys);
         end
         
         % Make figure visible
         set(this.Figure,'Visible','on')
      end
      
      %%
      function setSystem(this,Target,focus)
          if nargin > 2
              this.ScaleFocus = focus;
          end
          this.System = Target;
          update(this)
          
      end
      
      %%
      function layout(this)
         % Lays GUI components out
         p = get(this.Figure,'Position');
         fw = p(3);  fh = p(4);
         hBorder = 1; vBorder = .5;
         bh = 1.5;

         % Position Editor
         y0 = vBorder;
         set(this.ScaleViewEditor.HG.Panel,'Position',[hBorder y0 fw-2*hBorder vBorder+7])
         this.ScaleViewEditor.layout;

         % Position View
         bw = 16;  
         y0 = y0+vBorder+7;
        set(this.ScaleViewPanel.HG.Panel,'Position',[hBorder y0 fw-2*hBorder fh-y0-vBorder])
        this.ScaleViewPanel.layout;
        
      end

      %%
      function close(this)
         set(this.Figure,'CloseRequestFcn',[]);
         set(this.Figure,'DeleteFcn',[]);
         delete(this.Figure)
         delete(this)
      end
      
   end
   
   
   methods (Access = private)

       %%
      function build(this)
         % Builds GUI
         Color = get(0,'DefaultUIControlBackground');
         fig = figure(...
             'Color',Color,...
             'IntegerHandle','off', ...
             'Menubar','None',...
             'Toolbar','None',...
             'Name',ctrlMsgUtils.message('Control:scalegui:ScalingToolTitle'), ...
             'NumberTitle','off', ...
             'Unit','character', ...
             'Visible','off', ...
             'Tag','ScalingTool',...
             'HandleVisibility','off',...
             'ResizeFcn',@(x,y) layout(this),...
             'CloseRequestFcn',@(x,y) close(this),...
             'DeleteFcn',@(x,y) close(this));
         this.Figure = fig;
         
         % Store object in appdata of figure
         setappdata(this.Figure,'PreScaleToolObj',this)
         
         % Create toolbar
         t = uitoolbar(this.Figure,'HandleVisibility','off');
         
         % Create toggle buttons for zooming and legend
         z(1) = uitoolfactory(t,'Standard.PrintFigure');
         z(2) = uitoolfactory(t,'Exploration.ZoomIn');
         set(z(2),'Separator','on');
         z(3) = uitoolfactory(t,'Exploration.ZoomOut');
         z(4) = uitoolfactory(t,'Exploration.Pan');
         z(5) = uitoolfactory(t,'Annotation.InsertLegend');
         set(z(5),'Separator','on');
      
         % Create Scaling Tool Components
         this.ScaleViewPanel = scalingtool.ScalingViewPanel(fig);
         this.ScaleViewEditor = scalingtool.ScalingViewEditor(this.ScaleViewPanel,fig);
         
         % Set callbacks for buttons
         set(this.ScaleViewEditor.HG.Save,'Callback',{@localSaveDialogCallback this})
         set(this.ScaleViewEditor.HG.Close,'Callback',@(x,y) close(this))
         set(this.ScaleViewEditor.HG.Help,'Callback',{@localHelpCallback})
      end
      
     
      %%
      function exportDialog(this)
          
          % Create data for export2wsdlg        
          checkLabels = {ctrlMsgUtils.message('Control:scalegui:SaveDialogLabel1'), ...
              ctrlMsgUtils.message('Control:scalegui:SaveDialogLabel2')};
          varNames = {'ScaledSys', 'ScaledInfo'};
          
          ScaleFocus = this.ScaleViewPanel.getScaleFocus;
          if isempty(ScaleFocus)
              [ScaledModel,ScaledInfo] = prescale(this.ScaleViewPanel.System);
          else
              [ScaledModel,ScaledInfo] = prescale(this.ScaleViewPanel.System,{ScaleFocus(1) ScaleFocus(2)});
          end
                    
          items = {ScaledModel,ScaledInfo};
          
          % Launch export dialog
          export2wsdlg(checkLabels, varNames, items, ctrlMsgUtils.message('Control:scalegui:SaveDialogTitle'));
      end


   end
end

%--------------------------------------------------------------------------
function localSaveDialogCallback(es,ed,this)
% Launch export dialog
this.exportDialog;

end

function localHelpCallback(es,ed)
% CSH
MapFile = ctrlguihelp;
helpview(MapFile,'ScalingTool','CSHelpWindow')

end

