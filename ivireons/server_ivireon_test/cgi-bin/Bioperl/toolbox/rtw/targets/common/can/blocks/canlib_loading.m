function canlib_loading(libName)
%CANLIB_LOADING Wanrs users of obsolete simulink blocks in target library.
%
%   CANLIB_LOADING(LIBNAME) warns the users of obsolete simulink blocks in
%   target library, LIBNAME.
%
%   This function is called in the PostLoadFcn callback for canblocks.mdl
%   and vector_candrivers.mdl library.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $
%   $Date: 2008/12/04 23:17:03 $

% Allow MathWorks legacy test models to not issue this warning.
if strcmp(getenv('DisableObsoleteCANBlocksWarnings'),'1')
    return;
end
    
% Store the warning status
prevWarningStatus = warning('off', 'backtrace');
% Warn depending on the library. 
switch libName
    case 'messageblocks'
        warnID = 'targets:can:messageblocks';
        warnMsg = ['The CAN Message blocks are obsolete' ... 
                    ' and may be removed from the product at a future date. If your' ...
                    ' model uses these blocks, refer to the <a href="matlab:eval(''helpview(fullfile(docroot, ''''toolbox'''', ''''can_blocks'''', ''''can_blocks.map''''), ''''Obsolete_CAN_Blocks'''')'')">CAN blocks transition page</a> and' ...
                    ' update your model accordingly. \nIf you wish to turn this warning off, type' ...
                    ' ''warning(''off'', ''targets:can:messageblocks'')'' at the command line.'];
    case 'vectorblocks'
        warnID = 'targets:can:vectorblocks';
        warnMsg = ['The host-side Vector CAN Driver blocks are obsolete' ... 
                    ' and may be removed from the product at a future date. If your' ...
                    ' model uses these blocks, refer to the <a href="matlab:eval(''helpview(fullfile(docroot, ''''toolbox'''', ''''can_blocks'''', ''''can_blocks.map''''), ''''Obsolete_CAN_Blocks'''')'')">CAN blocks transition page</a> and' ...
                    ' update your model accordingly. \nIf you wish to turn this warning off, type' ...
                    ' ''warning(''off'', ''targets:can:vectorblocks'')'' at the command line.'];
end

% Call warning.
warning(warnID, warnMsg);

% Restore the warning status
warning(prevWarningStatus);

%endfunction