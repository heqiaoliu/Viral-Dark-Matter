function cellAtt = CreateCellAttrib(indices, nrows, ncols)
% CreateCellAttrib(indices, nrows, ncols) - Creates cell attributes for 
% the results tables

%   Copyright 2003-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $ $Date: 2008/12/04 23:26:38 $

% Create the new color and font objects for the cell attributes;
color = java.awt.Color(int16(255),int16(238),int16(204));
font = java.awt.Font('',1,12);

% Create the cell attributes
col_combine = 0:ncols-1;
cellAtt = javaObjectEDT('com.mathworks.toolbox.control.tableclasses.DefaultCellAttribute',nrows,ncols);
% Combine rows and columns
for ct = 1:size(indices,1);
    if isa(indices,'double')
        row_combine = indices(ct,1);
    else
        row_combine = indices(ct,1).intValue;
    end
    cellAtt.combine(row_combine,col_combine);
    cellAtt.setBackground(color,row_combine,col_combine);
    cellAtt.setFont(font,row_combine,col_combine);
end
