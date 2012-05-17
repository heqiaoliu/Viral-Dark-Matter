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
 
% Author(s): A. Stothert 10-Feb-2009
% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:36:15 $

if nargin < 2 && nargout == 2, hAx = []; end
if nargout > 1, hAx = []; end
h = [];
ctrlMsgUtils.warning('Controllib:general:AbstractMethodMustBeOverloaded',warnmsg)