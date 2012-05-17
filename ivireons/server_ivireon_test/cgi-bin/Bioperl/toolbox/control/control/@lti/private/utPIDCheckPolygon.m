function IsGoodPolygon = utPIDCheckPolygon(DCEL, Vertices, Edges, lineParameter, FlowDirection)
% Singular frequency based P/PI/PID/PIDF Tuning sub-routine.
%
%   This function checks the necessary condition of an inner polygon.
%

%   Author(s): Rong Chen
%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.8.2 $ $Date: 2007/03/28 21:36:32 $

IsGoodPolygon = true;
% loop through each edge of the polygon
for j=1:length(Edges)
    % find the line to which the edge belongs
    Line = DCEL(Edges(j)).Line;
    % if line is not a boundary, check flow condition
    if Line~=0 
        % get the line direction
        Vd = DCEL(Edges(j)).Vd;
        Vo = DCEL(Edges(j)).Vo;
        if Vd>0 && Vo>0
            LineDirection = sign((Vertices(Vd,:)-Vertices(Vo,:))*...
                [-lineParameter(Line,2) lineParameter(Line,1)]');
            % polygon is good if LineDirection * FlowDirection == -1 for all the edges
            if (LineDirection*FlowDirection(Line))==1
                IsGoodPolygon = false;
                break
            end
        else
            IsGoodPolygon = false;
            break
        end
    end
end
