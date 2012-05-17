function [d, isfull, type] = thisdesignmethods(this, varargin)
%THISDESIGNMETHODS   Return the valid design methods.

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:22:26 $

spec = get(this, 'CurrentSpecs'); 
if nargin > 1 
    if any(strcmpi(varargin{end}, set(this, 'Specification'))) 
        spec = feval(getconstructor(this, varargin{end})); 
        varargin(end) = []; 
    end 
end 

[d, isfull, type] = designmethods(spec, varargin{:});

% [EOF]
