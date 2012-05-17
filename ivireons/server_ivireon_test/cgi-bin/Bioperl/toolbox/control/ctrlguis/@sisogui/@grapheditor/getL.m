function [L,idxL] = getL(this)
% Returns handle and index of locally edited Loop.

%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2005/11/15 00:51:29 $
idxL = this.EditedLoop;
L = this.LoopData.L(idxL);