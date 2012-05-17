function outValue = num2fixpt( OrigValue, FixPtDataType, FixPtScaling, ...
                               RndMeth, DoSatur )
%  NUM2FIXPT  Quantize a value using a Simulink Fixed Point representation.
%   Usage:
%     outValue = num2fixpt(OrigValue,FixPtDataType,FixPtScaling,RndMeth,DoSatur);
%   Inputs:
%   OrigValue      real world value represented using floating point doubles.
%   FixPtDataType  fixed point data type specified using fixdt
%   FixPtScaling   if FixPtDataType specifies scaling, such as fixdt(1,8,3),
%                  then FixPtScaling is ignored.
%                  if FixPtDataType has unspecified scaling, such as fixdt(1,8),
%                  then FixPtScaling provides scaling: Slope or [Slope Bias]
%   RndMeth        rounding toward: 'Zero','Nearest','Ceiling', or 'Floor' [default]
%                  if FixPtDataType is FLOAT, then RndMeth ignored.
%   DoSatur        saturate to min or max on overflow: 'on' or 'off' [default]
%                  if FixPtDataType is FLOAT, then DoSatur ignored.
%   Output:
%   outValue       real world value of OrigValue after quantization to specified
%                  data type and scaling.  If overflows occur, even with
%                  saturation on, outValue and OrigValue can be very different.
%
%   Examples:
%
%   num2fixpt( pi, fixdt(1,8,5), [], 'Nearest', 'on' )
%   num2fixpt( 500/3, fixdt(0,8), [1 0], 'Zero', 'off' )
%
%   See also FI, FIXDT, FIXPTBESTPREC, FIXPTBESTEXP

% Copyright 1994-2009 The MathWorks, Inc.
% $Revision: 1.8.2.4 $  
% $Date: 2009/09/09 21:39:50 $

if nargin < 3
    FixPtScaling = [1 0];
end
if nargin < 2
    DAStudio.error('Simulink:fixedandfloat:numInputArg');
end

%
% get the data type specs
%
%dtv = DataTypeSpecs(    FixPtDataType, FixPtScaling );
dtv = getdatatypespecs( FixPtDataType, FixPtScaling, -1, 0 );
%
% get a boolean for the saturation mode
%
if nargin < 5
    %
    % default no saturation
    %
    boolDoSatur = 0;   
else
    if ischar(DoSatur)
        if strcmp(DoSatur,'on')
            boolDoSatur = 1;   
        else
            boolDoSatur = 0;   
        end                
    else
        boolDoSatur = ~(~DoSatur);   
    end
end
%
% get the integer for the rounding method
%
ROUND_ZERO  = 0;
ROUND_NEAR  = 1;
ROUND_CEIL  = 2;
ROUND_FLOOR = 3;
%
if nargin < 4
    %
    % default
    %
    iRndMeth = ROUND_FLOOR;   
else
    switch lower(RndMeth(1)) 
    case 'z'    
        iRndMeth = ROUND_ZERO;   
    case 'n'    
        iRndMeth = ROUND_NEAR;   
    case 'c'    
        iRndMeth = ROUND_CEIL;   
    otherwise    
        iRndMeth = ROUND_FLOOR;   
    end
end
    
if isreal(OrigValue)
    outValue = num2fix(OrigValue,...
                   dtv(1),dtv(2),dtv(3),dtv(4),dtv(5),dtv(6),...
                   iRndMeth,boolDoSatur);
else
    re_outValue = num2fix(real(OrigValue),...
                   dtv(1),dtv(2),dtv(3),dtv(4),dtv(5),dtv(6),...
                   iRndMeth,boolDoSatur);
    im_outValue = num2fix(imag(OrigValue),...
                   dtv(1),dtv(2),dtv(3),dtv(4),dtv(5),dtv(6),...
                   iRndMeth,boolDoSatur);
    outValue = complex(re_outValue,im_outValue);
end
