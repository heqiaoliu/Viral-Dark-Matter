function applyDotLayout(uiID, tabID)

%   Copyright 2007-2009 The MathWorks, Inc.

    manager = DepViewer.DepViewerUIManager;
    
    ui      = manager.getUI(uiID);   
    if( ~ishandle(ui) ), return; end    
    tab     = ui.getTab(tabID);
    if( ~ishandle(tab) ), return; end
    
    depModel = tab.getApp().getModel();
    editorData = tab.getEditor().getEditorData();
    showFullPath = editorData.showFullPath;
    instanceView = editorData.showInstanceView;
   
    
    if( editorData.showHorizontal )
        layoutOrientation = 'LR';
    else
        layoutOrientation = 'TB';
    end

    depModel.beginChangeSet();
    
    %Generating the file used by graphviz to layout the dependency graph
    [dotFileName, depNodes, depEdges, edgemap] = loc_genDotFile(depModel, showFullPath, instanceView, layoutOrientation);
    
    %Calling graphviz and generating the output file containing the
    %updated node/edges coordinates (tree layout)
    plainFileName = loc_genPlainFile(dotFileName);
    
    %updating the dependency model coordinates with the data contained
    %in graphviz output file
    loc_updateModelCoords(depModel, depNodes, depEdges, edgemap, plainFileName); 
    
    depModel.commitChangeSet();

end


%% ===================================================================== %
function [dotFileName, depNodes, depEdges, edgemap] = loc_genDotFile(depModel, showFullPath, instanceView, layoutOrientation)  

    assert( strcmp(layoutOrientation, 'TB') || strcmp(layoutOrientation, 'LR') );

    dotFileName = [tempname, '.dot'];
    [fid, errmsg] = fopen(dotFileName, 'w');
    if fid == -1
        msgId = [loc_errmsg,'FileOpen'];
        error(msgId, 'findDependencies: Error creating file ''%s'': %s', dotFileName, errmsg);
    end  
    
    
    dotFileAsString = ['digraph G {', sprintf('\n')]; 
    dotFileAsString = [dotFileAsString, '  rankdir="', layoutOrientation, '"', sprintf('\n')];
    depChildren = depModel.getNodes();
    depNodes = find(depChildren, '-isa', 'DepViewer.DepNode');
    
    %sorting the nodes by name to have a consistent layout
    depNodeNames = cell(1, length(depNodes)); 
    for i=1:length(depNodes)
        depNodeNames{i} = depNodes(i).longname; 
    end
    [~, indx] = sort(depNodeNames);    
    depNodes = depNodes( indx );
    
    depEdges = find(depChildren, '-isa', 'DepViewer.Dependency');
    
    %writing the nodes
    for idx=1:length(depNodes)
        depNode = depNodes(idx);
        key = int32(idx);
        depNode.dotID = key;
        
        if(instanceView && showFullPath)
            % Don't show the longname for the top model
            if(depNode.getInDegree() == 0)
                label = depNode.shortname;
            else
                label = [depNode.longname, ' (', depNode.shortname, ')'];
            end % if
        else 
            label = depNode.shortname;
        end % if
             
        if(instanceView && isequal(depNode.configuredSimMode, 'Processor-in-the-loop (PIL)'))
            label = [label, ' [PIL]']; %#ok
        end %if             
                        
        if(instanceView && isequal(depNode.configuredSimMode, 'Software-in-the-loop (SIL)'))
            label = [label, ' [SIL]']; %#ok
        end %if             
                        
        assert(~isempty(key));
        assert(~isempty(label));
        
        depNode.displayLabel = label;
        
        dotFileAsString = [dotFileAsString, ' ', sprintf('%d', key), ' ',... 
                           ' [shape=box label="', loc_processNameForDotLabel(label), '"];', sprintf('\n')]; %#ok - mlint        
    end
    
    edgemap = spalloc(length(depNodes), length(depNodes), length(depEdges));
     
    %writing the dependencies
    for idx=1:length(depEdges)
        depEdge = depEdges(idx);
        sourceDepNode = depEdge.getStartElement();
        destDepNode = depEdge.getEndElement();

        assert(~isempty(sourceDepNode));
        assert(~isempty(destDepNode));

        sourceID = sourceDepNode.dotID;
        destID = destDepNode.dotID;
        
        edgemap(sourceID, destID) = idx;
        
        dotFileAsString = [dotFileAsString,...
                           ' ',...
                           sprintf('%d', sourceID),...
                           ' -> ', ...
                           sprintf('%d', destID),...
                           ' [arrowhead=none];',...
                           sprintf('\n')]; %#ok - mlint
    end % for
    
    dotFileAsString = [dotFileAsString, '}']; 
    fwrite(fid, dotFileAsString);
    fclose(fid);
end %loc_genDotFile

%% ===================================================================== %
function plainFileName = loc_genPlainFile(dotFileName)
    plainFileName = [tempname, '.plain'];
    
    status = callgraphviz('dot','-Tplain',dotFileName,'-o',plainFileName);   
    if status ~= 0
      msgId = [loc_errmsg,'GeneratingDot'];
      error(msgId, 'findDependencies: Error occurred while generating file ''%s''.', dotFileName);      
    end 
    delete(dotFileName);
end %loc_genPlainFile

%% ===================================================================== %
function isCollinear = loc_areThreeCollinear(Px,Py,index)
    isCollinear = 0;
    d1 = [Px(index+1) - Px(index), Py(index+1) - Py(index)];
    d2 = [Px(index+2) - Px(index), Py(index+2) - Py(index)];
    if (dot(d1, d2) < 0.001)
       isCollinear = 1; 
    end
end

%% ===================================================================== %
function isCollinear = loc_isCollinear(Px,Py)
    npts = size(Px);
    npts = npts(1);
    isCollinear = 1;
    for i=1:npts-2
       if (~loc_areThreeCollinear(Px,Py,i))
           isCollinear = 0;
           return;
       end
    end
end

%% ===================================================================== %
function [Qx, Qy] = loc_cubicBezier(Px,Py,n)
    % Px contains x-coordinates of control points [Px0,Px1,Px2,Px3]
    % Py contains y-coordinates of control points [Py0,Py1,Py2,Py3]
    % n is number of intervals

    % Equation of Bezier Curve, utilizes Horner's rule for efficient computation.
    % Q(t)=(-P0 + 3*(P1-P2) + P3)*t^3 + 3*(P0-2*P1+P2)*t^2 + 3*(P1-P0)*t + Px0

    nControlPts = size(Px);
    nControlPts = nControlPts(2);
    if (nControlPts <= 4 && loc_isCollinear(Px,Py))
        Qx(1) = Px(1);
        Qy(1) = Py(1);
        Qx(2) = Px(nControlPts);
        Qy(2) = Py(nControlPts);
        return;
    end
    
    if (nControlPts < 4)
        Qx = Px;
        Qy = Py;
        return;
    end
    
    segment = 0;
    for i=1:3:nControlPts
        if (i > nControlPts-3)
            continue;
        end
        
        Px0=Px(i);
        Py0=Py(i);
        Px1=Px(i+1);
        Py1=Py(i+1);
        Px2=Px(i+2);
        Py2=Py(i+2);
        Px3=Px(i+3);
        Py3=Py(i+3);

        cx3=-Px0 + 3*(Px1-Px2) + Px3;
        cy3=-Py0 + 3*(Py1-Py2) + Py3;
        cx2=3*(Px0-2*Px1+Px2); 
        cy2=3*(Py0-2*Py1+Py2);
        cx1=3*(Px1-Px0);
        cy1=3*(Py1-Py0);
        cx0=Px0;
        cy0=Py0;

        dt=1/n;
        Qx(1 + segment*n)=Px0; % Qx at t=0
        Qy(1 + segment*n)=Py0; % Qy at t=0
        for i=1:n  
            t=i*dt;
            Qx(i+1 + segment*n)=((cx3*t+cx2)*t+cx1)*t + cx0;
            Qy(i+1 + segment*n)=((cy3*t+cy2)*t+cy1)*t + cy0;    
        end
        segment = segment + 1;
    end
end

%% ===================================================================== %
function loc_updateModelCoords(~, depNodes, depEdges, edgeMap, plainFileName)
    [fid, errmsg] = fopen(plainFileName,'r');
    if fid == -1
          msgId = [loc_errmsg,'FileOpen'];
          msg = error(msgId, 'findDependencies: Error opening file ''%s'': %s', plainFileName, errmsg);
          error(msgId, msg);
    end 
     
    curLine = fgetl(fid);
    [graphScaleFactor, graphWidth, graphHeight] = ...
        strread(curLine,'graph %n %n %n','delimiter',' '); %#ok
    
    doRead=true;
    nodeIndex = 1;
    edgeIndex = 1;
    while doRead && (~feof(fid))
      curLine=fgetl(fid);
      
      % Handle line continuation characters
      while(loc_hasOddNumberOfBackslashAtEnd(curLine))
          assert(~feof(fid));
          nextLine = fgetl(fid);
          
          curLine = [curLine(1:(end - 1)), nextLine];
      end % while
      
      [entryType, curLine] = strtok(curLine); %#ok
      switch entryType
         case 'node'
             nodeData = textscan(curLine, '%d%n%n%n%n', 1);
             curDepNode = depNodes(nodeIndex);

             assert(nodeData{1} == curDepNode.dotID);

             curX = abs(nodeData{2}-nodeData{4}/2.0)*72;             
             curY = (graphHeight-nodeData{3});
             curY = abs(curY-nodeData{5}/2.0)*72;            
             curWidth = nodeData{4}*72;
             curHeight = nodeData{5}*72;  
             curDepNode.position = [curX, curY];
             curDepNode.size= [curWidth, curHeight];
             nodeIndex = nodeIndex+1;
         case 'edge'
             [edgeData, linePosition] = textscan(curLine, '%d%d%n', 1);
             curLine = curLine(linePosition:end);
             
             sourceNode = edgeData{1};
             destNode   = edgeData{2};
             numberOfPoints = edgeData{3};
             
             formatStr='';
             for i=1:numberOfPoints
                 formatStr=[formatStr, '%n%n'];
             end
             edgeData = textscan(curLine, formatStr, 1);
             
             curDepEdge = depEdges(edgeMap(sourceNode, destNode));

             assert(isequal(curDepEdge.getStartElement().dotID, sourceNode));
             assert(isequal(curDepEdge.getEndElement().dotID,   destNode));
             
             if (~isempty(curDepEdge))
                 xs = [];
                 ys = [];
                 for i=1:numberOfPoints
                     xs(i) = edgeData{i*2-1}*72;
                     ys(i) = (graphHeight - edgeData{i*2})*72;
                 end
                 [xs, ys] = loc_fixPoints(xs, ys, depNodes(sourceNode), depNodes(destNode));
                 [Qx, Qy] = loc_cubicBezier(xs, ys, 8);
                 sz = size(Qx);
                 sz = sz(2);
                 curDepEdge.path = MG.Path(Qx, Qy);
                 
                 % We need to provide a single method that will do both.
                 % Manual delta is set to [0 0] to signal that this is a
                 % first manual routing. It makes no sense to set
                 % manuallyRouted to 1 without setting manualDelta.
                 curDepEdge.manuallyRouted = 1;
                 curDepEdge.manualDelta = [0,0];
             end
             edgeIndex = edgeIndex+1;
         case 'stop'
            doRead = false;
         otherwise
            msgId = [msgIdPref_l,'InvalidToken'];
            msg   = sprintf('findDependencies: Invalid token ''%s'' not recognized.', entryType);
            warning(msgId, msg); %#ok
      end
    end  
    fclose(fid);
    delete(plainFileName);
end %loc_updateModelCoords

%% ===================================================================== %
function [xs,ys] = loc_fixPoints(xs, ys, sourceNode, destNode)
    if( eq(sourceNode, destNode) ), return; end
        
    sourceCenterX = sourceNode.position(1) + sourceNode.size(1)/2;
    sourceCenterY = sourceNode.position(2) + sourceNode.size(2)/2;
    
    destCenterX = destNode.position(1) + destNode.size(1)/2;
    destCenterY = destNode.position(2) + destNode.size(2)/2;  
    
    lengthNoFlip = loc_distance( xs(1), ys(1), sourceCenterX, sourceCenterY ) + loc_distance( xs(end), ys(end), destCenterX, destCenterY );
    lengthFlip   = loc_distance( xs(1), ys(1), destCenterX, destCenterY ) + loc_distance( xs(end), ys(end), sourceCenterX, sourceCenterY );
    
    if(lengthFlip < lengthNoFlip) 
        xs(:)=xs(end:-1:1); 
        ys(:)=ys(end:-1:1); 
    end   
     
end

%% ===================================================================== %
function dist = loc_distance(x1, y1, x2, y2)
    dist = sqrt(abs(x1-x2)^2 + abs(y2-y1)^2);
end

%% ===================================================================== %
function odd = loc_hasOddNumberOfBackslashAtEnd(line)
    odd = false;
    i = length(line);

    while((i > 0) && (line(i) == '\')) 
        odd = ~odd;
        i = i - 1;
    end % while
end % loc_hasOddNumberOfBackslashAtEnd

%% ===================================================================== %
function name = loc_processNameForDotLabel(name)
    name = strrep(name, '\', '\\');
    name = strrep(name, '"', '\"');
    name = strrep(name, sprintf('\n'), ' ');
end % loc_processNameForDot


%% ===================================================================== %
function msgIdPref = loc_errmsg()
   msgIdPref = 'Simulink:DependencyViewer:';
end %loc_errmsg 
