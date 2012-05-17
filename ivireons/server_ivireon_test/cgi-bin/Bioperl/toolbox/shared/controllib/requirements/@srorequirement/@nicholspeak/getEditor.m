function [hEditPanel,hEdit] = getEditor(this,hEdit,varargin)
% GETEDITOR Return an edit dialog for this requirement
%
% [hEditPanel,hEditDlg] = this.getEditor;
% hEditPanel = this.getEditor(hEditDlg);
%
% Inputs:
%    hEditDlg - optional input with handle to an editor dialog, use this
%               input to display multiple requirements in the same dialog.
%               If omitted a new editor dialog is created.
%
% Outputs:
%   hEditPanel - a handle to a GUI class for this requirements text
%                editor
%   hEditDlg   - a handle to an editor dialog, see input argument hEditDlg.
%

% Author(s): A. Stothert 16-Dec-2008
% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:35:30 $

if nargin < 2 % || ~isa(hEdit,'editconstr.editdlg')
    %Construct an edit dialog
    hEdit = editconstr.editdlg;
end

if size(this.Data.getData('xdata'),1) > 0 || ...
        size(this.Data.getData('ydata'),1) > 0
    
    %Process optional arguments
    fShow = true;
    fType = 'nichols';
    View  = [];
    if ~isempty(varargin)
        %Check to see if we want to show the editor panel at this time.
        %This is sometimes not true, e.g., when pre-populating the editor
        %dialog with multiple requirements.
        idx = strcmp(varargin,'AutoShow');
        if any(idx)
            fShow = varargin{find(idx)+1};
        end
        %Check to see if we are passed a view object, if so we're being 
        %constructed from a plot and may need to modify the editor we
        %create.
        idx = strcmp(varargin,'View');
        if any(idx)
            View = varargin{find(idx)+1};
            switch class(View)
                otherwise
                    %Currently only support display on nichols plot
                    fType = 'nichols';
            end
        end
    end
    
    %Construct a editor panel for this requirement, we may be passed an
    %editor type.
    hEditPanel = editconstr.NicholsPeak(this,fType);
    
    %Do any specialized setup for nichols type editor
    if strcmp(fType,'nichols') && ~isempty(View);
        hEditPanel.Origin = View.Origin;
        L = handle.listener(View,findprop(View,'Origin'),'PropertyPostSet', {@localViewOriginChanged hEditPanel});
        Constr.Listeners = [View.Listeners; L];
        localAddEditOriginChanged(hEditPanel,View);
    end
    
    %Display the edit panel in the editor dialog
    if fShow
        hEdit.show(hEditPanel)
    end
else
    ctrMsgUtils.error('Controllib:graphicalrequirements:errNoDataToEdit')
end
end

%% Manage view origin change events
function localViewOriginChanged(hSrc,hData,hEditPanel)
hEditPanel.Origin = hData.NewValue;
end

function localAddEditOriginChanged(this,Constr)
%Local function to add listener, in local to avoid anonymous function
%issues.
addlistener(this,'Origin','PostSet', @(hSrc,hData) localEditOriginChanged(this,Constr));
end

%% Manage editor origin change events
function localEditOriginChanged(this,Constr)
if isvalid(this)
    Constr.Origin = this.Origin;
    Constr.update;
end
end