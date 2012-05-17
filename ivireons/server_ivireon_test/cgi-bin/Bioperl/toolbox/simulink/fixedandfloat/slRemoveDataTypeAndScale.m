function [changed, skipped] = slRemoveDataTypeAndScale(system, update, verbose)
%SLREMOVEDATATYPEANDSCALE Remove unnecessary calls to
%  slDataTypeAndScale('DT', 'Scale') for DataTypeStr parameters of blocks
%  within a Simulink model and replace them with an equivalent built-in or
%  user-defined (e.g. fixdt) fully-specified data type.
%
%  This function:
%   - Finds the DataTypeStr parameters specified using slDataTypeAndScale('DT',
%     'Scale') for blocks within the model. (This includes the blocks inside
%     masked subsystems but excludes the blocks inside library blocks.)
%   - Determines whether this slDataTypeAndScale() can be safely replaced
%     with an equivalent built-in or user-defined data type, depending on
%     the contents of 'DT' and 'Scale'. 
%   - Proposes changes for those  slDataTypeAndScale()'s that can be safely
%     replaced automatically and performs replacement if requested.
%   - Reports the list of slDataTypeAndScale()'s that require manual
%     inspection to determine wether the calls can be safely replaced.
%
%  Limits of Usage:
%   - Searches for slDataTypeAndScale excludes blocks inside library blocks.
%   - It does not remove unnecessary calls to slDataTypeAndScale if the
%     model is a library.
%   - Requires successful update diagram to perform analysis.
% 
%  Syntax:
%    [supported, skipped] = slRemoveDataTypeAndScale(system, update, verbose)
%
%    Arguments:
%     -system (required):   name/handle of a loaded model, a subsystem or
%                           block in that model.
%     -update (optional):   0: check only;
%                           1: update parameter (default);
%     -verbose (optional):  0: silent; 
%                           1: show info about the supported cases;
%                           2: show info about the supported and skipped cases (default);    
%                         
%    Returns:
%     -supported:  an array of structures for cases that can be
%                  automatically replaced.
%     -skipped:    an array of structures for cases that require manual
%                  inspection.
%
%  See also slDataTypeAndScale.

%  Supported cases for slDataTypeAndScale('DT', 'Scale') removal:
%   1. 'DT' is fully specified, 
%       Case 1.1. the block is NOT under masked subsystem.
%       Case 1.2. the block is under the masked subsystem with 'DT'
%                 specified via sint, uint, fixdt, sfrac, ufrac or float.
%   2. 'DT' is NOT fully specified but is specified via sfix, ufix, fixdt,
%       and 'Scale' is specified via any below,
%       Case 2.1. one scalar value expression that does not contain variables.
%       Case 2.2. one expression which contains variables.
%       Case 2.3. an array of two elements, each can be a variable, or an
%                 expression containing no white-space. 
%
%   Case 1.1:
%   o    slDataTypeAndScale('foo', 'Scale') ==> foo
%   o    slDataTypeAndScale('foobar(...)', 'Scale') ==> foobar(...)
%   Case 1.2:
%   o    slDataTypeAndScale('uint(b)', 'Scale') ==> uint(b)
%   o    slDataTypeAndScale('sint(b)', 'Scale') ==> sint(b)    
%   o    slDataTypeAndScale('ufrac(b)', 'Scale') ==> sfrac(b)    
%   o    slDataTypeAndScale('sfrac(b)', 'Scale') ==> sfrac(b)    
%   o    slDataTypeAndScale('float(str)', 'Scale') ==> float(str)     
%   o    slDataTypeAndScale('float(b, c)', 'Scale') ==> float(b, c)     
%   o    slDataTypeAndScale('fixdt(str)', 'Scale') ==> fixdt(str)
%   o    slDataTypeAndScale('fixdt(a, b, c)', 'Scale') ==> fixdt(a, b, c)
%   Case 2.1:
%     Let power2 be a numeric expression equal to 2^exponent, where exponent
%     is an integer.
%   o    slDataTypeAndScale('sfix(b)', 'power2') ==> fixdt(1, b, -exponent)
%   o    slDataTypeAndScale('fixdt(a, b)', 'power2') ==> fixdt(a, b, -exponent) 
%     Let npower2 be any other numeric expression, e.g. 1.5, 1.2*2^-2.
%   o    slDataTypeAndScale('ufix(b)', 'npower2') ==> fixdt(0, b, npower2, 0)
%   o    slDataTypeAndScale('fixdt(a, b)', 'npower2') ==> fixdt(a, b,
%        npower2, 0) 
%   Case 2.2:
%     Let expr be any expression that evaluates to a scalar value one. 
%   o    slDataTypeAndScale('sfix(b)', '2^expr') ==> fixdt(1, b, 2^expr, 0)
%   o    slDataTypeAndScale('ufix(b)', 'expr') ==> fixdt(0, b, expr, 0)
%   o    slDataTypeAndScale('fixdt(a, b)', '2^expr') ==> fixdt(a, b, 2^expr, 0)
%   o    slDataTypeAndScale('fixdt(a, b)', 'expr') ==> fixdt(a, b, expr, 0)
%   Case 2.3:
%     Let Par1 and Par2 each be a numeric values, a variables, or an 
%     expressions containing no white-space. 
%   o    slDataTypeAndScale('sfix(b)', '[Par1, Par2]') ==> fixdt(1, b, Par1,
%        Par2) 
%   o    slDataTypeAndScale('fixdt(a, b)', '[Par1  Par2]') ==> fixdt(a, b,
%        Par1, Par2)
%
%  Skipped cases listed for user inspection:
%   1. The model is a library model.
%   2. The block is under a masked subsystem and 'DT' is fully specified
%      via any below,
%      2.1. a variable, e.g. foo
%      2.2. a function other than sint, uint, fixdt, sfrac, ufrac, and
%           float, e.g. foobar(a,b)
%   3. 'DT' is NOT fully specified, 
%      3.1. 'DT' is NOT specified via a function sfix, ufix or fixdt, e.g.
%           foobar(a)
%      3.2. 'DT' is specified via a function sfix, ufix or fixdt, and
%           'Scale' is specified via any below
%        3.2.1. a single variable but does not resolve to a scalar value.
%        3.2.2. an array of two elements, either of which is an expression
%               containing one or more white-spaces.
%        3.2.3. an array of more than two elements. 
%
%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $     $Date: 2009/03/05 19:03:10 $

    if ( nargin == 0 )
        disp(DAStudio.message('Simulink:fixedandfloat:slRmDTNoArg'));
        return;
    elseif ( nargin < 2 )
        update = 1;
        verbose = 2;
    elseif ( nargin < 3 )
        verbose = 2;
    end

    changed = struct('BlockName', {}, 'ParamName', {}, 'OldDTStr', {}, 'NewDTStr', {});
    skipped = struct('BlockName', {}, 'ParamName', {}, 'OldDTStr', {}, 'NewDTStr', {});
    
    % make sure the model has been loaded upon the system
    try 
        handle = get_param(system, 'Handle');
        modelName = getfullname(bdroot(handle));
    catch e
        DAStudio.error('Simulink:fixedandfloat:slRmDTInputArg');
    end

    try 
        % get the handles for blocks in the loaded model system
        mdlType = strtrim(get_param(bdroot(handle), 'BlockDiagramType'));
      
        % get the data type parameters which is specified via
        % slDataTypeAndScale( ) function
        if ( isUnderMask(handle) )
            % the block is under masked subsystem
            objs_mask = filterParameters(find_system(handle, 'LookUnderMasks', 'all', 'BlockParamType', 'DataTypeStr'));
            objs_nmask = [];
            nObjs = length(objs_mask);
            nObjs_nmask = 0;
        else
            objs_nmask = filterParameters(find_system(handle, 'LookUnderMasks', 'none', 'BlockParamType', 'DataTypeStr'));
            objs_all = filterParameters(find_system(handle, 'LookUnderMasks', 'all', 'BlockParamType', 'DataTypeStr'));
            objs_mask = setDiffonParamDescriptor(objs_all, objs_nmask);
            nObjs = length(objs_all);
            nObjs_nmask = length(objs_nmask);
        end
        
        
        
        handles = zeros(nObjs, 1);  % preallocation for speed by estimation
        paramNames = cell(nObjs, 1);

        % process parameters not from blocks under mask
        for n = 1:nObjs_nmask
            blkPath = objs_nmask(n).OwnerPath;
            handles(n) = get_param(blkPath, 'Handle');
            paramNames{n} = objs_nmask(n).ParameterName;
        end

        % process parameters from blocks under mask
        for n = 1:(nObjs-nObjs_nmask)
            blkPath = objs_mask(n).OwnerPath;
            handles(nObjs_nmask+n) = get_param(blkPath, 'Handle');
            paramNames{nObjs_nmask+n} = objs_mask(n).ParameterName;
        end
        
        isChange = false; 
        itemNum1 = 0;
        itemNum2 = 0;
        for n=1:nObjs
            blkHdl = handles(n);
            paramName = paramNames{n};
            blkPath = getfullname(blkHdl);
            oldStr = get_param(blkHdl, paramName);
            
            % replace slDataTypeAndScale() function if possible and verify the change
            if ( ~isequal( mdlType, 'library') )
                if ( n <= nObjs_nmask )
                    isMasked = 0;
                else
                    isMasked = 1;
                end
                newStr = replaceFunc(blkHdl, oldStr, isMasked);
            else
                newStr = '';
            end

            if ( ~isempty(newStr) )
                isChange = true;
                itemNum1 = itemNum1+1;
                changed(itemNum1).BlockName = blkPath;
                changed(itemNum1).ParamName = paramName;
                changed(itemNum1).OldDTStr = oldStr;
                changed(itemNum1).NewDTStr = newStr;
                
                if ( update )
                    set_param(blkHdl, paramName, newStr);
                end
            else
                itemNum2 = itemNum2+1;
                skipped(itemNum2).BlockName = blkPath;
                skipped(itemNum2).ParamName = paramName;
                skipped(itemNum2).OldDTStr = oldStr;
                skipped(itemNum2).NewDTStr = newStr;
            end
        end

        if ( ~nObjs && verbose >= 1 )
            disp(DAStudio.message('Simulink:fixedandfloat:slRmDTVerbose0'));
        end
        if ( isChange && verbose >= 1 )
            if ( update )
                disp(DAStudio.message('Simulink:fixedandfloat:slRmDTVerbose1u'));
            else
                disp(DAStudio.message('Simulink:fixedandfloat:slRmDTVerbose1'));
            end
            showResults(changed);
        end
        if ( verbose >= 2 && ~isempty(skipped) )
            if ( isequal( mdlType, 'library') )
                disp(DAStudio.message('Simulink:fixedandfloat:slRmDTLibrary', modelName));
            end
            disp(DAStudio.message('Simulink:fixedandfloat:slRmDTVerbose2'));
            showResults(skipped);
        end
  
    catch e
          e.rethrow;
    end
% endfunction


%------------------------------------------------------------------------------
% SUBFUNCTIONS
%------------------------------------------------------------------------------

% is the system under masked subsystem
function msk = isUnderMask(hdl)

    msk = false;
    rootHdl = get_param(bdroot(hdl), 'Handle'); % always top system of a model
    parent = get_param(hdl, 'Parent');
    if ( isempty(parent) )
        return;
    else
        parentHdl = get_param(parent, 'Handle');
    end
    
    while ( ~isequal(parentHdl, rootHdl) )
        if ( isequal(get_param(parentHdl, 'Mask'), 'on') )
            msk = true;
            break; 
        else
            parent = get_param(parentHdl, 'Parent');
            parentHdl = get_param(parent, 'Handle');
        end
    end
        

% remove parameters not specified by slDataTypeAndScale function
% return parameter descriptor array for any slDataTypeAndScale, or [] if no
% such function exists from input
function objs = filterParameters( dscps )
    
    L = length(dscps);
    i = 0;
    for n=1:L
        blkPath = dscps(n).OwnerPath;
        parName = dscps(n).ParameterName;
        paramValue = get_param(blkPath, parName);
        if ( strcmp(getFunctionName(paramValue), 'slDataTypeAndScale') )
            i = i+1;
            objs(i) = dscps(n);
        end
    end
    
    if ( i==0 )
        objs = [];
    end
        

% set difference of two sets of parameter descriptors,i.e. dscps1 - dscps2
% return the difference if any descriptor in dscps1 is not in dscps2, or
% return [] otherwise.
function dscps = setDiffonParamDescriptor(dscps1, dscps2)

    L1 = length(dscps1);
    L2 = length(dscps2);
    n = 0;
    
    for n1=1:L1
        flag = 0;
        str1 = [dscps1(n1).OwnerPath, dscps1(n1).ParameterName];
        for n2=1:L2
            str2 = [dscps2(n2).OwnerPath, dscps2(n2).ParameterName];
            if ( strcmp(str1, str2) )
                flag = 1;
                break;
            end
        end
        if (~flag)
            n = n+1;
            dscps(n) = dscps1(n1);
        end
    end
    
    if ( n == 0 )
        dscps = [];
    end

% get function name, function should NOT be enclosed by parathesis i.e.
% (func( ... ))
function s = getFunctionName(str)
       
    k = findstr(str, '(');
    if ( ~isempty(k) && k(1) > 1 )
        s = strtrim(str(1:k(1)-1));
    else
        s = '';
    end

% replace function slDataTypeAndScale() with fully-specified type such as
% fixdt(1, 16, sc) if possible. 
% str must contain 'slDataTypeAndScale' function call.
% return '' if replacement is not needed or not considered at this point
function newStr = replaceFunc(blkh, str, isMasked)

    newStr = '';
    
%     get number of parameters
    k1 = findstr('''', str);
    leng = length(k1);
    if (leng < 4 || mod(leng,2) )
        return;
    else
         numParam = leng/2;
    end
        
    if (numParam > 2)
        % target DT = 'fidxt(''uint16'')' or similar
        k2 = findstr('''''', str); % find double prime
        k3 = setdiff(k1, [k2, k2+1]); % remove double prime
        L = length(k3); % # of single prime
        if ( L == 4 && length(k2) == 2 && k2(1) >k3(1) && k2(2)+1<k3(2) )
            str(k2(1)) = ' ';
            str(k2(2)+1) = ' ';
            k1 = k3;
        else 
            % parameters can not fit fixdt, no change
            return;
        end
    end

    % get the type and scale parameters
    unevaledTypeStr = strtrim(str(k1(1)+1:k1(2)-1));
    unevaledScaleStr = strtrim(str(k1(3)+1:k1(4)-1));
    
    % resolve type and scale for non-library block
    try 
        DT = slResolve(unevaledTypeStr, blkh, 'expression');
        isfullySpec = getdatatypespecs(DT, [], 0, 0, 3);
        Scaling = slResolve(unevaledScaleStr, blkh, 'expression');
        preRes = getdatatypespecs(DT, Scaling, 0, 0, 1);
    catch e
        disp(DAStudio.message('Simulink:fixedandfloat:slRmDTResolve', unevaledTypeStr, unevaledScaleStr, str, getfullname(blkh)));
        return;
    end

    if (isfullySpec) % type is fully-specified 
        % block is not under masked subsystem or DT is safe
        if ( isMasked == 0 || isSafeDTFunction(unevaledTypeStr))    
            newStr = unevaledTypeStr;
        end
    else
         % parse original DT and scale to migrate to the format that fixdt may take            
        [dtSign, dtBits, dtScaling] = parseStrforFixDT(unevaledTypeStr, unevaledScaleStr, max(size(Scaling)));
        if ~isequal(dtSign, '') 
            % params fit fixdt, replace str
            newStr = ['fixdt(', dtSign, ', ', dtBits, ', ', dtScaling, ')'];
            % get the resolution of original and new data type 
            try 
                curRes = slResolve(newStr, blkh);
            catch e
                newStr = '';
                return;
            end
            % check if they turn out to be the same
            if ( ~isResolutionEqual(preRes, curRes) )
                newStr = '';
                return;
            end
        end
    end

% check if dtStr is specified via sint, uint, sfrac, ufrac, float, or fixdt
function s = isSafeDTFunction(dtStr)

    funcName = getFunctionName(dtStr);
    if ( isempty(funcName) )
        s = 0;
        return;
    end
    
    switch funcName
        case 'fixdt'
            s = 1;
        case 'sint'
            s = 1;
        case 'uint'
            s = 1;
        case 'sfrac'
            s = 1;
        case 'ufrac'
            s = 1;
        case 'float'
            s = 1;
        otherwise
            s = 0;
    end
   
 % This is strict parsing without resolution to
 % migrate typeStr and scaleStr to the format that fixdt( ) may 
 % take; function takes original type, scale and number of parameters in
 % scaleStr; return sign, bit width and scaling for fixdt( ); 
 % sign == '' specifies migration to fixdt is not applicable
 % numSclParams = 0 avoids checking the number of parameters in scaleStr
 % Note: for scaleStr with two parameters, each element of parameter shall not
 % contain white-space. 
function [sign, bits, scale] = parseStrforFixDT( typeStr, scaleStr, numSclParams)
   
    sign = '';
    bits = '';
    scale = '';
    
    % work on typeStr for sign and bits of fixdt
    k1 = findstr(typeStr, '(');
    k2 = findstr(typeStr, ')');
    if ( ~isequal(length(k1),length(k2)) )
        % has unmatching number of paratheses
        return;
    end
    
    if ( isempty(k1) )
        % typeStr does not contain function call 
        return;
    end
    
    try
         num = length(k2);
        % typeStr is specified by a function such as sfix, ufix or fixdt            
        if isequal(getFunctionName(typeStr), 'ufix')
               sign = '0';
               bits = strtrim(typeStr(k1(1)+1:k2(num)-1));
        end
            
        if isequal(getFunctionName(typeStr), 'sfix')
               sign = '1';
               bits = strtrim(typeStr(k1(1)+1:k2(num)-1));
        end
            
             % the fixdt( , ) with two params 
        if isequal(getFunctionName(typeStr), 'fixdt')
               k3 = findstr(typeStr, ','); % comma position in typeStr
               L = length(k3);
               % at this point, migrate the fixdt( ) whose both params
               % conatin values, variables, expression, but not function 
            if ( L == 1 ) 
                 sign = strtrim(typeStr(k1(1)+1:k3(1)-1));
                  bits = strtrim(typeStr(k3(1)+1:k2(num)-1));
            end
        end

       % The cases not to be considered: not a function of sfix(b),
       % ufix(b), or fixdt(a,b)
        if (isequal(sign, ''))
            return;
        elseif ( numSclParams >= 3 ) % # of scaling parameter is over the limit for sl*
            sign = '';
            return;
        end

            
        % work on scaleStr for scaling param of fixdt
        scaling = scaleStr;
        num = length(scaling);
        counter = 1;
        
        if ( ~isempty(findstr(scaling, '[') ) ) 
            % param is represented by an array [a, b]
            % replace '[', ']' and ',' with ' ' in scaleStr
            for n = 1:num
                if ( isequal(scaling(n), ']') || isequal(scaling(n), '[') || isequal(scaling(n), ',') )
                    scaling(n) = ' ';
                end
            end
            params = strtrim(scaling);
        
             % add ',' to separate the parameters
            num = length(params);
            flag = 0;

            for n = 1:num
              if ( params(n) == ' ' && ~flag )
                  params(n) = ',';
                  flag = 1;
                  counter = counter+1;
              else 
                 if ( params(n) ~= ' ' && flag )
                    flag = 0;
                  end
              end    
            end
        else
            params = strtrim(scaling);
        end

        if (counter>=3)
            scale = '';  % sl* doesn't work with three params of scaling
        elseif ( numSclParams>0 && counter ~= numSclParams )
            % parsing mismatch
            scale = '';
        elseif ( counter == 2 )
            scale = convertScale4twoP(params);
        else % single scaling param
            scale = convertScale4oneP(params);
        end
            
        if ( isempty(scale) )
             sign = '';
        end
        
    catch e
        sign = '';
        e.rethrow;
        return
    end
    
% convert the single scaling param of sl* to that of fixdt()
% return '' if conversion should not be done
function scale = convertScale4oneP(str)
    
    if ( isempty(str) )
         scale  = '';
         return;
    end
     
    if ( isValueExpression(str) )   % numeric number
        value = -log2(str2num(str));
        if ( isequal(floor(value), value) )    % equal to power of 2
            scale = sprintf('%d', floor(value));
        else
            scale = [str, ', 0'];
        end
    else
        scale = [str, ', 0'];
    end
        
    
    % convert the two scaling parameters of sl* to that of fixdt()
    % return '' if conversion should not be done
 function scale = convertScale4twoP(str)
     
     k=findstr(str, ',');
     
     param1 = strtrim(str(1:k-1));
     param2 = strtrim(str(k+1:end));
     
     if ( isequal(param2, '0') )    % bias == 0
         scale = convertScale4oneP(param1);
     else
         scale = [param1, ', ', param2];
     end
     
% check if the str is an value expression contains only numbers [0-9] and math
% operator '+-*/^', '()', and white-space
function status = isValueExpression(str)
    
    status = 0;
    idx1 = regexp(str, '[\^\-.+*/() ]');
    idx2 = regexp(str, '[0-9]');
    
    if ( length(idx1)+length(idx2) == length(str) )
        status = 1;
    end
    
 % verify if two resolved variables or expressions end up with the same
 % values in terms of their all fields   
function isEq = isResolutionEqual( a, b )

    fields_a = fieldnames(a);
    fields_b = fieldnames(b);
    DTMode = 'DataTypeMode';
 
    isEq = 0;
    
    % deal with special case for slope is equal to a power of 2 value and
    % Bias is zero
    if ( ismember(DTMode, fields_a) && ismember(DTMode, fields_b) && ...
        strcmp(a.(DTMode), 'Fixed-point: binary point scaling') && ... 
        strcmp(b.(DTMode), 'Fixed-point: slope and bias scaling') )
        % the fields other than 'DataTypeMode' and 'FractionLength' need to
        % be the same for a and b
        a.DataTypeMode = 'Fixed-point: slope and bias scaling';
        if ( a.isContentEqual(b) )
            isEq = 1;
        end
        return;
    end
        
    % normal cases
    if ( a.isContentEqual(b) )
        isEq = 1;
    end
    return;

% display results on stdout
function showResults(res)
    
    L = length(res);
    for itemNum=1:L
        disp(res(itemNum));
    end
        
    
