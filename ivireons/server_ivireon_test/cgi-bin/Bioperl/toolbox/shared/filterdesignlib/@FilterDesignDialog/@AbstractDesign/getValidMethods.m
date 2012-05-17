function validMethods = getValidMethods(this, varargin)
%GETVALIDMETHODS   Get the validMethods.
%By default this function returns the full names for design methods. If the
%'short' flag is provided then this returns the short names.

%   Author(s): J. Schickler
%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2009/12/05 02:22:16 $

validMethods = [];
hfdesign = getFDesign(this, this);
s = getSpecification(this);
if isempty(hfdesign)
    sEntries = [];
else
    sEntries = set(hfdesign, 'Specification');
end

if any(strcmpi(s,sEntries)),
    % If the spec that is loaded requires a Filter Design Toolbox license
    % that is no longer available, skip this part and return empty.
    set(hfdesign, 'Specification', s);
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
end


% [EOF]
