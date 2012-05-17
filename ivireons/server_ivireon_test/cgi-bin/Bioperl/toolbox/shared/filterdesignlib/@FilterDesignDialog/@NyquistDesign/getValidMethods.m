function validMethods = getValidMethods(this, varargin)
%GETVALIDMETHODS   Get the validMethods.

%   Author(s): J. Schickler
%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/04/21 04:23:02 $

hfdesign = get(this, 'FDesign');

try
    bandvalue = evaluatevars(this.Band);
catch
    
    % If we cannot evaluate the Band setting, assume that it is not 2.
    % This will disable the IRType popup and keep us from getting into a
    % bad state.
    bandvalue = 3;
end

set(hfdesign, 'Specification', getSpecification(this), 'Band', bandvalue);

if nargin > 1
    % if the short flag is provided, then output short names for design
    % methods.
    validMethods = designmethods(hfdesign, this.ImpulseResponse);
else
    % By dfault output the long names. 
    validMethods = designmethods(hfdesign, this.ImpulseResponse, 'full');
end

% Make sure that the methods are in the correct orientation for DDG.
validMethods = validMethods(:)';

% [EOF]
