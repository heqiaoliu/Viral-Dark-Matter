function h = customize(h)
%CUSTOMIZE   

%   Author(s): G. Taillefer
%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2010/05/20 02:18:22 $

% product title should not be translated/localized. 
h.title = 'Fixed-Point Tool';
h.setTreeTitle(DAStudio.message('FixedPoint:fixedPointTool:labelModelHierarchy'));
%get im explorer and save it for later use 
h.imme = DAStudio.imExplorer(h);
h.imme.enableListSorting(true, 'Name', true); %enablesorting, columname, isascending
h.showDialogView(true);
h.showContentsOf(true);
h.showFilterContents(false);
h.setListMultiSelect(false);
set_param(0, 'HiliteAncestorsData', fxptui.gethilitescheme)

% [EOF]
