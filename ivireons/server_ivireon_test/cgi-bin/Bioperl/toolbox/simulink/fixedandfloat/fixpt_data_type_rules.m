function varargout = fixpt_data_type_rules(opStr,varargin)
% fixpt_data_type_rules This is function for private use by Simulink

% Copyright 1994-2009 The MathWorks, Inc.
% $Revision: 1.1.6.5 $  
% $Date: 2009/06/16 05:29:38 $

    switch opStr
        
      case 'SlopeBias2BinPt'
        
        funout = handleSlopeBias2BinPt(opStr,varargin{:});
        
      case 'SlopeBias2BinPt_WithTerms'
        
        funout = handleSlopeBias2BinPt(opStr,varargin{:});
        
      case 'Relop'
            
        funout = handleRelop(opStr,varargin{:});

      case 'CheckCastUseIntDivNetSlope'
            
        funout = handleCheckCastSlopeCorrection(opStr,varargin{:});

      case 'CheckMulUseIntDivNetSlope'
            
        funout = handleCheckMulSlopeCorrection(opStr,varargin{:});

      case 'CheckSupersetsDataType'
            
        funout = handleCheckSupersetsDataType(opStr,varargin{:});
      
      otherwise
        
        error('simulink:fixedpoint:datatyperules',...
              'The first input argument was not a recognised operation.');
    end

    nDesired = nargout;
    nActual =  length(funout);
    
    if nDesired <= nActual
        
        varargout = funout(1:max(1,nDesired));
    else
        error('simulink:fixedpoint:datatyperules',...
              'For operation %s, the number of output arguments is %d, but the function was called with %d output arguments.',opStr,nActual,nDesired);
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
function funout = handleSlopeBias2BinPt(opStr,varargin)
        
    inputNames = { 
        'u1_dt' 
        'AllowedWordLengths'
                 }; 

    inArgsStruct = getInputArgs(opStr,inputNames,varargin{:});

    u1DtVec = getdatatypespecs(inArgsStruct.u1_dt);
    
    yDtVec = fixptdtrules(opStr,u1DtVec,inArgsStruct.AllowedWordLengths);
    
    resDT = getdatatypespecs(yDtVec);
    
    if calledFromTlc(varargin{:})
        funout{1} = struct(resDT);
    else
        funout{1} = resDT;
    end
    
% End Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
function funout = handleRelop(opStr,varargin)
            
    inputNames = { 
        'u1_dt' 
        'u2_dt'
        'AllowedWordLengths'
                 }; 

    inArgsStruct = getInputArgs(opStr,inputNames,varargin{:});
    
    u1DtVec = getdatatypespecs(inArgsStruct.u1_dt);
    
    u2DtVec = getdatatypespecs(inArgsStruct.u2_dt);
    
    yDtVec = fixptdtrules(opStr,u1DtVec,u2DtVec,inArgsStruct.AllowedWordLengths);
        
    resDT = getdatatypespecs(yDtVec);
    
    if calledFromTlc(varargin{:})
        funout{1} = struct(resDT);
    else
        funout{1} = resDT;
    end

% End Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
function slopeCorrectionMode = handleCheckCastSlopeCorrection(opStr,varargin)
            
    inputNames = { 
        'u_dt' 
        'y_dt'
        'hardwareWL'
        'hardwareRndMeth'
        'rndMeth'
        'doSatur'
        }; 

    inArgsStruct = getInputArgs(opStr,inputNames,varargin{:});
    
    uDtVec = getdatatypespecs(inArgsStruct.u_dt);
    
    yDtVec = getdatatypespecs(inArgsStruct.y_dt);
    
    rndMethValue = rndMethStr2Val(inArgsStruct.rndMeth);

    hwRndMeth = HwRndMethStr2Val(inArgsStruct.hardwareRndMeth);

    doSaturStr = inArgsStruct.doSatur;
            
    if strcmp(doSaturStr, 'on')
        doSatur = 1;
    else
        doSatur = 0;
    end
    
    slopeCorrectionMode{1} = fixptdtrules(opStr, ...
                                          uDtVec, ...
                                          yDtVec, ...
                                          inArgsStruct.hardwareWL,...
                                          hwRndMeth, ...
                                          rndMethValue,...
                                          doSatur);

% End Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
function slopeCorrectionMode = handleCheckMulSlopeCorrection(opStr,varargin)
            
    inputNames = { 
        'u0_dt' 
        'u1_dt'
        'y_dt'
        'hardwareWL'
        'hardwareRndMeth'
        'rndMeth'
        'doSatur'
        }; 

    inArgsStruct = getInputArgs(opStr,inputNames,varargin{:});
    
    u0DtVec = getdatatypespecs(inArgsStruct.u0_dt);
    
    u1DtVec = getdatatypespecs(inArgsStruct.u1_dt);
    
    yDtVec = getdatatypespecs(inArgsStruct.y_dt);

    rndMethValue = rndMethStr2Val(inArgsStruct.rndMeth);

    hwRndMeth = HwRndMethStr2Val(inArgsStruct.hardwareRndMeth);
    
    doSaturStr = inArgsStruct.doSatur;
            
    if strcmp(doSaturStr, 'on')
        doSatur = 1;
    else
        doSatur = 0;
    end
    
    checkValue = fixptdtrules(opStr, ...
                                          u0DtVec, ...
                                          u1DtVec, ...
                                          yDtVec, ...
                                          inArgsStruct.hardwareWL,...
                                          hwRndMeth, ...
                                          rndMethValue,...
                                          doSatur);
 slopeCorrectionMode{1} = checkValue;
% End Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

function isSupersets = handleCheckSupersetsDataType(opStr,varargin)
            
    inputNames = { 
        'u0_dt' 
        'u1_dt'
        }; 

    inArgsStruct = getInputArgs(opStr,inputNames,varargin{:});
    
    u0DtVec = getdatatypespecs(inArgsStruct.u0_dt);
    
    u1DtVec = getdatatypespecs(inArgsStruct.u1_dt);
    
    checkValue = fixptdtrules(opStr, ...
                                          u0DtVec, ...
                                          u1DtVec);

    isSupersets{1} = checkValue;
% End Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
function inArgsStruct = getInputArgs(opStr,inputNames,varargin)

    inArgsStruct = struct([]);
    
    iArg = 1;
    
    %
    % subtract 2 for opStr and inputNames
    % so that iArg+1 will never index beyond end of cell
    %
    nArg = nargin-2;
    
    while iArg < nArg
        
        curArgName = varargin{iArg};
        
        if ischar(curArgName)
            
            if any(strcmp(curArgName,inputNames))
                
                inArgsStruct(1).(curArgName) = varargin{iArg+1};
                
            else
                warning('simulink:fixedpoint:datatyperules',...
                        'For operation %s, input pair with name %s is not needed and ignored',opStr,curArgName);
            end
        else
            error('simulink:fixedpoint:datatyperules',...
                  'First item in name-value pair must be a character array.');
        end
        
        iArg = iArg+2;
    end
    
    for i=1:length(inputNames)
        
        curInputName = inputNames{i};
        
        if ~isfield(inArgsStruct,curInputName)
            
            error('simulink:fixedpoint:datatyperules',...
                  'For operation %s, input pair with name %s was not found.',opStr,curInputName);
        end
    end

% End Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
function isCalledFromTlc = calledFromTlc(varargin)
    
    isCalledFromTlc = 0;
    
    for iArg = 1:nargin
        
        curArgName = varargin{iArg};
        
        if ischar(curArgName) && strcmp(curArgName,'calledFromTlc')
            
            isCalledFromTlc = 1;
            break;
        end
    end
    
% End Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
function  rndMethValue = rndMethStr2Val(rndMethStr)
    switch rndMethStr
        case 'Zero'
            rndMethValue = 0;
        case 'Nearest'
            rndMethValue = 1;
        case 'Ceiling'
            rndMethValue = 2;
        case 'Floor'
            rndMethValue = 3;
        case 'Simplest'
            rndMethValue = 4;
        case 'Round' % don't know if the option exist
            rndMethValue = 5;            
        case 'Convergent'
            rndMethValue = 6;
    end
% End Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
function  rndMethValue = HwRndMethStr2Val(rndMethStr)
    switch rndMethStr
        case 'Zero'
            rndMethValue = 0;
        case 'Floor'
            rndMethValue = 1;
        case 'Undefined'
            rndMethValue = 2;
        otherwise
            rndMethValue = 2;
    end
% End Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

