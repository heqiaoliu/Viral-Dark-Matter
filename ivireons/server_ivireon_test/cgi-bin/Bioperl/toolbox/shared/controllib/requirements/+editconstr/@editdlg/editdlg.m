classdef editdlg < handle
    % EDITDLG Dialog to edit constraints
    %
    
    % Author(s): A. Stothert
    % Copyright 2009 The MathWorks, Inc.
    % $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:31:03 $
 
    properties
        ConstraintList
        ParamEditor
        Handles
        Listeners
        TempListeners
    end
    
    properties(SetObservable, AbortSet)
        Constraint
    end
    
    %Public constructor
    methods(Access = 'public')
        function this = editdlg
        end
    end
    
    %Protected methods
    methods(Access = 'protected')
        function cbConstraintChanged(this,hSrc,hData)
            %PostSet callback for Constraint property
            
            NewConstr = this.Constraint;
            if ~isempty(NewConstr)
                % Update constraint popup list
                this.refresh;
                % Update parambox
                this.updateParambox
            else
                % De-targeting: remove listeners and all references to widgets
                if ~isempty(this.ParamEditor)
                    delete(this.ParamEditor.Listeners);
                end
                this.ParamEditor = [];
                delete(this.TempListeners);
                this.TempListeners = [];
                if ~isempty(this.Handles.ParamBox)
                    ParamBox = this.Handles.ParamBox;
                    awtinvoke(ParamBox,'removeAll()');
                    awtinvoke(ParamBox,'revalidate()');
                    awtinvoke(ParamBox,'repaint()');
                end
                tabOrder    = javaArray('java.awt.Component',3);
                tabOrder(1) = this.Handles.TypeSelect;
                tabOrder(2) = this.Handles.Handles{4};
                tabOrder(3) = this.Handles.Handles{5};
                focusTraversal = com.mathworks.toolbox.control.util.MJGenericFocusTraversal(tabOrder);
                awtinvoke(this.Handles.Frame,'setFocusTraversalPolicy(Ljava.awt.FocusTraversalPolicy;)',focusTraversal)
            end
        end
        function updateParambox(this)
            %UPDATEPARAMBOX help method to populaet the dialog with widgets
            %defined by the selected requirement
            
            this.Handles.Frame.setDone(false);
            % Update parameter box
            if ~isempty(this.ParamEditor)
                % Clean up current editor settings
                if ishandle(this.ParamEditor.Listeners)
                    delete(this.ParamEditor.Listeners);
                end
                this.ParamEditor = [];
            end
            ParamBox = this.Handles.ParamBox;
            awtinvoke(ParamBox,'removeAll()');
            this.ParamEditor = this.Constraint.getWidgets(this.Handles.ParamBox);
            awtinvoke(ParamBox,'revalidate()');
            awtinvoke(ParamBox,'repaint()');
            
            %Set tab order
            import com.mathworks.toolbox.control.util.*;
            editorTabOrder = this.ParamEditor.tabOrder;
            nTabOrder = numel(editorTabOrder);
            tabOrder = javaArray('java.awt.Component',3+nTabOrder);
            tabOrder(1) = this.Handles.TypeSelect;
            for ct = 2:2+nTabOrder-1
                tabOrder(ct) = editorTabOrder(ct-1);
            end
            tabOrder(1+nTabOrder+1) = this.Handles.Handles{4};
            tabOrder(1+nTabOrder+2) = this.Handles.Handles{5};
            focusTraversal = MJGenericFocusTraversal(tabOrder);
            awtinvoke(this.Handles.Frame,'setFocusTraversalPolicy(Ljava.awt.FocusTraversalPolicy;)',focusTraversal);
            
            % Redraw
            dim = awtinvoke(this.Handles.Frame,'getSize()');
            if dim.width < 440 || dim.height < 275
                %Forces resize to some min dimensions.
                awtinvoke(this.Handles.Frame,'pack()');
            end
            
        end
    end
end