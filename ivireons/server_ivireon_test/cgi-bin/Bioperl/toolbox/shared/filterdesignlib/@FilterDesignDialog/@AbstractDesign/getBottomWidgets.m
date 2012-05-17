function items = getBottomWidgets(this, startrow, items)
%GETBOTTOMWIDGETS   Get the bottomWidgets.

%   Author(s): J. Schickler
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/04/21 04:21:07 $

if nargin < 3
    items = {};
    if nargin < 2
        startrow = 1;
    end
end

if strcmpi(this.OperatingMode, 'matlab')
    varname.Type           = 'edit';
    varname.Name           = FilterDesignDialog.message('SaveVariableAs');
    varname.RowSpan        = [startrow startrow];
    varname.ColSpan        = [1 1];
    varname.ObjectProperty = 'VariableName';
    varname.Tag            = 'VariableName';
    varname.Source         = this;
    varname.Mode           = true;
    varname.Enabled        = this.Enabled;

    items = {items{:}, varname}; %#ok<CCAT>
end

if supportsAnalysis(this)

    fvtool.Type         = 'pushbutton';
    fvtool.Name         = FilterDesignDialog.message('ViewFilterResponse');
    fvtool.RowSpan      = [startrow startrow];
    fvtool.ColSpan      = [3 3];
    fvtool.ObjectMethod = 'export';
    fvtool.Tag          = 'fvtool';
    fvtool.MethodArgs   = {'%dialog', 'launchfvtool', true, 'visualizing the design'};
    fvtool.ArgDataTypes = {'handle', 'string', 'bool', 'string'};
    fvtool.Source       = this;
    fvtool.ToolTip      = 'Launch FVTool to analyze the designed filter';
    fvtool.Enabled      = this.Enabled;
    
    items = {items{:}, fvtool}; %#ok<CCAT>
end

% [EOF]
