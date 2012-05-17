function dlgstruct = getDialogSchema(this,arg) %#ok
%getDialogSchema Construct ColorMap dialog.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2009/06/11 16:05:41 $

% Colormap
%
% Do NOT auto-apply these (.Mode=false)
cmap.Name           = 'Colormap:';
cmap.Type           = 'combobox';
cmap.Editable       = true;
cmap.Entries        = {'gray(256)','jet(256)','hot(256)','bone(256)','cool(256)','copper(256)'};
cmap.ObjectProperty = 'MapExpression';
cmap.RowSpan        = [1 1];
cmap.ColSpan        = [1 2];
cmap.ToolTip        = 'Must evaluate to an Nx3 matrix';
cmap.Mode           = false;
cmap.Enabled        = this.isIntensity;
cmap.Tag            = 'MapExpression';

% Pixel scaling
str = sprintf('Specify range of displayed pixel values [%d to %d]', ...
              this.ScaleLimits);
scale.Name           = str;
scale.Tag            = 'UserRange';
scale.Type           = 'checkbox';
scale.ObjectProperty = 'UserRange';
scale.RowSpan        = [2 2];
scale.ColSpan        = [1 2];
scale.Mode           = false;
scale.DialogRefresh  = true;  % immediate reaction to checkbox
scale.Enabled        = this.isIntensity;

if isempty(this.dialog)
    % Never rendered yet - use object data to drive enable
    enable_minmax = this.isIntensity && this.UserRange;
else
    % Dialog already open
    % Do not use this.userRange, since it's out-of-date here
    % this.isIntensity is fine to use, since it's not a widget
    % in the dialog (thus it's never out-of-date with dialog entries)
    enable_minmax = this.isIntensity && this.dialog.getWidgetValue('UserRange');
end

smin.Name           = 'Min:';
smin.Type           = 'edit';
smin.ObjectProperty = 'UserRangeMin';
smin.RowSpan        = [3 3];
smin.ColSpan        = [1 1];
smin.ToolTip        = 'Minimum pixel value';
smin.Enabled        = enable_minmax;
smin.Mode           = false;
smin.Tag            = 'UserRangeMin';

smax.Name           = 'Max:';
smax.Type           = 'edit';
smax.ObjectProperty = 'UserRangeMax';
smax.RowSpan        = [3 3];
smax.ColSpan        = [2 2];
smax.ToolTip        = 'Maximum pixel value';
smax.Enabled        = enable_minmax;
smax.Mode           = false;
smax.Tag            = 'UserRangeMax';

% Overall Settings group
%
cmap_cont.Type       = 'panel';
%cmap_cont.Name       = 'Color Map';
cmap_cont.Tag        = 'ColorMapPanel';
cmap_cont.LayoutGrid = [3 2];
cmap_cont.Items      = {cmap, scale, smin, smax};

% ----------------------------------------------
% Return main dialog structure
% ----------------------------------------------
%
dlgstruct = this.StdDlgProps;
dlgstruct.Items          = {cmap_cont};
dlgstruct.PreApplyMethod = 'preApply';
dlgstruct.DialogTag      = 'ColorMap';

% [EOF]
