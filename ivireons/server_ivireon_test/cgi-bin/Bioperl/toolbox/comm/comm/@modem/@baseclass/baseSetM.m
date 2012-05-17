function M = baseSetM(h, M)
%BASESETM Validate common properties of M for object H.

%   @modem/@baseclass

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/05/06 15:46:48 $

% Check that M is a real scalar positive integer
if ( ~isnumeric(M) || isinf(M) || isnan(M) || (M==1) )
    error([getErrorId(h) ':InvalidM'], 'M must be an integer greater than 1.');
end

if ( isa(h, 'modem.abstractMod') )
    % Check that if InputType is Bit, M should be of the form 2^K
    if ( strcmp(h.InputType, 'Bit') && (ceil(log2(M)) ~= log2(M)))
        error([getErrorId(h) ':InvalidBitM'], ['When InputType is ''Bit'', M ' ...
            'must be in the form of M = 2^K,\nwhere K is a positive integer']);
    end
else
    % Check that if OutputType is Bit, M should be of the form 2^K
    if ( strcmp(h.OutputType, 'Bit') && (ceil(log2(M)) ~= log2(M)))
        error([getErrorId(h) ':InvalidBitM'], ['When OutputType is ''Bit'', M ' ...
            'must be in the form of M = 2^K,\nwhere K is a positive integer']);
    end
end

%-------------------------------------------------------------------------------
% [EOF]
