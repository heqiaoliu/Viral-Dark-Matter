function [DCEL, Vertices, PolygonE, PolygonV] = utPIDGetPolygon(lineParameter,xyBounds,ParTol,PlotNeeded)
% Singular frequency based P/PI/PID/PIDF Tuning sub-routine.
%
% This function finds all the minimal polygons defined by a set of lines and 
% a rectangle which by default contains all the intersections
%
%   input: 
%       - lineParameter, a N-by-3 real vector, represents N lines in the
%       implicit form: [a b c] -> ax + by + c = 0
%
%   optional inputs: 
%       - xyBounds, a 4-by-1 real vector, which is provided as a
%       user-defined rectangle boundary [xmin xmax ymin ymax].  This
%       boundary 
%       - ParTol, a positive real value, which is the tolerance to check if
%       two lines are parallel (true if abs(det([a1 b1;a2 b2]))<ParTol)
%       - PlotNeeded, a logical value, when it is true, a planar graph is
%       plotted with color patches
%  
%   output:
%       - DCEL, a (2*N^2+N*2+4)-by-1 structure array, which stores a planar
%       graph in the Doubly Connected Edge List (DCEL) format
%       - Vertices, a (N*(N-1)/2+2*N+4)-by-2 real matrix which
%       contains all the 2-D coordinates for vertices
%       - PolygonE, a (N*(N-1)/2+N+1)-by-1 cell array each cell contains a
%       vecter of edge indices that represents a polygon
%       - PolygonV, a (N*(N-1)/2+N+1)-by-1 cell array, each cell contains a
%       vecter of vertex indices that represents a polygon
%

%   Author(s): Rong Chen
%   Copyright 2006-2007 The MathWorks, Inc. 
%   $Revision: 1.1.6.5 $ $Date: 2007/12/14 14:25:37 $

%% initialization
if nargin<1 || isempty(lineParameter) 
    ctrlMsgUtils.error('Controllib:general:UnexpectedError','No line is defined.')
end
if nargin<2
    xyBounds = [];
end
if nargin<3 || isempty(ParTol) 
    ParTol = 1e-6;
end
if nargin<4 || isempty(PlotNeeded) 
    PlotNeeded = false;
end
% N is the number of lines
N = size(lineParameter,1);
% initialize output Vertices which stores coordinates for all the vertices
% its maximum number is N*(N-1)/2+2*N+4
Vertices = zeros(N*(N-1)/2+N*2+4,2);
% initialize Edge list in the DCEL format with twin information
% Vo: origin
% Vd: destination
% NextEdgeOnFace: next edge on the same face (counter clockwise)
% PrevEdgeOnFace: previous edge on the same face (counter clockwise)
% Twin: stores the index of its dual edge (0 when on the boundary)
% NextEdgeOnBox: next edge on the boundary (valid for boundary edge only )
% Line: the line it belongs to (0 when on the boundary)
% its maximum length is 2*N^2+2*N+4
DCEL = struct('Vo',cell(2*N^2+N*2+4,1),'Vd',[],'NextEdgeOnFace',[],'PrevEdgeOnFace',[],'Twin',[],'NextEdgeOnBox',[],'Line',[],'Polygon',[]);
% initialize polygon lists represented by Vertex and Edge respectively
% its maximum length is N*(N-1)/2+N+1, maximum width in each cell is N+4
PolygonV = cell(N*(N-1)/2+N+1,1);
PolygonE = cell(N*(N-1)/2+N+1,1);


%% find all the intersections between any pair of lines
% the number of intersections among lines is at most N*(N-1)/2
if isempty(xyBounds)
    xyBounds = findBoundary(lineParameter,N,ParTol);
end

%% Initialize planar graph {Vertices and Edges}
% initialize Vertices list
Vertices(1:4,:) = [xyBounds(2) xyBounds(4); xyBounds(1) xyBounds(4); xyBounds(1) xyBounds(3); xyBounds(2) xyBounds(3)];
ctVertices = 4;
% initialize DCEL list with the boundary
DCEL(1)=struct('Vo',1,'Vd',2,'NextEdgeOnFace',2,'PrevEdgeOnFace',4,'Twin',0,'NextEdgeOnBox',2,'Line',0,'Polygon',0);
DCEL(2)=struct('Vo',2,'Vd',3,'NextEdgeOnFace',3,'PrevEdgeOnFace',1,'Twin',0,'NextEdgeOnBox',3,'Line',0,'Polygon',0);
DCEL(3)=struct('Vo',3,'Vd',4,'NextEdgeOnFace',4,'PrevEdgeOnFace',2,'Twin',0,'NextEdgeOnBox',4,'Line',0,'Polygon',0);
DCEL(4)=struct('Vo',4,'Vd',1,'NextEdgeOnFace',1,'PrevEdgeOnFace',3,'Twin',0,'NextEdgeOnBox',1,'Line',0,'Polygon',0);
ctDCEL = 4;

%% loop through all the lines and create a planar graph
for LineNumber = 1:N
    % ---------------------------------------------------------------------
    % STEP 1. loop through the box edges and find the entering vertex.  
    % ---------------------------------------------------------------------    
    EnterEdgeNum = 1; % since Edge 1 is always on boundary
    EnterVertexNum = nan;
    signDest = localSign(lineParameter(LineNumber,:),Vertices(DCEL(EnterEdgeNum).Vo,:));  
    while true % guaranteed to return to the first edge
        % calculate the signs of Vo and Vd, which can be {-1, 0, 1}
        signOrig = signDest;
        signDest = localSign(lineParameter(LineNumber,:),Vertices(DCEL(EnterEdgeNum).Vd,:));  
        % deal with different cases how the line intersects with edge
        if signOrig == signDest
            % applying case: % [1 1], [-1 -1] and [0 0]
            % go to the next edge on the boundary (counter clockwise)
            EnterEdgeNum = DCEL(EnterEdgeNum).NextEdgeOnBox;
            % until edge 1 is reached
            if EnterEdgeNum == 1
                break
            end
        else
            % if there is a sign change, record the following information
            % EnterEdgeNum: on which edge the line enters
            % EnterVertexNum: on which vertex the line enters
            % if a new vertex is created, Vertices and its counter update
            [tEnter, EnterVertexNum] = findIntercept(DCEL,EnterEdgeNum,signOrig,signDest,lineParameter(LineNumber,:),Vertices);
            if (tEnter>0 && tEnter<1)
               ctVertices = ctVertices + 1;
               Vertices(ctVertices,:) = (1-tEnter)*Vertices(DCEL(EnterEdgeNum).Vo,:)+tEnter*Vertices(DCEL(EnterEdgeNum).Vd,:);
               EnterVertexNum = ctVertices;
            end	
            break;
        end
    end
    %  when the line does not cross any edge of the boundary, skip
    if isnan(EnterVertexNum)
        continue
    end
    % ---------------------------------------------------------------------
    % Step 2. insert lines into polygon one by one
    % ---------------------------------------------------------------------
    LeaveEdgeNum = NaN;
    while isnan(LeaveEdgeNum) || DCEL(LeaveEdgeNum).Twin~=0
        % traverse all the edges that belong to the face aassociated the
        % entering edge and calculate sign changes
        k = DCEL(EnterEdgeNum).NextEdgeOnFace;
        % if there is a sign change, record the following information
        % LeaveEdgeNum: on which edge the line leaves
        % LeaveVertexNum: on which vertex the line leaves
        LeaveEdgeNumCandidates = zeros(1,3);
        LeaveVertexNum = zeros(1,3);
        tLeave = zeros(1,3);
        % we also count the number of sign changes
        SignChangedCounter = 0;
        signDest = localSign(lineParameter(LineNumber,:),Vertices(DCEL(k).Vo,:));
        % loop through all the edges other than the entering one on the
        % face
        while k~=EnterEdgeNum
            % compute signs
            signOrig = signDest;
            signDest = localSign(lineParameter(LineNumber,:),Vertices(DCEL(k).Vd,:));        
            % deal with different cases how the line intersects with edge
            if signOrig ~= signDest
                SignChangedCounter = SignChangedCounter+1;
                LeaveEdgeNumCandidates(SignChangedCounter) = k;
                [t, LeaveVertexNum(SignChangedCounter)] = findIntercept(DCEL,k,signOrig,signDest,lineParameter(LineNumber,:),Vertices);
                % if exit in the middle of an edge, add a new vertex
                if (t>0 && t<1)
                   ctVertices = ctVertices + 1;
                   Vertices(ctVertices,:) = (1-t)*Vertices(DCEL(k).Vo,:)+t*Vertices(DCEL(k).Vd,:);
                   % store the values at the beginning of the arrays
                   LeaveVertexNum(1) = ctVertices;
                   LeaveEdgeNumCandidates(1) = k;
                   tLeave(1) = t;
                   break;
                else
                   tLeave(SignChangedCounter) = t;
                end
            end            
            k = DCEL(k).NextEdgeOnFace;
        end
        % find the exiting edge and vertex
        if (SignChangedCounter==3) && (tEnter==1)
            % enter at vertex (origin) and leave on a different vertex
            LeaveEdgeNum = LeaveEdgeNumCandidates(2);
            LeaveVertexNum = LeaveVertexNum(2);
            tLeave = tLeave(2);
        else
            % other cases
            LeaveEdgeNum = LeaveEdgeNumCandidates(1);
            LeaveVertexNum = LeaveVertexNum(1);
            tLeave = tLeave(1);
        end
        % split entering edge if necessary
        if tEnter==0
            % record the neighboring edges to the vertex
            enPrev = DCEL(EnterEdgeNum).PrevEdgeOnFace;
            enNext = EnterEdgeNum;
        elseif tEnter==1
            % record the neighboring edges to the vertex
            enPrev = EnterEdgeNum;
            enNext = DCEL(EnterEdgeNum).NextEdgeOnFace;
        else
            % split edge
            ctDCEL = ctDCEL+1;
            % add a new edge
            DCEL(ctDCEL) = DCEL(EnterEdgeNum);
            DCEL(EnterEdgeNum).Vd = EnterVertexNum;
            DCEL(EnterEdgeNum).NextEdgeOnFace = ctDCEL;
            DCEL(ctDCEL).Vo = EnterVertexNum;
            DCEL(ctDCEL).PrevEdgeOnFace = EnterEdgeNum;
            DCEL(DCEL(ctDCEL).NextEdgeOnFace).PrevEdgeOnFace = ctDCEL;            
            % if the edge is not on the boundary, update twin info for
            % both the new edge and their twin edges which were created
            % in the previous polygon traverse
            % TwinIndex stored the indices for the twin edges
            if DCEL(EnterEdgeNum).Twin>0
                DCEL(EnterEdgeNum).Twin = TwinIndex(2);
                DCEL(ctDCEL).Twin = TwinIndex(1);
                DCEL(TwinIndex(1)).Twin = ctDCEL;
                DCEL(TwinIndex(2)).Twin = EnterEdgeNum;
            % if the edge is on the boundary, update box info
            else
                DCEL(EnterEdgeNum).NextEdgeOnBox = ctDCEL;
            end
            % record the neighboring edges to the vertex
            enPrev = EnterEdgeNum;
            enNext = ctDCEL;
        end
        % split exiting edge if necessary
        if tLeave==0
            % record the neighboring edges to the vertex
            exPrev = DCEL(LeaveEdgeNum).PrevEdgeOnFace;
            exNext = LeaveEdgeNum;
        elseif tLeave==1
            % record the neighboring edges to the vertex
            exPrev = LeaveEdgeNum;
            exNext = DCEL(LeaveEdgeNum).NextEdgeOnFace;
        else
            % split edge
            ctDCEL = ctDCEL+1;
            % add a new edge
            DCEL(ctDCEL) = DCEL(LeaveEdgeNum);
            DCEL(LeaveEdgeNum).Vd = LeaveVertexNum;
            DCEL(LeaveEdgeNum).NextEdgeOnFace = ctDCEL;
            DCEL(ctDCEL).Vo = LeaveVertexNum;
            DCEL(ctDCEL).PrevEdgeOnFace = LeaveEdgeNum;
            DCEL(DCEL(ctDCEL).NextEdgeOnFace).PrevEdgeOnFace = ctDCEL;
            % if the edge is not on the boundary, save the twin edge info
            if DCEL(LeaveEdgeNum).Twin>0
                TwinIndex = [LeaveEdgeNum ctDCEL];
            % if the edge is on the boundary, update box info
            else
                DCEL(LeaveEdgeNum).NextEdgeOnBox = ctDCEL;
            end
            % record the neighboring edges to the vertex
            exPrev = LeaveEdgeNum;
            exNext = ctDCEL;
        end
        % add 2 new edges except when (1) the exit vertex is the same as
        % the enter vertex, (2) the two vertices share a same edge
        if ~(EnterVertexNum == LeaveVertexNum ||  enNext==exPrev || enPrev==exNext)
            ctDCEL = ctDCEL+2;
            % add two new edges
            DCEL(ctDCEL-1).Vo=EnterVertexNum;
            DCEL(ctDCEL-1).Vd=LeaveVertexNum;
            DCEL(ctDCEL-1).NextEdgeOnFace=0;
            DCEL(ctDCEL-1).PrevEdgeOnFace=0;
            DCEL(ctDCEL-1).Twin=ctDCEL;
            DCEL(ctDCEL-1).NextEdgeOnBox=0;
            DCEL(ctDCEL-1).Line=LineNumber;        
            DCEL(ctDCEL).Vo=LeaveVertexNum;
            DCEL(ctDCEL).Vd=EnterVertexNum;
            DCEL(ctDCEL).NextEdgeOnFace=0;
            DCEL(ctDCEL).PrevEdgeOnFace=0;
            DCEL(ctDCEL).Twin=ctDCEL-1;
            DCEL(ctDCEL).NextEdgeOnBox=0;
            DCEL(ctDCEL).Line=LineNumber;        
            % update Prev/NextEdgeOnFace properties for new/modified edges
            DCEL(enNext).PrevEdgeOnFace = ctDCEL;
            DCEL(ctDCEL).NextEdgeOnFace = enNext;
            DCEL(enPrev).NextEdgeOnFace = ctDCEL-1;
            DCEL(ctDCEL-1).PrevEdgeOnFace = enPrev;
            DCEL(exNext).PrevEdgeOnFace = ctDCEL-1;
            DCEL(ctDCEL-1).NextEdgeOnFace = exNext;
            DCEL(exPrev).NextEdgeOnFace = ctDCEL;
            DCEL(ctDCEL).PrevEdgeOnFace = exPrev;            
        end
        % traverse the dual face
        EnterEdgeNum = DCEL(LeaveEdgeNum).Twin;
        EnterVertexNum = LeaveVertexNum;
        tEnter = 1-tLeave;
    end % end of while
    %localPlotGraph(figure,N,DCEL,ctDCEL,Vertices);
end
if PlotNeeded
    localPlotGraph(figure,N,DCEL,ctDCEL,Vertices);
end

%% return polygons
Visited = false(1,ctDCEL);
ctPolygon = 0;                      % counter of polygons
faceV = zeros(1,N+4);
faceE = zeros(1,N+4);
% loop through all the edges
for ctEdge = 1:ctDCEL
    % if the edge is visited, skip
    % otherwise, use it as the first edge of a new face
    if ~Visited(ctEdge)
        ctPolygon = ctPolygon+1;
        ctFace = 0;
        Edge = ctEdge;
        % loop through the edges for this face until it goes back to 1
        while true
            ctFace = ctFace+1;
            faceV(ctFace) = DCEL(Edge).Vo;
            faceE(ctFace) = Edge;
            Visited(Edge) = true;            
            Edge = DCEL(Edge).NextEdgeOnFace;
            if Edge == ctEdge
                % remove unused space
                PolygonV{ctPolygon}=faceV(1:ctFace);
                PolygonE{ctPolygon}=faceE(1:ctFace);
                [DCEL(faceE(1:ctFace)).Polygon] = deal(ctPolygon);
                break;
            end
        end
    end
end
% remove unused space
DCEL = DCEL(1:ctDCEL);
PolygonV = PolygonV(1:ctPolygon);
PolygonE = PolygonE(1:ctPolygon);
Vertices = Vertices(1:ctVertices,:);

%----------------------------------------------------------------------
%% Subroutines
%----------------------------------------------------------------------
function p = getIntersectionLL(line1,line2,ParTol)
%% calculate intersection of two lines, coordinate returned
a = [line1;line2];
% check singularity
if abs(a(1,1)*a(2,2)-a(1,2)*a(2,1))<ParTol*norm(a(1,1:2))*norm(a(2,1:2))
    p = [];
else
    p = -(a(:,1:2)\a(:,3))';
end

function [t, p] = getIntersectionLE(Line,Start,End)
%% calculate intersection of a line and an edge, coordinate returned
% use localSign to check if either end of the edge is on the line
if localSign(Line,Start)==0
    t = 0;
    p = Start;
elseif localSign(Line,End)==0
    t = 1;
    p = End;
else
    ex = End(1)-Start(1);
    ey = End(2)-Start(2);    
    t = -(Line(1)*Start(1)+Line(2)*Start(2)+Line(3))/(Line(1)*ex+Line(2)*ey);
    p = Start + t*[ex ey];
    % make sure p is on the line for numerical accuracy
    if localSign(Line,p)~=0
        t = t - (Line(1)*p(1)+Line(2)*p(2)+Line(3))/(Line(1)*ex+Line(2)*ey);
        p = Start + t*[ex ey];
    end
end

function sign = localSign(Line,point)
%% sign function, return 0 if point is considered on the line 
x=point(1);
y=point(2);
a = Line(1);
b = Line(2);
c = Line(3);
% threshold
delta = 100*eps(abs(a*x)+abs(b*y)+abs(c));
phi = a*x+b*y+c;
if phi>delta
    sign = 1;
elseif phi<-delta
    sign = -1;
else
    sign = 0;
end

function [t, V] = findIntercept(DCEL,Edge,signOrig,signDest,Line,Vertices)
%% find the interception between a line and an edge
if signOrig == 0
    % Line passing Vo: [0 1] or [0 -1]
    t = 0;
    V = DCEL(Edge).Vo;
elseif signDest == 0
    % Line passing Vd: [1 0] or [-1 0]
    t = 1;
    V = DCEL(Edge).Vd;
else
    % Line passing between Vo and Vd: [1 -1] or [-1 1]
    % calculate the intersection
    t = getIntersectionLE(Line,Vertices(DCEL(Edge).Vo,:),Vertices(DCEL(Edge).Vd,:));
    V = 0;
end

function xyBounds = findBoundary(lineParameter,N,ParTol)
%% generate x-y boundary
if N>1
    % generate boundary if there are more than two lines
    MinV = [0 0]; % minx, miny
    MaxV = [0 0]; % maxx, maxy
    for i=1:N
        for j=i+1:N
            % get intersection between line i and j
            p = getIntersectionLL(lineParameter(i,:),lineParameter(j,:),ParTol);
            if ~isempty(p)
                MinV(1)=min(MinV(1),p(1));
                MaxV(1)=max(MaxV(1),p(1));
                MinV(2)=min(MinV(2),p(2));
                MaxV(2)=max(MaxV(2),p(2));
            end
        end
    end
    % generate boundary if there is at least one intersection
    if any([MinV MaxV]~=0)
        % calculate vertices for boundary
        Center = (MinV+MaxV)/2;
        Width = max(10,2*(MaxV-MinV)) ;
        MinXY = Center - Width;  % [xmin ymin]
        MaxXY = Center + Width;  % [xmax ymax]
        xyBounds = [MinXY(1) MaxXY(1) MinXY(2) MaxXY(2)];
    else
        % all the lines are parallel, a default box is used and user is
        % supposed to provide the bounding box.
        xyBounds = [-10 10 -10 10];
    end
else
    % if there is only one line, a default box is used and user is
    % supposed to provide the bounding box.
    xyBounds = [-10 10 -10 10];
end

function localPlotGraph(fig,N,DCEL,Num,Vertices)
%% planar graph plot
figure(fig);
hold on
color = (1:N*(N-1)/2+N+1)/(N*(N-1)/2+N+2);
DCEL = DCEL(1:Num);
DCELPatch = DCEL;
ct = 1;
i = 1;
Visited = true(1,Num);
while ~isempty(DCELPatch)
    k= DCELPatch(ct).NextEdgeOnFace;
    face = DCELPatch(ct).Vo;
    Visited(ct) = false;    
    while k ~= ct
        face = [face DCELPatch(k).Vo]; %#ok<AGROW>
        Visited(k) = false;            
        k = DCELPatch(k).NextEdgeOnFace;
    end
    patch(Vertices(face,1),Vertices(face,2),color(i));
    i = i+1;
    ct = find(Visited,true,'first');
    if isempty(ct)
        break;
    end
end
firstDual = true(1,Num);
for i=1:Num
    text(Vertices(DCEL(i).Vo,1),Vertices(DCEL(i).Vo,2),num2str(DCEL(i).Vo));                            
    if DCEL(i).Twin==0
        plot([Vertices(DCEL(i).Vo,1) Vertices(DCEL(i).Vd,1)],[Vertices(DCEL(i).Vo,2) Vertices(DCEL(i).Vd,2)]);
        text((Vertices(DCEL(i).Vo,1)+Vertices(DCEL(i).Vd,1))/2,(Vertices(DCEL(i).Vo,2)+Vertices(DCEL(i).Vd,2))/2,['e' num2str(i)]);
    else
        if firstDual(DCEL(i).Twin)
            firstDual(i) = false;
        else
            plot([Vertices(DCEL(i).Vo,1) Vertices(DCEL(i).Vd,1)],[Vertices(DCEL(i).Vo,2) Vertices(DCEL(i).Vd,2)]);
            text((Vertices(DCEL(i).Vo,1)+Vertices(DCEL(i).Vd,1))/2,(Vertices(DCEL(i).Vo,2)+Vertices(DCEL(i).Vd,2))/2,['e' num2str(DCEL(i).Twin) 'e' num2str(i)]);
        end
    end
end    

