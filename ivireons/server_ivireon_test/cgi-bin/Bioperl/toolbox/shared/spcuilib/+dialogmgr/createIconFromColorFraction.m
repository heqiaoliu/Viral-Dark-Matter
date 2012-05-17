function icon = createIconFromColorFraction(x,bg,fg)
%
    
%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:39:13 $ 
    
% Create an RGB icon from a matrix of values in the range [0,1].
% Interpolates between a background and a foreground color, both specified
% as 3-element RGB vectors, where a matrix value of 0 produces the
% background color and 1 produces the foreground color.

% Interp by color plane
% Allocate MxNx3 icon
sz = size(x);
icon = zeros([sz 3]);
for i=1:3
    % Interp between bg and fg by color plane
    icon(:,:,i) = x*fg(i) + (1-x)*bg(i);
end
end

