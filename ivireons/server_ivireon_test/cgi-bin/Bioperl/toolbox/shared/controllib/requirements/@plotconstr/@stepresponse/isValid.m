function Valid = isValid(this)
%Check that constraint is a valid step response constraint

%   Author: A. Stothert 
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:33:56 $

Valid = true;

%Check for 5 (2 upper, 3 lower) X and Y coordinates
Valid = Valid && all(size(this.Data.getData('xData')) == [5,2]);
if Valid
   Valid = Valid && all(size(this.Data.getData('yData')) == [5,2]);
end
%Correct number of weights
if Valid
   Valid = Valid && 5 == numel(this.Data.getData('Weight'));
end
%Correct number of links
if Valid
   Linked = this.Data.getData('Linked');
   Valid = Valid && numel(Linked) == 8 && Linked(2,2)==false;
end


      
