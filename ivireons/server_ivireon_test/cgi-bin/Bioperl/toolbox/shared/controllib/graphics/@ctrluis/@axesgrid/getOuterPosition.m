function Pos = getOuterPosition(this)
%getOuterPosition   gets axesgrid outer position.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2009/12/05 02:16:33 $

Pos = get(this.BackgroundAxes,'OuterPosition');
