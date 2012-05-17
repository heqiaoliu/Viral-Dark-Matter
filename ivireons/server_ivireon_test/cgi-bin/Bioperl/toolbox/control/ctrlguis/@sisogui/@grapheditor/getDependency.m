function CList = getDependency(this)
% Returns handle of compensators that the editor is dependent on

%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2005/11/15 00:51:28 $

L = this.LoopData.L(this.EditedLoop);

CList = [L.TunedFactors(:); L.TunedLFT.Blocks(:)];