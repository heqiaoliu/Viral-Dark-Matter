function varargout = ccp_init_mask(action, block, varargin)
% CCP_INIT_MASK Configuration for the CCP Block
%
% ccp_init_mask(action, block)
%
% Copyright 2002-2005 The MathWorks, Inc.
% $Revision: 1.11.4.7 $
% $Date: 2005/09/08 20:34:03 $
switch action
    case 'show_commands_mask_callback'
        show_commands=get_param(block,'show_commands');
        var_names = {'GET_CCP_VERSIONenabled' 'EXCHANGE_IDenabled' 'SET_MTAenabled' 'DNLOADenabled' ...
                'UPLOADenabled' 'SHORT_UPenabled' 'GET_DAQ_SIZEenabled' 'SET_DAQ_PTRenabled' ...
                'WRITE_DAQenabled' 'START_STOPenabled' 'SET_S_STATUSenabled' 'GET_S_STATUSenabled' ...
                'START_STOP_ALLenabled' 'DNLOAD_6enabled'};
        switch show_commands
            case 'on'
                internal_show_commands(block, var_names);
            case 'off'
                internal_hide_commands(block, var_names);
        end;
    otherwise
        disp('Unknown action');
end;
   
function internal_show_commands(block, var_names)
    for (i=1:length(var_names)) 
        simUtil_maskParam('show',block,var_names{i});
    end;
    
function internal_hide_commands(block, var_names)
    for (i=1:length(var_names))
        simUtil_maskParam('hide',block,var_names{i});
    end;
