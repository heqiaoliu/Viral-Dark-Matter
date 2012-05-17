function dlgstruct = getDialogSchema(h, name)
% GETDIALOGSCHEMA

%   Author(s): G. Taillefer
%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2010/04/05 22:16:54 $

%return empty if h is invalid
dlgstruct.DialogTitle = '';
dlgstruct.Items = {};

if(~h.isvalid); return; end;

r=1;

%get autoscale settings panel
grp_scl = getsclpanel(h);
grp_scl.RowSpan = [r r];r=r+1;
grp_scl.ColSpan = [1 1];

%get results panel
grp_res = getrespanel(h);
grp_res.RowSpan = [r r];r=r+1;
grp_res.ColSpan = [1 1];

%get simulation settings panel
grp_sim = getsimpanel(h);
grp_sim.RowSpan = [r r];r=r+1;
grp_sim.ColSpan = [1 1];

%create spacer panel
spacer2.Type = 'panel';
spacer2.RowSpan = [r r];r=r+1;
spacer2.ColSpan = [1 1];
spacer2.LayoutGrid = [r-1 1];

%invisiwidget to listen to block property changes
blkprops.Source = h.daobject;
blkprops.Visible = false;
blkprops.Type = 'edit';
blkprops.ListenToProperties = { ...
	'MinMaxOverflowLogging', ...
	'DataTypeOverride', ...
	'DataTypeOverrideAppliesTo', ...
	'MinMaxOverflowArchiveMode'};
blkprops.RowSpan = [r r];r = r+1;
blkprops.ColSpan = [1 1];

%create main dialog
dlgstruct.DialogTitle = DAStudio.message('FixedPoint:fixedPointTool:labelCurrentSystem',  fxptds.getpath(h.daobject.Name));
dlgstruct.DialogTag = 'Fixed_Point_Tool_Dialog';
dlgstruct.HelpMethod = 'doc';
dlgstruct.HelpArgs =  {'fxptdlg'};
dlgstruct.PreApplyMethod   = 'setProperties';
dlgstruct.PreApplyArgsDT = {'handle'};
dlgstruct.PreApplyArgs = {'%dialog'};
dlgstruct.LayoutGrid  = [r-1 4];
dlgstruct.RowStretch = [0 0 0 0 1];
dlgstruct.ColStretch = [0 0 0 1];
dlgstruct.Items = {grp_scl, grp_res, grp_sim, spacer2, blkprops};

% [EOF]
