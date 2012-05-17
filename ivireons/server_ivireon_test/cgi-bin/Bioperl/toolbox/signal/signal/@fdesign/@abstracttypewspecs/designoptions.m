function dopts = designoptions(this, method)
%DESIGNOPTIONS   Return the design options.

%   Author(s): J. Schickler
%   Copyright 2004-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2006/06/27 23:35:43 $

if nargin < 2,
    error(generatemsgid('notEnoughInputs'),...
        ['You must specify a design method in order to see available options.\n',...
        'To view a list of possible design methods use: designmethods(%s).'],inputname(1));
end

% Only try to call DESIGNOPTIONS on the specs if the method is valid.
if isdesignmethod(this, method)
    dopts = designoptions(this.CurrentSpecs, method);
else
    error(generatemsgid('invalidMethod'), ...
        '''%s'' is not a valid method for ''%s''.', upper(method), this.Specification);
end

% [EOF]
