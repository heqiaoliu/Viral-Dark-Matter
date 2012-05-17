function hout = LinearizationSpecificationDialog(varargin)
% LinearizationSpecificationDialog - Create the DDG dialog to specify a
% linearization.

%  Author(s): John Glass
%  Revised:
%   Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2009/04/21 04:50:15 $

mlock
persistent dlg;
persistent this;

if ~isa(this,'slctrlguis.LinearizationSpecificationDialog')
    this = slctrlguis.LinearizationSpecificationDialog;
end
hout = this;

if nargin == 0
    return
else
    NewBlock = varargin{1};
end

% If the dialog has un-applied changes throw an error dialog
if isa(dlg,'DAStudio.Dialog')
    if dlg.hasUnappliedChanges
        errordlg(ctrlMsgUtils.message('Slcontrol:blockspecificationdlg:UnappliedChanges',this.Block),'Simulink Control Design')
        return
    end
end

this.Block = NewBlock;

% Get the structure specified on the block
spec = get_param(this.Block,'SCDBlockLinearizationSpecification');
if isempty(spec)
    spec = struct('Specification','',...
                    'Type','Expression',...
                    'ParameterNames','',...
                    'ParameterValues','');
end

% Store the data
this.Data = struct('SCDBlockLinearizationSpecification',spec,...
                    'SCDEnableBlockLinearizationSpecification',...
                        get_param(this.Block,'SCDEnableBlockLinearizationSpecification'),...
                    'TableRowFocus',1,...
                    'PNPVTableData',{localPNPVCell(spec)});
if ~isa(dlg,'DAStudio.Dialog')
    dlg = DAStudio.Dialog(this);
else
    this.refresh(dlg)
end
dlg.show

% Add a listener to when the block is being deleted
hBlock = get_param(NewBlock,'Object');
this.Listeners = handle.listener(hBlock, 'DeleteEvent', {@LocalClose,dlg});

function LocalClose(es,ed,dlg)

if isa(dlg,'DAStudio.Dialog')
    delete(dlg)
end

function data = localPNPVCell(SpecStruct)
% Get the parameter table data
ncommas_names = strfind(SpecStruct.ParameterNames,',');
if ~isempty(SpecStruct.ParameterNames)
    if ~isempty(ncommas_names)
        paramn_str = textscan(SpecStruct.ParameterNames,'%s','delimiter',',');
        paramn_str = paramn_str{1};
        paramv_str = textscan(SpecStruct.ParameterValues,'%s','delimiter',',');
        paramv_str = paramv_str{1};
    else
        paramn_str = {SpecStruct.ParameterNames};
        paramv_str = {SpecStruct.ParameterValues};
    end
    data = [paramn_str,paramv_str];
else
    data = {'',''};
end