function Pos = getOuterPosition(this)
%getOuterPosition   gets axespair outer position.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:15:57 $

% Get visible HG axes
HGAxes = getaxes(this);

idx = 1;
for ct = 1:length(HGAxes)
    if strcmpi(get(HGAxes(ct),'Visible'),'on')
        tmpPos = get(HGAxes(ct),'OuterPosition');
        PosCorners(idx,:) = [tmpPos(1),tmpPos(2),tmpPos(1)+tmpPos(3),tmpPos(2)+tmpPos(4)];
        idx = idx+1;
    end
end

Corners = [min(PosCorners(:,1)),min(PosCorners(:,2)),max(PosCorners(:,3)),max(PosCorners(:,4))];
Pos = [Corners(1),Corners(2),Corners(3)-Corners(1),Corners(4)-Corners(2)];
