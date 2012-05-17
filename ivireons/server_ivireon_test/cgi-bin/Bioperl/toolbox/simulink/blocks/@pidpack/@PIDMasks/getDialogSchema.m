function dlgStruct = getDialogSchema(this, name) %#ok<INUSD>

% GETDIALOGSCHEMA This method overrides the method overrides
% matlab\toolbox\simulink\simulink\@Simulink\@DDGSource\getDialogSchema.m

%   Author(s): Murad Abu-Khalaf , December 17, 2008
%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2009/12/28 04:38:25 $

% Get the block handle from the dialog source
h = this.getBlock;

% Get the appropriate DDG dialog structure for the block

try
    unknownBlockType = false;
    switch h.MaskType
        case 'PID 1dof'
            dlgStruct = getPIDDDG(this , h);
            
        case 'PID 2dof'
            dlgStruct = getPIDDDG(this, h);
            
        otherwise
            unknownBlockType = true;
    end
    
    if (unknownBlockType)
        dlgStruct = errorDlg(h, ['Unknown mask type: ' h.MaskType]);
        warning('pidpack:PIDMasks', ['Unknown mask type in PIDMasks ' mfilename]);
    end
    
catch e
  dlgStruct = errorDlg(h, e.message);
end

%==============================================================================
% SUBFUNCTIONS:
%==============================================================================
function dlgStruct = errorDlg(h, errMsg)
txt.Name = ['Error occurred when trying to create dialog:' sprintf('\n') errMsg];
txt.Type = 'text';

blockType = h.BlockType;
if strcmp(h.Mask, 'on')
    maskType  = h.MaskType;
    if ~isempty(maskType)
        blockType = maskType;
    end
    blockType = [blockType, ' (mask)'];
end

dlgStruct.DialogTitle       = ['Block Parameters: ', blockType];
dlgStruct.Items             = {txt};
dlgStruct.CloseMethod       = 'closeCallback';
dlgStruct.CloseMethodArgs   = {'%dialog'};
dlgStruct.CloseMethodArgsDT = {'handle'};
