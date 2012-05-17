function checkForSameSizeAndClass(X,Y,fcnName)
%checkForSameSizeAndClass used by immultiply,imdivide,imabsdiff
%   private function to check that X and Y have the same size and class.
    
% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2007/11/09 20:21:13 $
    
if ~strcmp(class(X),class(Y))
    eid = sprintf('Images:%s:mismatchedClass', fcnName);
    error(eid, 'X and Y must have the same class.');
end

if ~isequal(size(X),size(Y))
    eid = sprintf('Images:%s:mismatchedSize', fcnName);
    error(eid, 'X and Y must be the same size.');
end
