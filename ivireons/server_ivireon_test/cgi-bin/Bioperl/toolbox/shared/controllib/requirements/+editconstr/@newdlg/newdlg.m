classdef newdlg < handle
   % NEWDLG  Dialog to create a requirement
   %
   
   % Author(s): A. Stothert 25-Nov-2008
   % Copyright 2008-2010 The MathWorks, Inc.
   % $Revision: 1.1.8.4 $ $Date: 2010/04/11 20:36:34 $
   
   properties(Access = 'public')
      Client
      List
   end
   
   properties(Access = 'public', SetObservable, AbortSet)
      Constraint
   end
   
   properties(Access = 'private')
      ParamEditor
      Handles
      Listeners
   end
   
   methods(Static = true)
      function inst = getInstance(Client,ParentFig)
         %GETINSTANCE return an instance of the dialog
         
         mlock    %Prevent loss of theInstance from clear all
         persistent theInstance
         if isempty(theInstance) || ~isvalid(theInstance)
            theInstance = editconstr.newdlg;
         end
         inst = theInstance;
         %Target the instance to the passed client
         if nargin == 2
            inst.setClient(Client,ParentFig)
         end
      end
   end
   
   methods(Access = 'protected')
      function this = newdlg
         %% NEWDLG  Constructor for singleton instance of @newdlg
         %        (dialog for creating a new constraint).
         
         % Build GUI frame
         this.Handles = this.build;
         % Listener to targeted constraint
         addlistener(this, 'Constraint', 'PostSet',@this.cbConstraintChanged);
         
         % Listener to self for cleanup
         addlistener(this,'ObjectBeingDestroyed', @this.cbCleanup);
      end
      
      
      function setClient(this,Client,ParentFig)
         %% Target dialog to a particular client
         
         % Set client
         this.Client = Client;
         
         if ishghandle(ParentFig)
            % Listen to figure being destroyed
            f = handle(ParentFig);
            DestroyL = handle.listener(f,'ObjectBeingDestroyed',@close);
            DestroyL.CallbackTarget = this;
            this.Listeners = DestroyL;
         end
         
         % Get list of available constraints for CLIENT and update popup
         this.List = Client.newconstr;
         if isempty(this.List)
            errStr = ctrlMsgUtils.message('Controllib:graphicalrequirements:errNoReqToAdd');
            errordlg(errStr)
            return
         end
         PopUp = this.Handles.TypeSelect;
         awtinvoke(PopUp,'removeAllItems');
         for ct=1:size(this.List,1)
            awtinvoke(PopUp,'addItem(Ljava.lang.Object;)',sprintf(this.List{ct,2}));
         end
         
         % Initialize dialog for first type in list
         this.settype(this.List{1,1});
         
         % Make frame visible
         Frame = this.Handles.Frame;
         awtinvoke(Frame,'pack');
         if ~Frame.isVisible
            % Bring it up centered
            if ishghandle(ParentFig)
               centerfig(Frame,ParentFig);
            else
               localCenterFig(Frame,ParentFig.position);
            end
         end
         awtinvoke(Frame,'setMinimized(Z)',false);
         awtinvoke(Frame,'setVisible(Z)',true);
      end
      
      function cbConstraintChanged(this,~,~)
         %% Update "Constraint Parameters" groupbox when constraint handle
         % changes
         
         NewConstr = this.Constraint;
         if ~isempty(NewConstr)
            this.Handles.Frame.setDone(false)
            if ~isempty(this.ParamEditor)
               % Clean up current editor settings
               delete(this.ParamEditor.Listeners);
               this.ParamEditor = [];
            end
            % Clean-up the parameter box
            ParamBox = this.Handles.ParamBox;
            awtinvoke(ParamBox,'removeAll');
            awtinvoke(ParamBox,'revalidate()');
            awtinvoke(ParamBox,'repaint()');
            % Update parameters box content
            this.ParamEditor = NewConstr.getWidgets(this.Handles.ParamBox);
            
            %Set tab order
            editorTabOrder = this.ParamEditor.tabOrder;
            nTabOrder      = numel(editorTabOrder);
            tabOrder       = javaArray('java.awt.Component',4+nTabOrder);
            tabOrder(1)    = this.Handles.TypeSelect;
            for ct = 2:2+nTabOrder-1
               tabOrder(ct) = editorTabOrder(ct-1);
            end
            tabOrder(1+nTabOrder+1) = this.Handles.Handles{4};
            tabOrder(1+nTabOrder+2) = this.Handles.Handles{5};
            tabOrder(1+nTabOrder+3) = this.Handles.Handles{6};
            focusTraversal = com.mathworks.toolbox.control.util.MJGenericFocusTraversal(tabOrder);
            awtinvoke(this.Handles.Frame,'setFocusTraversalPolicy(Ljava.awt.FocusTraversalPolicy;)',focusTraversal);
            
            % Redraw
            dim = awtinvoke(this.Handles.Frame,'getSize()');
            if dim.width < 443 || dim.height < 278
               %Force resize to some min dimensions
               awtinvoke(this.Handles.Frame,'pack()');
            end
         else
            if ~isempty(this.ParamEditor)
               delete(this.ParamEditor.Listeners);
            end
            this.ParamEditor = [];
            if ~isempty(this.Handles.ParamBox)
               ParamBox = this.Handles.ParamBox;
               awtinvoke(ParamBox,'removeAll');
               awtinvoke(ParamBox,'revalidate()');
               awtinvoke(ParamBox,'repaint()');
            end
            tabOrder    = javaArray('java.awt.Component',3);
            tabOrder(1) = this.Handles.TypeSelect;
            tabOrder(2) = this.Handles.Handles{4};
            tabOrder(3) = this.Handles.Handles{5};
            focusTraversal = com.mathworks.toolbox.control.util.MJGenericFocusTraversal(tabOrder);
            awtinvoke(this.Handles.Frame,'setFocusTraversalPolicy(Ljava.awt.FocusTraversalPolicy;)',focusTraversal)
            
            %Reset selection list to first item
            %awtinvoke(this.Handles.TypeSelect,'setSelectedIndex(I)',0);
         end
      end
      
      function cbCleanup(this,~,~)
         
         this.ParamEditor = [];
         this.Client = [];
         
         % Clean-up the parameter box
         ParamBox = this.Handles.ParamBox;
         awtinvoke(ParamBox,'removeAll');
         awtinvoke(ParamBox,'revalidate()');
         awtinvoke(ParamBox,'repaint()');
         
         % Clean-up the new dialog frame
         this.Handles.Frame.dispose;
         
         this.Handles = [];
      end
   end
end

function localCenterFig(Frame,pos)
%Helper function to center frame on window defined by pos

orig = pos(1:2) + 0.5*pos(3:4);
sz = Frame.getSize;
sz.width  = orig(1)-0.5*sz.width;
sz.height = orig(2)-0.5*sz.height;
awtinvoke(Frame,'setLocation(Ljava.awt.Point;)',java.awt.Point(sz.width,sz.height));

end
