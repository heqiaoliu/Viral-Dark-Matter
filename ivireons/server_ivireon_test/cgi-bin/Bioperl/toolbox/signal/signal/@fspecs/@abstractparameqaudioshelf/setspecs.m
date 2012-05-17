function setspecs(this, varargin)
%SETSPECS   Set the specifications

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/01/20 15:35:40 $

%Set default values (different from the default fdesign.parameq equalizer
%values). If we don't do this, other default values are written into the
%object later on.
if nargin < 2
    this.FilterOrder = 2;
    this.F0 = 0;
    this.G0 = 10;
end

% Find strings in varargin
strs = varargin(cellfun(@ischar, varargin));

if ~isempty(intersect(strs,{'linear','squared'})),
    error(generatemsgid('invalidSpecs'),...
        'Specifications must be provided in dB for this response.');
end

aswfs_setspecs(this,varargin{:});

% [EOF]
