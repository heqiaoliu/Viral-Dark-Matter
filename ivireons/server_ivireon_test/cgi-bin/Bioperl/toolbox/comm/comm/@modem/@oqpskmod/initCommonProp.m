function h = initCommonProp(h, refObj)
%INITCOMMONPROP Initialize common properties 
%   between object H and object REFOBJ

%   @modem/@oqpskmod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/14 15:03:37 $

% Common properties that need to be copied in the correct order
% e.g. SymbolOrder should be set before SymbolMapping
dstFieldNames = {'M', ...
    'PhaseOffset', ...
    'SymbolOrder', ...
    'SymbolMapping', ...
    'InputType'};

baseInitCommonProp(h, dstFieldNames, refObj);

%-------------------------------------------------------------------------------
% [EOF]