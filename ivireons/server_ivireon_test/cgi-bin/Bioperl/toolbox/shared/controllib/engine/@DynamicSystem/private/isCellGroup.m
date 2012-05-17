function [isCell,isVoid] = isCellGroup(Group1,Group2)
%ISCELLGROUP  Determine group format in binary ops

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:51:36 $
isCell1 = iscell(Group1);
isCell2 = iscell(Group2);
isVoid1 = ~isCell1 && isempty(fieldnames(Group1));
isVoid2 = ~isCell2 && isempty(fieldnames(Group2));

isCell = (isCell1 && isCell2) || (isCell1 && isVoid2) || ...
   (isCell2 && isVoid1);
isVoid = isVoid1 && isVoid2;

