function dataType = slDataTypeAndScale(unevaledContainerTypeStr, unevaluedScalingStr, context)
%  SLDATATYPEANDSCALE compatibility support for Simulink data type parameters
%
%   This function maps a container type and, if needed, fixed-point scaling to
%   a fully specified data type. The purpose of this function is to support
%   backwards compatibility of Simulink models. This function is intended
%   for use only within parameters on Simulink block dialogs.
% 
%   To remove unnecessary calls to SLDATATYPEANDSCALE within a Simulink model 
%   and replace them with an equivalent built-in or user-defined
%   fully-specified data type, e.g. fixdt, use SLREMOVEDATATYPEANDSCALE.
%
%   Usage
%    dataType = slDataTypeAndScale( unevaledContainerTypeStr, unevaluedScalingStr )    
%    dataType = slDataTypeAndScale( unevaledContainerTypeStr, unevaluedScalingStr, context )    
%
%   In older versions of Simulink, some blocks specified
%   a data type using multiple dialog parameters.  These parameters could 
%   include a data type edit parameter and a scaling edit parameter.  
%   Current versions of these blocks have combined the multiple parameters
%   into just one parameter.  SLDATATYPEANDSCALE supports backwards
%   compatibility in the face of this parameter count reduction.
%   SLDATATYPEANDSCALE takes the contents of the old data type and scaling
%   edit fields as its first and second arguments, respectively.  The first
%   argument specifies the container type and possibly the scaling too.  
%   If the first argument does not provide scaling, then the scaling is
%   obtained from the second argument.
%
%   Simulink block parameters are generally stored as strings.  These
%   parameters are passed to this function as unevaluated strings for two
%   reasons.  First, the parameter strings may contain comments at the end.
%   Passing the original parameter as an unevaluated string prevents
%   errors due to end comments.  The second reason is that 
%   evaluating the parameters can cause errors. SLDATATYPEANDSCALE only uses
%   the second argument conditionally.  Passing this argument as a string avoids
%   needless evaluation errors. This string will be evaluated only if it is really 
%   needed.
%
%   The old data type and scaling arguments are resolved in the context of CONTEXT
%   if CONTEXT is provided. Otherwise, they are evaluated in the caller's workspace.
% 
%   Example 1: needs the scaling and returns fixdt(1,16,7)
%
%     slDataTypeAndScale( 'fixdt(1,16)', '2^-7' )
%
%   Example 2: ignores the scaling and returns fixdt(1,16,9)
%
%     slDataTypeAndScale( 'fixdt(1,16,9)', '2^-7' )
%   
%   Example 3: ignores the scaling and returns 'single'
%
%     slDataTypeAndScale( '''single''', 'bad text' )
%
%   See also slRemoveDataTypeAndScale.

% Copyright 2006-2009 The MathWorks, Inc.
% $Revision: 1.1.6.6 $  
% $Date: 2009/05/14 17:50:32 $

if nargin < 3
    containerType = evalin('caller', unevaledContainerTypeStr);
else
    containerType = slResolve(unevaledContainerTypeStr, context);
end
dataTypeDeterminesScaling = getdatatypespecs(containerType,[],0,0,3);

if dataTypeDeterminesScaling
    
    dataType = containerType;    

else
    if (nargin < 3)
        scaling = evalin('caller',unevaluedScalingStr);
    else
        scaling = slResolve(unevaluedScalingStr, context);
    end
    dataType = getdatatypespecs(containerType,scaling,0,0,1);
end    
