function createDoubleArrow(hThis,varargin)
% Create and set up a scribe double arrow

%   Copyright 2006 The MathWorks, Inc.

% Since we cannot call super() from UDD, call a helper-method:
% Don't send varargin here, but rather call this method for setup purposes
hThis.createScribeObject1D;

hThis.ShapeType = 'doublearrow';

% Angle of arrow
dx = hThis.X(2) - hThis.X(1);
dy = hThis.Y(2) - hThis.Y(1);
theta = atan2(dy,dx);
costh = cos(theta); sinth = sin(theta);
% length of whole arrow in normal and pixel coords
nx = hThis.X;
ny = hThis.Y;
nlength = sqrt((abs(hThis.X(1) - hThis.X(2)))^2 + (abs(hThis.Y(1) - hThis.Y(2)))^2);
hFig = ancestor(hThis,'Figure');
R1 = hgconvertunits(hFig,[0 0 nx(1) ny(1)],'normalized','pixels',hFig);
R2 = hgconvertunits(hFig,[0 0 nx(2) ny(2)],'normalized','pixels',hFig);
px = [R1(3) R2(3)];
py = [R1(4) R2(4)];
plength = sqrt((diff(px)).^2 + (diff(py)).^2);
% frational (frx of whole arrow length) Head lengths and widths
Head1FLength = hThis.Head1Length/plength;
Head1FWidth = hThis.Head1Width/plength;
Head2FLength = hThis.Head2Length/plength;
Head2FWidth = hThis.Head2Width/plength;
% unrotated x,y,z vectors for line part
x = [0, nlength*(1 - Head2FLength)];
y = [0, 0];
z = [0, 0];
% Rotate by theta and translate by hThis.X(1),hThis.Y(1).
xx = x.*costh - y.*sinth + hThis.X(1);
yy = x.*sinth + y.*costh + hThis.Y(1);
% create a tail
hThis.TailHandle = hg.line('xdata',xx,'ydata',yy,'zdata',z,...
    'Parent',double(hThis),'Interruptible','off','HandleVisibility','off',...
    'HitTest','off');

% Head 1
% unrotated x,y,z vectors for arrow
x = nlength.*[Head1FLength, 0, Head1FLength];
y = nlength.*[Head1FWidth/2, 0, -Head1FWidth];
z = [0, 0, 0];

% Rotate by theta and translate by hThis.X(1),hThis.Y(1).
xx = x.*costh - y.*sinth + hThis.X(1);
yy = x.*sinth + y.*costh + hThis.Y(1);

% Create Head1 - ignoring style and everything for now.
hThis.Head1Handle = hg.patch('xdata',xx,'ydata',yy,'zdata',z,...
    'parent',double(hThis),'Interruptible','off','HandleVisibility','off',...
    'HitTest','off');

% Head 2
% unrotated x,y,z vectors for arrow
x = nlength.*[1-Head2FLength, 1, 1-Head2FLength];
y = nlength.*[Head2FWidth/2, 0, - Head2FWidth/2];
z = [0, 0, 0];

% Rotate by theta and translate by hThis.X(1),hThis.Y(1).
xx = x.*costh - y.*sinth + hThis.X(1);
yy = x.*sinth + y.*costh + hThis.Y(1);
% Create Head2 - ignoring style and everything for now.
hThis.Head2Handle = hg.patch('xdata',xx,'ydata',yy,'zdata',z,...
    'parent',double(hThis),'Interruptible','off','HandleVisibility','off',...
    'HitTest','off');

% The Selection Handles must always be on top in the child order:
hChil = findall(double(hThis));
set(hThis,'Children',[hChil(5:end);hChil(2:4)]);

% Define the properties which should listen to the "Color" property
hThis.ColorProps{end+1} = 'TailColor';
hThis.ColorProps{end+1} = 'Head1Color';
hThis.ColorProps{end+1} = 'Head2Color';

% Set the Edge Color Property to correspond to the "Color" property of the
% line.
hThis.EdgeColorProperty = 'Color';
hThis.EdgeColorDescription = 'Color';

% Set the Face Color Property to correspond to the "Color" property of the
% line.
hThis.FaceColorProperty = 'HeadColor';
hThis.FaceColorDescription = 'Head Color';

% Install a property listener on the values which cause the "Position"
% property to update:
props = hThis.findprop('Position');
props(end+1) = hThis.findprop('Head1Style');
props(end+1) = hThis.findprop('Head1BackDepth');
props(end+1) = hThis.findprop('Head1RosePQ');
props(end+1) = hThis.findprop('Head1HypocycloidN');
props(end+1) = hThis.findprop('Head1Length');
props(end+1) = hThis.findprop('Head1Width');
props(end+1) = hThis.findprop('Head1Size');
props(end+1) = hThis.findprop('Head2Style');
props(end+1) = hThis.findprop('Head2BackDepth');
props(end+1) = hThis.findprop('Head2RosePQ');
props(end+1) = hThis.findprop('Head2HypocycloidN');
props(end+1) = hThis.findprop('Head2Length');
props(end+1) = hThis.findprop('Head2Width');
props(end+1) = hThis.findprop('Head2Size');
l = handle.listener(hThis,props, ...
    'PropertyPostSet', @localChangePosition);
hThis.PropertyListeners(end+1) = l;

% Set the "HeadColorMode" property to "auto"
hThis.HeadColorMode = 'auto';

% Update the head patch data
evd.affectedObject = hThis;
localChangePosition([],evd);

% Set properties passed by varargin
set(hThis,varargin{:});

%---------------------------------------------------------------------%
function localChangePosition(hProp,eventData) %#ok
% Update the line data to be in line with the position

hThis = eventData.affectedObject;
if ~hThis.UpdateInProgress
    hThis.UpdateInProgress = true;
    hFig = ancestor(hThis,'Figure');
    R1 = hgconvertunits(hFig,[0 0 hThis.X(1) hThis.Y(1)],'normalized','points',hFig);
    R2 = hgconvertunits(hFig,[0 0 hThis.X(2) hThis.Y(2)],'normalized','points',hFig);
    PX = [R1(3) R2(3)];
    PY = [R1(4) R2(4)];

    % Angle of arrow
    dx = PX(2) - PX(1);
    dy = PY(2) - PY(1);
    theta = atan2(dy,dx);
    costh = cos(theta);
    sinth = sin(theta);
    % length of whole arrow in points
    PAL = sqrt((abs(PX(1) - PX(2)))^2 + (abs(PY(1) - PY(2)))^2);

    % unrotated x,y,z vectors for line part
    L = hThis.Head1Length;
    switch (hThis.Head1Style)
        case 'none'
            x1 = 0;
        case {'plain','diamond','fourstar','ellipse','rectangle','rose'}
            x1 = L;
        case {'vback1','vback2','vback3'}
            d = [.15,.35,.8]; b = {'vback1','vback2','vback3'};
            x1 = (1 - d(strcmp(b,hThis.Head1Style)))*L;
        case {'cback1','cback2','cback3'}
            d = [.1,.25,.6]; b = {'cback1','cback2','cback3'};
            x1 = (1 - d(strcmp(b,hThis.Head1Style)))*L;
        case 'hypocycloid'
            N = hThis.Head1HypocycloidN;
            % odd number doesn't get rotated
            % already points away
            % meets tail in one of its concavities
            if mod(N,2)>0
                x1 = ((N-1)/N)*L;
            else
                x1 = L;
            end
        case 'astroid'
            x1 = L;
        case 'deltoid'
            x1 = 2*L/3;
    end

    L = hThis.Head2Length;
    switch (hThis.Head2Style)
        case 'none'
            x2 = PAL;
        case {'plain','diamond','fourstar','ellipse','rectangle','rose'}
            x2 = PAL - L;
        case {'vback1','vback2','vback3'}
            d = [.15,.35,.8]; b = {'vback1','vback2','vback3'};
            x2 = PAL - (1 - d(strcmp(b,hThis.Head2Style)))*L;
        case {'cback1','cback2','cback3'}
            d = [.1,.25,.6]; b = {'cback1','cback2','cback3'};
            depth = d(strcmp(b,hThis.Head2Style));
            dfromend = (1 - depth)*(L/PAL);
            x2 = PAL*(1 - dfromend);
        case 'hypocycloid'
            N = hThis.Head2HypocycloidN;
            % odd number doesn't get rotated
            % already points away (with a -1*x flip at this end)
            % meets tail in one of its concavities
            if mod(N,2)>0
                x2 = PAL - (((N-1)/N)*L);
            else
                x2 = PAL - L;
            end
        case 'astroid'
            x2 = PAL - L;
        case 'deltoid'
            x2 = PAL - (2*L/3);
    end

    x = [x1,x2];
    y = [0, 0];
    % Rotate by theta and translate by hThis.X(1),hThis.Y(1).
    xx = x.*costh - y.*sinth + PX(1);
    yy = x.*sinth + y.*costh + PY(1);

    % Convert to normalized units
    norm1 = hgconvertunits(hFig,[xx(1) yy(1) 0 0],'points','normalized',hFig);
    norm2 = hgconvertunits(hFig,[xx(2) yy(2) 0 0],'points','normalized',hFig);
    
    xx = [norm1(1) norm2(1)];
    yy = [norm1(2) norm2(2)];
    
    set(double(hThis.TailHandle),'xdata',xx,'ydata',yy);

    % unrotated x,y,z vectors for arrow head 1
    L = hThis.Head1Length;
    W = hThis.Head1Width/2;
    switch (hThis.Head1Style)
        case 'plain'
            x = [L, 0, L];
            y = [W, 0, -W];
        case {'vback1','vback2','vback3'}
            narrowfrx = .75;
            d = [.15,.35,.8]; b = {'vback1','vback2','vback3'};
            depth = d(strcmp(b,hThis.Head1Style));
            x = [L,0; 0,L; L*(1-depth),L*(1-depth)];
            y = narrowfrx.*[W,0; 0,-W; 0,0];
        case 'diamond'
            x = [L/2,L/2; 0,L; L/2,L/2];
            y = [W,-W; 0,0; -W,W];
        case 'rectangle'
            x = [L,0; 0,L; 0,L];
            y = [W,-W; W,-W; -W,W];
        case 'fourstar'
            x = [L/3,L/2,L,L/2,2*L/3,2*L/3;
                0,L/3,2*L/3,2*L/3,2*L/3,L/3;
                L/3,2*L/3,2*L/3,L/3,L/3,L/3];
            y = [W/3,W,0,-W,-W/3,W/3;
                0,W/3,W/3,-W/3,W/3,W/3;
                -W/3,W/3,-W/3,-W/3,-W/3,-W/3];
        case {'cback1','cback2','cback3'}
            d = [.1,.25,.6]; b = {'cback1','cback2','cback3'};
            depth = d(strcmp(b,hThis.Head1Style));
            Y = pi/2:pi/40:3*pi/2;
            X = cos(Y);
            xoff = 2*depth;
            X = xoff.*X;
            Y = Y./pi - 1; %-1/2 to 1/2
            Y = Y.*2*W; %-W to W
            X = (L/3).*(X + 3);  %0 to L
            xtip = 0;
            ytip = 0;
            x=zeros(3,length(X)-1); y=zeros(3,length(X)-1);
            for i=1:length(X)-1
                x(:,i) = [xtip; X(i); X(i+1)];
                y(:,i) = [ytip; Y(i); Y(i+1)];
            end
        case 'ellipse'
            % make a basic ellipse LxW at 0,0 with 20 points
            xstart = L/2; ystart = 0;
            x=zeros(3,39); y=zeros(3,39);
            for i=1:39
                th = i*pi/20;
                x(:,i) = [xstart; L/2*cos(th); L/2*cos(th+pi/20)];
                y(:,i) = [ystart; W*sin(th); W*sin(th+pi/20)];
            end
            % translate to beginning of arrow
            x = x + L/2;
        case 'rose'
            % Roses r==Cos[p/q*theta].
            % Parametric: Cos[p/q*t]*{Cos[t],Sin[t]}
            pq = hThis.Head1RosePQ;
            xstart = sin(pi/4).*cos(pq*pi/4)*L/2;
            ystart = cos(pi/4).*cos(pq*pi/4)*W;
            x=zeros(3,39); y=zeros(3,39);
            delta_t = pi/20;
            for i=1:39
                t1 = pi/4 + i*delta_t;
                t2 = t1 + delta_t;
                x1 = sin(t1).*cos(pq*t1)*L/2;
                x2 = sin(t2).*cos(pq*t2)*L/2;
                y1 = cos(t1).*cos(pq*t1)*W;
                y2 = cos(t2).*cos(pq*t2)*W;
                x(:,i) = [xstart; x1; x2];
                y(:,i) = [ystart; y1; y2];
            end
            x = x + L/2;
        case 'hypocycloid'
            N = hThis.Head1HypocycloidN;
            a = 1;
            b = 1/N;
            xstart = (a-2*b); ystart = 0;
            x=zeros(3,12*N-1); y=zeros(3,12*N-1);
            delta_t = pi/(6*N);
            for i=1:12*N-1
                t1 = i*delta_t;
                t2 = t1 + delta_t;
                x1 = (a - b) * cos(t1) - b*cos(((a-b)/b)*t1);
                x2 = (a - b) * cos(t2) - b*cos(((a-b)/b)*t2);
                y1 = (a - b) * sin(t1) + b*sin(((a-b)/b)*t1);
                y2 = (a - b) * sin(t2) + b*sin(((a-b)/b)*t2);
                x(:,i) = [xstart; x1; x2];
                y(:,i) = [ystart; y1; y2];
            end
            if mod(N,2)==0
                % a little rotation for even pointed hypocycloids
                % so that point meets tail.
                phi = pi/N; cosphi = cos(phi); sinphi = sin(phi);
                xx = x.*cosphi - y.*sinphi;
                yy = x.*sinphi + y.*cosphi;
                x = xx;
                y = yy;
            end
            x = x*L/2;
            y = y*W;
            x = x + L/2;
        case 'astroid' %hypocycloid, N=4;
            N = 4;
            a = 1;
            b = 1/N;
            xstart = (a-2*b); ystart = 0;
            x=zeros(3,47); y=zeros(3,47);
            delta_t = pi/24;
            for i=1:47
                t1 = i*delta_t;
                t2 = t1 + delta_t;
                x1 = (a - b) * cos(t1) - b*cos(((a-b)/b)*t1);
                x2 = (a - b) * cos(t2) - b*cos(((a-b)/b)*t2);
                y1 = (a - b) * sin(t1) + b*sin(((a-b)/b)*t1);
                y2 = (a - b) * sin(t2) + b*sin(((a-b)/b)*t2);
                x(:,i) = [xstart; x1; x2];
                y(:,i) = [ystart; y1; y2];
            end

            % a little rotation for even pointed hypocycloids
            % so that point meets tail.
            phi = pi/N; cosphi = cos(phi); sinphi = sin(phi);
            xx = x.*cosphi - y.*sinphi;
            yy = x.*sinphi + y.*cosphi;
            x = xx;
            y = yy;
            x = x*L/2;
            y = y*W;
            x = x + L/2;
        case 'deltoid' %hypocycloid, N=3;
            N = 3;
            a = 1;
            b = 1/N;

            xstart = (a-2*b); ystart = 0;
            x=zeros(3,35); y=zeros(3,35);
            delta_t = pi/18;
            for i=1:35
                t1 = i*delta_t;
                t2 = t1 + delta_t;
                x1 = (a - b) * cos(t1) - b*cos(((a-b)/b)*t1);
                x2 = (a - b) * cos(t2) - b*cos(((a-b)/b)*t2);
                y1 = (a - b) * sin(t1) + b*sin(((a-b)/b)*t1);
                y2 = (a - b) * sin(t2) + b*sin(((a-b)/b)*t2);
                x(:,i) = [xstart; x1; x2];
                y(:,i) = [ystart; y1; y2];
            end

            x = x*L/2;
            y = y*W;
            x = x + L/2;
        case 'none'
            x = 0; y = 0;
    end

    % Rotate by theta and translate by hThis.X(1),hThis.Y(1)
    xx = x.*costh - y.*sinth + PX(1);
    yy = x.*sinth + y.*costh + PY(1);

    % Convert into normalized units:
    % For each entry in xx and yy, do the conversion
    for i = 1:numel(xx)
        norm = hgconvertunits(hFig,[xx(i) yy(i) 0 0],'points','normalized',hFig);
        xx(i) = norm(1);
        yy(i) = norm(2);
    end
    
    set(double(hThis.Head1Handle),'xdata',xx,'ydata',yy,'zdata',zeros(size(yy)));

    % unrotated x,y,z vectors for arrow head 2
    L = hThis.Head2Length;
    W = hThis.Head2Width/2;
    switch (hThis.Head2Style)
        case 'plain'
            x = [PAL-L, PAL, PAL-L];
            y = [W, 0, -W];
        case {'vback1','vback2','vback3'}
            narrowfrx = .75;
            d = [.15,.35,.8]; b = {'vback1','vback2','vback3'};
            depth = d(strcmp(b,hThis.Head2Style));
            x = [PAL-L,PAL; PAL,PAL-L;  PAL-(1-depth)*L,PAL-(1-depth)*L];
            y = narrowfrx.*[W,0; 0,-W; 0,0];
        case 'diamond'
            x = [PAL-L/2,PAL-L/2; PAL,PAL-L; PAL-L/2,PAL-L/2];
            y = [W,-W; 0,0; -W,W];
        case 'rectangle'
            x = [PAL-L,PAL;  PAL,PAL-L; PAL,PAL-L];
            y = [W,-W; W,-W; -W,W];
        case 'fourstar'
            x = [PAL-L/3,PAL-L/2,PAL-L,PAL-L/2,PAL-(2*L/3),PAL-(2*L/3);
                PAL,PAL-L/3,PAL-(2*L/3),PAL-(2*L/3),PAL-(2*L/3),PAL-L/3;
                PAL-L/3,PAL-(2*L/3),PAL-(2*L/3),PAL-L/3,PAL-L/3,PAL-L/3];
            y = [W/2,W,0,-W,-W/3,W/3;
                0,W/3,W/3,-W/3,W/3,W/3;
                -W/3,W/3,-W/3,-W/3,-W/3,-W/3];
        case {'cback1','cback2','cback3'}
            d = [.1,.25,.6]; b = {'cback1','cback2','cback3'};
            depth = d(strcmp(b,hThis.Head2Style));
            Y = pi/2:pi/40:3*pi/2;
            X = cos(Y);
            xbot = 3;
            xoff = 2*depth;
            X = (-1*xoff).*X;
            Y = Y./pi - 1; %-1/2 to 1/2
            Y = Y.*2*W; %-W to W
            X = X.*(L/3);
            X = X + PAL - L;
            xtip = xbot*(L/3) + PAL - L;
            ytip = 0;
            x=zeros(3,length(X)-1); y=zeros(3,length(X)-1);
            for i=1:length(X)-1
                x(:,i) = [xtip; X(i); X(i+1)];
                y(:,i) = [ytip; Y(i); Y(i+1)];
            end
        case 'ellipse'
            % make a basic ellipse LxW at 0,0 with 20 points
            xstart = L/2; ystart = 0;
            x = zeros(3,39); y = zeros(3,39);
            for i=1:39
                th = i*pi/20;
                x(:,i) = [xstart; L/2*cos(th); L/2*cos(th+pi/20)];
                y(:,i) = [ystart; W*sin(th); W*sin(th+pi/20)];
            end
            % translate to beginning of arrow
            x = x + PAL - L/2;
        case 'rose'
            % Roses r==Cos[p/q*theta].
            % Parametric: Cos[p/q*t]*{Cos[t],Sin[t]}
            pq = hThis.Head2RosePQ;
            xstart = sin(pi/4).*cos(pq*pi/4)*L/2;
            ystart = cos(pi/4).*cos(pq*pi/4)*W;
            x=zeros(3,39); y=zeros(3,39);
            delta_t = pi/20;
            for i=1:39
                t1 = pi/4 + i*delta_t;
                t2 = t1 + delta_t;
                x1 = sin(t1).*cos(pq*t1)*L/2;
                x2 = sin(t2).*cos(pq*t2)*L/2;
                y1 = cos(t1).*cos(pq*t1)*W;
                y2 = cos(t2).*cos(pq*t2)*W;
                x(:,i) = [xstart; x1; x2];
                y(:,i) = [ystart; y1; y2];
            end
            x = x + PAL - L/2;
        case 'hypocycloid'
            N = hThis.Head2HypocycloidN;
            a = 1;
            b = 1/N;

            xstart = (a-2*b); ystart = 0;
            x=zeros(3,12*N-1); y=zeros(3,12*N-1);
            delta_t = pi/(6*N);
            for i=1:12*N-1
                t1 = i*delta_t;
                t2 = t1 + delta_t;
                x1 = (a - b) * cos(t1) - b*cos(((a-b)/b)*t1);
                x2 = (a - b) * cos(t2) - b*cos(((a-b)/b)*t2);
                y1 = (a - b) * sin(t1) + b*sin(((a-b)/b)*t1);
                y2 = (a - b) * sin(t2) + b*sin(((a-b)/b)*t2);
                x(:,i) = [xstart; x1; x2];
                y(:,i) = [ystart; y1; y2];
            end

            if mod(N,2)==0
                % a little rotation for even pointed hypocycloids
                % so that point meets tail.
                phi = pi/N; cosphi = cos(phi); sinphi = sin(phi);
                xx = x.*cosphi - y.*sinphi;
                yy = x.*sinphi + y.*cosphi;
                x = xx;
                y = yy;
            else
                % odd pointed hypocycloids need to be flipped for
                % concavity to meet tail and point to point away.
                x = -x;
            end
            x = x*L/2;
            y = y*W;
            x = x + PAL - L/2;
        case 'astroid' %hypocycloid, N=4;
            N = 4;
            a = 1;
            b = 1/N;
            xstart = (a-2*b); ystart = 0;
            x=zeros(3,47); y=zeros(3,47);
            delta_t = pi/24;
            for i=1:47
                t1 = i*delta_t;
                t2 = t1 + delta_t;
                x1 = (a - b) * cos(t1) - b*cos(((a-b)/b)*t1);
                x2 = (a - b) * cos(t2) - b*cos(((a-b)/b)*t2);
                y1 = (a - b) * sin(t1) + b*sin(((a-b)/b)*t1);
                y2 = (a - b) * sin(t2) + b*sin(((a-b)/b)*t2);
                x(:,i) = [xstart; x1; x2];
                y(:,i) = [ystart; y1; y2];
            end

            % a little rotation for even pointed hypocycloids
            % so that point meets tail.
            phi = pi/N; cosphi = cos(phi); sinphi = sin(phi);
            xx = x.*cosphi - y.*sinphi;
            yy = x.*sinphi + y.*cosphi;
            x = xx;
            y = yy;
            x = x*L/2;
            y = y*W;
            x = x + PAL - L/2;
        case 'deltoid' %hypocycloid, N=3;
            N = 3;
            a = 1;
            b = 1/N;

            xstart = (a-2*b); ystart = 0;
            x=zeros(3,35); y=zeros(3,35);
            delta_t = pi/18;
            for i=1:35
                t1 = i*delta_t;
                t2 = t1 + delta_t;
                x1 = (a - b) * cos(t1) - b*cos(((a-b)/b)*t1);
                x2 = (a - b) * cos(t2) - b*cos(((a-b)/b)*t2);
                y1 = (a - b) * sin(t1) + b*sin(((a-b)/b)*t1);
                y2 = (a - b) * sin(t2) + b*sin(((a-b)/b)*t2);
                x(:,i) = [xstart; x1; x2];
                y(:,i) = [ystart; y1; y2];
            end

            % odd pointed hypocycloids need to be flipped for
            % concavity to meet tail and point to point away.
            x = -x;
            x = x*L/2;
            y = y*W;
            x = x + PAL - L/2;
        case 'none'
            x = PAL; y = 0;
    end
    % Rotate by theta and translate by hThis.X(1),hThis.Y(1).
    xx = x.*costh - y.*sinth + PX(1);
    yy = x.*sinth + y.*costh + PY(1);
    
    % Convert into normalized units:
    % For each entry in xx and yy, do the conversion
    for i = 1:numel(xx)
        norm = hgconvertunits(hFig,[xx(i) yy(i) 0 0],'points','normalized',hFig);
        xx(i) = norm(1);
        yy(i) = norm(2);
    end
    
    set(double(hThis.Head2Handle),'xdata',xx,'ydata',yy,'zdata',zeros(size(yy)));
    hThis.UpdateInProgress = false;
end