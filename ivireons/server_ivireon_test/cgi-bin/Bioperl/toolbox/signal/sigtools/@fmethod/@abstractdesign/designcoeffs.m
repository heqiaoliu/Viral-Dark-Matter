function varargout = designcoeffs(this, specs, varargin)
%DESIGNCOEFFS   Design the filter and return the coeffs.

%   Author(s): J. Schickler
%   Copyright 1999-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2007/12/14 15:17:32 $

if nargin < 2,
    % Create a default specifications object
    specs = feval(validspecobj(this));
end

% Allow subclasses to process the specifications.
specs = preprocessspecs(this, specs);

% Validate the specifications
[isvalid,errmsg,msgid] = validate(specs);
if ~isvalid,
    error(msgid,errmsg);
end

% Perform algorithm specific validation
[isvalid,errmsg,msgid] = validate(this,specs);
if ~isvalid,
    error(msgid,errmsg);
end

% Normalize the frequency specs. before designing
normalized = specs.NormalizedFrequency;
normalizefreq(specs);

% Try/Catch the subclass.  We do not know if they will error out and we
% will need to reset the normalizedFrequency property if they do.
try
    % Perform actual design
    [varargout{1:nargout}] = actualdesign(this,specs,varargin{:});
catch ME

    % Set frequency specs. back to what they were
    normalizefreq(specs,normalized);
    
    throwAsCaller(ME);
end

% Set frequency specs. back to what they were
normalizefreq(specs,normalized);

% [EOF]
