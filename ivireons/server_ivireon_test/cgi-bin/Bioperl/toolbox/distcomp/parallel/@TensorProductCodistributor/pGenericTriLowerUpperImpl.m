function [LP, codistr] = pGenericTriLowerUpperImpl(codistr, LP, k, compareFcn)
% pGenericTriLowerUpperImpl A generic implementation of both tril and triu
% for the abstract TensorProductCodistributor class.
% 
% compareFcn is a function handle used to find the portion of the local part
% that can be disregarded. For tril, compareFcn is 'lt(row,col)', while 
% the compareFcn for triu is 'gt(row,col)'.
%
%   See also hTrilImpl, hTriuImpl

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/06/08 13:25:28 $
    
    gRows = codistr.globalIndices(1, labindex);
    gCols = codistr.globalIndices(2, labindex);
      
    for j = 1:length(gCols)
        drop = compareFcn(gRows, gCols(j)-k);
        LP(drop, j) = 0;
    end    
