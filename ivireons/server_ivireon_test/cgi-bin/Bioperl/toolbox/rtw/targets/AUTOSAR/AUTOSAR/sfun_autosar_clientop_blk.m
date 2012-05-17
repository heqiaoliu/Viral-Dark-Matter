function [maskDisplay, iIsBuiltin,iIsBus,iDtIdx,iWidth,iIsExpr,iDtStr,...
    oIsBuiltin,oIsBus,oDtIdx,oWidth,oIsExpr,oData,tlcStr] = ...
    sfun_autosar_clientop_blk( action, hblk )
%SFUN_AUTOSAR_CLIENTOP_BLK
%
% Convert mask parameters to sfcn parameters for AUTOSAR client operation blk
% 
% inports correspond to IN arguments
% outports correspond to OUT arguments
% an additional outport will be created for the error status
%

% Copyright 2008-2010 The MathWorks, Inc.

% We use callbacks to check parameters (displaying errordlg). All other errors
% are reported using DAStudio.Error and due to mask initisation catching errors
% will be reported to the user during model update.

imageFilename = 'sfun_autosar_clientop.bmp';
showErrPort = strcmp( get_param( hblk, 'showErrorStatus' ), 'on' );
portNameStr = get_param( hblk, 'portName' );
operationPrototypeStr = get_param( hblk, 'operationPrototype' );
interfacePathStr = get_param( hblk, 'interfacePath' );
showPortLabels = strcmp( get_param( hblk, 'showARPortLabels' ), 'on' );

% Block does not support multiple instantiation
supportMultipleInstantiation = 'off';

% define datatype for error port
showErrorOp = arblk.operationPrototype( 'f( OUT uint8 RTE_E )' );

model = bdroot(hblk);

% may override AUTOSAR max short name length
cs = getActiveConfigSet(model);
if cs.isValidParam('AutosarMaxShortNameLength')
    maxShortNameLength = get_param(cs, 'AutosarMaxShortNameLength');
else
    % To support use of blocks with other targets and 
    % old models (without the AutosarMaxShortNameLength param) loaded into 
    % Simulink only install
    maxShortNameLength = 32;
end

switch lower(action)
  case {'port_name_callback'}
    % Check port name is valid
    [isvalid, msg] = arxml.checkIdentifier(portNameStr, 'shortName', maxShortNameLength);
    if ~isvalid
        errordlg( msg, 'Client Operation Parse Error' );
    end
  case {'interface_path_callback'}
    % Check interface path is valid
    [isvalid, msg] = arxml.checkIdentifier(interfacePathStr, 'absPathShortName', maxShortNameLength);
    if ~isvalid
        errordlg( msg, 'Client Operation Parse Error' );
    end
  case {'operation_prototype_callback'}
    % Check operation prototype is a valid AUTOSAR prototype
    [~, isvalid, ~, err_msg] = arblk.parseOperationPrototype( operationPrototypeStr );
    if ~isvalid
        errordlg( err_msg, 'Client Operation Parse Error' );
    end
  case {'configure', 'check'}
      
    supportMultipleInstantiation = strcmp( supportMultipleInstantiation, 'on' );
    
    % AUTOSAR client/server operation prototype is similar to a c-fcn call thus we
    % use this to construct the api call
    operation = arblk.operationPrototype( operationPrototypeStr );
    operation.identifier = sprintf('%s_%s_%s', 'Rte_Call', portNameStr, operation.identifier);
    
    % Construct port mapping of the s-function to rte api call. 'this' (Used when
    % multiple instantiation is turned on) is not mapped to any ports. IN
    % arguments map to inports in order, OUT arguments map to outports in
    % order. Additionally if we are showing an error port then this is mapped
    % to the last outport.
    
    currInport = 1;
    currOutport = 1;
    arg2portNum = zeros( numel( operation.argument ), 1);
    for ii = 1:numel( operation.argument )
        switch operation.argument(ii).direction
          case {'IN'}
            arg2portNum(ii) = currInport;
            currInport = currInport + 1;
          case {'OUT'}
            arg2portNum(ii) = currOutport;
            currOutport = currOutport + 1;
          otherwise
            DAStudio.error('RTW:autosar:unknownArgumentDirection', operation.argument(ii).direction);
        end
    end

    if showErrPort
        errorStatusPortNum = currOutport;
        currOutport = currOutport + 1; %#ok<NASGU>
    end
    
    
    % Setup s-function parameters for inputs
    inArguments = operation.getINarguments;
    iIsBuiltin = zeros( 1, numel( inArguments) );
    iIsBus     = zeros( 1, numel( inArguments) );
    iDtIdx     = zeros( 1, numel( inArguments) );
    iDtStr     = cell ( 1, numel( inArguments) );
    iWidth     = zeros( 1, numel( inArguments) );
    iIsExpr    = zeros( 1, numel( inArguments) );
    for ii = 1:numel( inArguments )
        dt = inArguments(ii).datatype;
        iIsBuiltin(ii) = dt.IsBuiltin;
        iIsBus(ii)     = dt.IsBus;
        iDtIdx(ii)     = dt.Id - 1;
        iDtStr{ii}     = dt.DTName;

        if length( inArguments(ii).dims ) == 1
            iWidth(ii) = inArguments(ii).dims;
        else
            DAStudio.error('RTW:autosar:dimensionMustBeOne');
        end

        if iIsBus(ii) && iWidth(ii) > 1
            DAStudio.error('RTW:autosar:nonScalarBus');
        end
        
        % Only inputs that are scalars are passed by value, these can accept expressions as their arguments
        iIsExpr(ii)    = (~dt.IsBus && iWidth(ii) == 1);
    end
    
    % Setup s-function parameters for outports
    outArguments = operation.getOUTarguments;
    oIsBuiltin = zeros( 1, numel( outArguments) );
    oIsBus     = zeros( 1, numel( outArguments) );
    oDtIdx     = zeros( 1, numel( outArguments) );
    oDtStr     = cell ( 1, numel( outArguments) );
    oNameCell  = cell ( 1, numel( outArguments) );
    oWidth     = zeros( 1, numel( outArguments) );
    oIsExpr    = zeros( 1, numel( outArguments) );
    for ii = 1:numel( outArguments )
        dt = outArguments(ii).datatype;
        oIsBuiltin(ii) = dt.IsBuiltin;
        oIsBus(ii)     = dt.IsBus;
        oDtIdx(ii)     = dt.Id - 1;
        oDtStr{ii}     = dt.DTName;
        oNameCell{ii}  = ['"' outArguments(ii).identifier '"'];

        if length( outArguments(ii).dims ) == 1
            oWidth(ii) = outArguments(ii).dims;
        else
            DAStudio.error('RTW:autosar:dimensionMustBeOne');
        end

        if oIsBus(ii) && oWidth(ii) > 1
            DAStudio.error('RTW:autosar:nonScalarBus');
        end
        
        % Only inputs that are scalars are passed by value, these can accept expressions as their arguments
        oIsExpr(ii)    = 0;
    end

    numONames=length(oNameCell);

    % formatting required to create TLC vector
    oNames = slprivate('joinCellToStr',oNameCell,',');
    oNames = ['[' oNames ']'];
        
    
    if showErrPort==true
        argument = showErrorOp.argument(1);
        dt = argument.datatype;
        oIsBuiltin(end+1) = dt.IsBuiltin;
        oIsBus(end+1)     = dt.IsBus;
        oDtIdx(end+1)     = dt.Id - 1;
        oDtStr{end+1}     = dt.DTName;
        if length( argument.dims ) == 1
            oWidth(end+1)     = argument.dims;
        else
            DAStudio.error('dimensionMustBeOne');
        end 
        
        % only enable expression folding if this is the only OUT param
        oIsExpr(end+1)    = (numel( outArguments) == 0);
    end
    
    % Pack these return variables into a single cell array to preserve
    % the function signature (see g588302)
    oData = {oDtStr,oNames,numONames,get_param(hblk, 'showErrorStatus')};
    
    % construct TLC expression and mask display
    maskDisplay = sprintf('image(imread(''%s''),''center'');', imageFilename); 

    rhsStr = [operation.identifier, '('];
    protoStr = sprintf('%s %s(', 'uint8_T', operation.identifier);

    sep = '';
    if supportMultipleInstantiation
        rhsStr = sprintf('%s%s%s', rhsStr, 'this', sep);
        protoStr = sprintf('%s%s%s', protoStr, 'Rte_Instance this', sep);
        sep = ', ';
    end
    
    for ii = 1:numel( operation.argument )
        rhsStr = sprintf('%s%s%s', rhsStr, sep, iGetRHSArgAccess( operation.argument(ii), arg2portNum(ii) ) );
        protoStr = sprintf('%s%s%s', protoStr, sep, iGetRHSDataTypeAccess( operation.argument(ii) ) );
        sep = ', ';

        switch( operation.argument(ii).direction )
          case {'IN'}
            type = 'input';
          case {'OUT'}
            type = 'output';
          otherwise
            DAStudio.error('RTW:autosar:unknownArgumentDirection', operation.argument(ii).direction);
        end
        
        if showPortLabels
            maskDisplay = sprintf('%s\nport_label(''%s'', %d, ''%s'')',...
                                  maskDisplay, type,...
                                  arg2portNum(ii),...
                                  operation.argument(ii).identifier);
        end
    end

    rhsStr = sprintf('%s)', rhsStr);
    protoStr = sprintf('%s)', protoStr);
    
    if showErrPort
        lhsStr = iGetLHSArgAccess( showErrorOp.argument(1), errorStatusPortNum );
        if showPortLabels
        maskDisplay = sprintf('%s\nport_label(''output'', %d, ''%s'')', maskDisplay, errorStatusPortNum, showErrorOp.argument(1).identifier);
        end
    else
        lhsStr = '';
    end
    
    if ~isempty(lhsStr)
        tlcStr{1, 1} = sprintf('"%s = %s"', lhsStr, rhsStr);
    else
        tlcStr{1, 1} = sprintf('"%s"', rhsStr);
    end
    tlcStr{1, 2} = sprintf('"%s"', rhsStr);

    tlcStr{1, 3} = sprintf('%s', protoStr);
    
    
  otherwise
    DAStudio.error('RTW:autosar:unknownBlockCommand');
end

%--------------------------------------------------------------------------
function str = iGetRHSArgAccess(arg, portNum)

width = arg.dims(1);

switch arg.direction
  case {'IN'}
    if arg.datatype.IsBus
        str = sprintf('%%<LibBlock%sSignalAddr(%d, "", "", 0)>',...
                      'Input', portNum - 1);
    elseif width > 1
        str = sprintf('&%%<LibBlock%sSignalAddr(%d, "", "", 0)>',...
                      'Input', portNum - 1);

    else
        str = sprintf('%%<LibBlock%sSignal(%d, "", "", 0)>',...
                      'Input', portNum - 1);
    end
    
  case {'OUT'}
    if width > 1
        str = sprintf('&%%<LibBlock%sSignalAddr(%d, "", "", 0)>',...
                      'Output', portNum - 1);
    else
        str = sprintf('%%<LibBlock%sSignalAddr(%d, "", "", 0)>',...
                      'Output', portNum - 1);
    end
  otherwise
    DAStudio.error('RTW:autosar:unknownArgumentDirection', arg.direction);
end

%--------------------------------------------------------------------------
function str = iGetLHSArgAccess(arg, portNum)

switch arg.direction
  case {'OUT'}
    str = sprintf('%%<LibBlock%sSignal(%d, "", "", 0)>',...
                  'Output', portNum - 1);
  otherwise
    DAStudio.error('RTW:autosar:unknownArgumentDirection', arg.direction);
end


%--------------------------------------------------------------------------
function str = iGetRHSDataTypeAccess(arg)

width = arg.dims(1);

switch arg.direction
  case {'IN','OUT'}
    if arg.datatype.IsBus
        str = sprintf('%s* %s', arg.datatype.Name, arg.identifier);
    elseif width > 1
        assert( ~arg.datatype.IsBus, 'arrays of buses not supported');
        if arg.datatype.IsEnum
            type=arg.datatype.Name;
        else
            type=arg.datatype.NativeType;
        end
        str = sprintf('Rte_rt_Array__%s_%i* %s', type, width, arg.identifier);
    else % built-in or alias to built-in
        % even for alias to built-in we still use built-in data type
        % because Simulink overrides alias if block is connected to
        % equavalent built-in.
        if strcmp(arg.direction,'OUT')
            type = sprintf('%s*', arg.datatype.NativeType);
        else
            type = sprintf('%s', arg.datatype.NativeType);
        end
        str = sprintf('%s %s', type, arg.identifier);
    end
  otherwise
    DAStudio.error('RTW:autosar:unknownArgumentDirection', arg.direction);
end
