function Pos = getOuterPosition(this)
%getOuterPosition   gets axes outer position.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:14:38 $

Pos = get(this.Axes2d,'OuterPosition');
