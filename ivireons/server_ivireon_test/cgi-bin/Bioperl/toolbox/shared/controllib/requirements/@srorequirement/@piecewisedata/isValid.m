function Valid = isValid(this)
%Check that constraint is a valid constraint

%   Author: A. Stothert 
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:35:40 $

%Extract data
xCoords = this.getData('xdata');
yCoords = this.getData('ydata');
Weight  = this.getData('Weight');
Linked  = this.getData('Linked');

Valid = true;
%Same number of X and Y coordinates
Valid = Valid && all(size(xCoords) == size(yCoords));
%Correct number of weights
Valid = Valid && size(xCoords,1) == numel(Weight);
%Correct number of links
Valid = Valid && size(Linked,1) == size(xCoords,1)-1;
      
