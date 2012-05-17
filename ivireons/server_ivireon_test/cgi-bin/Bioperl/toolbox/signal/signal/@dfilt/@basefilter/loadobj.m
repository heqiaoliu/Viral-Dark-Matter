function this = loadobj(s)
%LOADOBJ   Load this object.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/26 22:03:44 $

this = feval(s.class);

% Fix old versions.
if isstruct(s) && ~isfield(s, 'version')
    s.version.number      = 0;
    s.version.description = 'R14';
end

loadreferencecoefficients(this, s);

% Set the arithmetic before the public interface in case subclasses have
% properties in the public interface which are actually in the arithmetic
% (the filter quantizers).
loadarithmetic(this, s);

loadpublicinterface(this, s);

% Load the private data after all public properties to make sure setting
% the public property doesn't overwrite the private settings.
loadprivatedata(this, s);

% Load the metadata last because it affects nothing.
loadmetadata(this, s);

% [EOF]
