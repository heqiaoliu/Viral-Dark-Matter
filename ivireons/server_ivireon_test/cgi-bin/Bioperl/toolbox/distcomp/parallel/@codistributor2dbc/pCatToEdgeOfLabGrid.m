function data = pCatToEdgeOfLabGrid(codistr, data, dim)
%pCatToEdgeOfLabGrid Concatenate input data along dimension to edge of lab grid 
% out = pCatToEdgeOfLabGrid(codistr, data, dim) concatenates data along the dimension dim
% to the edge of the lab grid in the dimension dim.  dim must be 1 or 2.
%
% For example, with a lab grid of [2, 3] and 'row' orientation, the layout of
% the labs in the lab grid is:
%     | 1 | 2 | 3 |
%     | 4 | 5 | 6 |
% In that case, out = pCatToEdgeOfLabGrid(codistr, data, 1) returns
% On lab 1: cat(1, data_on_lab1, data_on_lab2, data_on_lab3)
% On lab 4: cat(1, data_on_lab4, data_on_lab5, data_on_lab5)
% On labs 2, 3, 5 and 6: []
%
% Similarly, with the lab grid above, out = pCatToEdgeOfLabGrid(codistr, data, 2) 
% returns
% On lab 1: cat(2, data_on_lab1, data_on_lab4)
% On lab 2: cat(2, data_on_lab2, data_on_lab4)
% On lab 3: cat(2, data_on_lab3, data_on_lab5)
% On labs 4, 5 and 6: []

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/06/08 13:25:35 $

if dim <= 0 || dim > 2
    error('distcomp:codistributor2dbc:pProcessAlongDim:InvalidDimension', ...
          'Dimension must be 1 or 2.');
end

if codistr.LabGrid(dim) == 1
    % Nothing to do.  All labs are already on the edge of the lab grid in this
    % dimension.
    return;
end

if dim == 1
    proc = codistr.pLabindexToProcessorCol(labindex);
else % dim == 2
    proc = codistr.pLabindexToProcessorRow(labindex);
end

% Split communicators according to the proc values. Looking at our example
% above for dim = 1, the groups would be for labindices 1:3 and 4:6
splitter = distributedutil.CommSplitter(proc, labindex); %#ok<NASGU>
% labindex is now 1 for the lowest value of original lab index in each group.
% In our example, labs 1 and 4 are now both known as lab 1, labs 2 and 5
% now both known as labs 2, and labs 3 and 6 are now labs 3.

targetLab = 1;
data = gcat(data, dim, targetLab);
splitter = []; %#ok<NASGU> Undo communicator split.

end %End of iReduceAcrossLabs.
