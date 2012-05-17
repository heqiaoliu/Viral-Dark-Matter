function io_uniq = utFindJacobianMultIOs(~,io_combine)
% UTFINDJACOBIANMULTIOS  Compute the Jacobian data structure for all
% possible IO combinations.
%
 
% Author(s): John W. Glass 20-Jul-2005
% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2009/11/09 16:35:18 $

% Concatinate the names with the ports
for ct = length(io_combine):-1:1
    io_str{ct} = sprintf('%s-%d',io_combine(ct).Block,io_combine(ct).PortNumber); 
end

% Find the unique ports
[~,ind] = unique(io_str);
io_combine = copy(io_combine(ind));

for ct = length(io_combine):-1:1
    io_uniq(ct,1) = copy(io_combine(ct));
end

% Change the IO property to be input-output
set(io_uniq,'Type','inout')
set(io_uniq,'OpenLoop','off')
set(io_uniq,'Active','on')