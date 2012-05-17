function s = edit(Constr,Container)
%EDIT  Builds generic constraint editor. Should be overloaded by 
%      specific subclasses.

%   Copyright 1986-2008 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:32:33 $

ctrlMsgUtils.warning('Controllib:general:AbstractMethodMustBeOverloaded')
s = [];