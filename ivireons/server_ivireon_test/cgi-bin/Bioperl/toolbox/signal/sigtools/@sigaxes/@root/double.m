function n = double(h, varargin)
%DOUBLE Returns the double representation of the complex object

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2004/04/13 00:21:06 $

if nargin == 1,
    
    % Get the real and imaginary and convert them to a double.
    re = get(h, 'Real');
    im = get(h, 'Imaginary');
    
    if iscell(re), re = [re{:}]'; end
    if iscell(im), im = [im{:}]'; end
    
    n = re + im*i;
else
    
    % Find all the roots with no conjugates and those with conjugates.
    noc = find(h, 'Conjugate', 'Off');
    c   = find(h, 'Conjugate', 'On');
    
    noc = double(noc);
        
    if isempty(c)
        
        n = noc;
    else
        
        c = double(c);
        c = reshape([c conj(c)]', 1, 2*length(c))';
        n = [noc; c];
    end
end

% [EOF]
