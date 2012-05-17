function Str = getDisplayName(obj)
% return a nice display name for the object
% Protected method of idnlfun

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2007/06/07 14:44:06 $

% Author(s): Rajiv Singh.

Str = 'Abstract Nonlinear Estimator';
switch class(obj)
    case 'customnet'
        Str = 'Custom Network';
    case 'ridgenet'
        Str = 'Abstract Ridge Network';
    case 'sigmoidnet'
        Str = 'Sigmoid Network';
    case 'neuralnet'
        Str = 'Multi-Layer Neural Network';
    case 'unitgain'
        Str = 'Unit Gain';
    case 'linear'
        Str = 'Linear Function';
    case 'wavenet'
        Str = 'Wavenet';
    case 'treepartition'
        Str = 'Tree Partition';
    case 'saturation'
        Str = 'Saturation';
    case 'deadzone'
        Str = 'Dead Zone';
    case 'pwlinear'
        Str = 'Piece-wise Linear';
    case 'piecewise'
        Str = 'Abstract Piecewise';
    case  'poly1d'
    Str = 'One-dimensional polynomial estimator';
end
        
% FILE END

        