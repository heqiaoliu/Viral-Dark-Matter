function this = loadobj(s)
%LOADOBJ   Load this object.

%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/05/31 23:15:14 $

% Constructs a new object this of class s.class
this = feval(s.class);

if ~isstruct(s)
    % If s is an object, store its properties into the fields of a structure s.
    % Useful when copying an object, and certain read-only properties
    % cannot be copied: they are then removed via rmfield.
    s = get(s);
else
    % If s is a structure, remove its field 'class'. 
    % Useful when loading an object stored as a structure in a .mat file,
    % which contains a 'class' field (so that s.class evaluates to the
    % correct class name).
    s = rmfield(s, 'class');
end

% Remove the 'SpectrumType' field from the structure s, because the
% 'SpectrumType' property of the corresponding object this is read-only, and
% cannot be written to.
s = rmfield(s, 'SpectrumType');

% Copy the remaining fields of s to the properties of the object this.
set(this, s);
