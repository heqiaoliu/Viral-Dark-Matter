function h = initCommonProp(h, refObj) %#ok
%INITCOMMONPROP Initialize common properties 
%   between object H and object REFOBJ

%   @modem/@dpskmod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/06 15:47:18 $

% Common properties that need to be copied in the correct order
% e.g. SymbolOrder should be set before SymbolMapping
dstFieldNames = {'M', ...
    'PhaseRotation', ...
    'SymbolOrder', ...
    'SymbolMapping', ...
    'InputType', ...
    'InitialPhase'};

baseInitCommonProp(h, dstFieldNames, refObj);

%-------------------------------------------------------------------------------
% [EOF]