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
 
% Author(s): A. Stothert 24-Nov-2008
% Copyright 2008-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:37:22 $

if nargin < 2 % || ~isa(hEdit,'editconstr.editdlg')
    %Construct an edit dialog
    hEdit = editconstr.editdlg;
end

if size(this.Data.getData('xdata'),1) > 0
    %Construct a editor panel for this requirement
    hEditPanel = editconstr.TimeResponse(this);
    
    %Check to see if we want to show the editor panel at this time. This
    %is sometimes not true, e.g., when pre-populating the editor dialog with 
    %multiple requirements. 
    fShow = true;
    if ~isempty(varargin)
        idx = strcmp(varargin,'AutoShow');
        if any(idx)
            fShow = varargin{find(idx)+1};
        end
    end
        
    %Display the edit panel in the editor dialog
    if fShow
        hEdit.show(hEditPanel)
    end
else
    ctrMsgUtils.error('Controllib:graphicalrequirements:errNoDataToEdit')
end