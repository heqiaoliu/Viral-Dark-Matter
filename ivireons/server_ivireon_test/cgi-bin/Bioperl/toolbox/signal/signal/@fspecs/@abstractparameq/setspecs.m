function setspecs(this, varargin)
%SETSPECS   Set the specifications

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/10/18 03:25:26 $

% Find strings in varargin
strs = varargin(cellfun(@ischar, varargin));

if ~isempty(intersect(strs,{'linear','squared'})),
    error(generatemsgid('invalidSpecs'),...
        'Specifications must be provided in dB for this response.');
end
aswfs_setspecs(this,varargin{:});

% [EOF]
