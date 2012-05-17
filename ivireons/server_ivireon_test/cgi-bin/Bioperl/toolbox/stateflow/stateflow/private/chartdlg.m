function varargout = chartdlg(varargin)
%EVENTDLG  Creates and manages the chart dialog box

%   E.Mehran Mestchian
%   Copyright 1995-2008 The MathWorks, Inc.
%   $Revision: 1.26.2.10 $  $Date: 2008/12/01 08:05:12 $

    objectId = varargin{2};
    dynamic_dialog_l(objectId);

%---------------------------------------------------------------------------------
function dynamic_dialog_l(chartId)
%
%  
%  
  h = idToHandle(sfroot, chartId);
  
  if ~isempty(h)
      d = DAStudio.Dialog(h, 'Chart', 'DLG_STANDALONE');
      sf('SetDynamicDialog',chartId, d);
  end	 

