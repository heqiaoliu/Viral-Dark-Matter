function varargout = vertexpicker(varargin)
% This internal helper function may change in a future release.

% [P V I PFACTOR] = VERTEXPICKER(OBJ,TARGET,MODE) 
% OBJ is an axes child.
% TARGET is an axes ray as if produced by the 'CurrentPoint' axes
%        property.
% MODE is optional, '-force' will find closest vertex even if the
%        TARGET ray does not intersect OBJ. This option is used by
%        the data cursor feature as the mouse drags away from the 
%        object
%                   
% P is the projected mouse position on OBJ.
% V is the nearest vertex to P.
% I is the index to V.
% PFACTOR is the amount of interpolation between P and V.
%
% [P V I PFACTOR] = VERTEXPICKER(OBJ,MODE) Assumes TARGET 
%                   is the axes current point                     

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1.2.5.2.29 $ $Date: 2009/12/11 20:34:35 $

% Output variables

if feature('HGUsingMATLABClasses')
    [varargout{1:nargout}] = vertexpickerHGUsingMATLABClasses(varargin{:});
    return;
end

pout = {}; % interpolated point (1x3)
vout = {}; % closest data vertex  point (1x3)
viout = {}; % index into vertex array representing vout (1x1)
pfactor = {}; % interpolation factor
facevout = {}; % interesteted face polygon 
faceiout = {}; % index into face array representing facevout
xdist = []; % relative distance from target to vertex in view space

% parse input
[obj,target,mode] = local_parseargs(nargin,varargin);
len = length(obj);

% scalar input
if len==1
   [pout,vout,viout,pfactor,facevout,faceiout] = ...
                                local_main(obj,target,mode);

% vector input
elseif len>1
    
   % Loop through every object and select the vertex closest 
   % to the mouse pointer in relative view space
   for n = 1:len
      [pout{n},vout{n},viout{n},pfactor{n},...
       facevout{n},faceiout{n},xdist(n)] = local_main(obj(n),target,mode);
   end
    % Get closest vertex to mouse pointer
   [xdist,ind] = min(xdist);
   if ~isempty(ind)
       pout = pout{ind};
       vout = vout{ind};
       viout = viout{ind};
       pfactor = pfactor{ind};
       facevout = facevout{ind};
       faceiout = faceiout{ind};
   end
end

varargout = {pout, vout, viout, pfactor, facevout, faceiout};

%--------------------------------------------------------%
function [pout,vout,viout,pfactor,facevout,faceiout,xdist] = local_main(obj,target,mode)

% Set this flag to true to display debugging information
isdebug = false;

% Output variables
pout=[];vout=[];viout=[];pfactor=[];facevout=[];faceiout=[];xdist=[]; 

% Performance opimization for 2-D lines 
if strcmp(get(obj,'type'),'line') && ...
   ~strcmpi(get(obj,'LineStyle'),'none')
    ax = ancestor(obj,'axes');
    if is2D(ax) && isempty(get(obj,'Zdata')) && all(strcmpi(get(ax,{'XScale','YScale','ZScale'}),'linear'))
        [pout, vout, viout, pfactor, facevout, faceiout] = ...
           local_FastLinePicker(obj,ax,target);
       return;
    end
end
    
% if obj is a figure
if strcmp(get(obj,'type'),'figure')
    fig = obj;
    ax = get(fig,'currentobject');
    currobj = get(fig,'currentobject');
    
    % bail out if not a child of the axes
    if isempty(ancestor(get(currobj,'parent'),'axes'))
        return;
    end
    
% if obj is an axes
elseif strcmp(get(obj,'type'),'axes')
    ax = obj;
    fig = ancestor(ax,'hg.figure');
    currobj = get(fig,'currentobject');
    currax = ancestor(currobj,'axes');
    
    % Bail out if current object is under an unspecified axes
    if ~isequal(ax,currax)
        return;
    end

% if obj is an hg object    
elseif isa(obj,'hg.GObject')
    currobj = obj;
    ax = ancestor(obj,'hg.axes');
    if isempty(ax)
        return;
    end
        
% Ignore all other objects
else
    return;
end

[pout, vout, viout, pfactor, facevout, faceiout, xdist] = ...
    local_MainVertexPicker(isdebug,mode,currobj,ax,target');

%--------------------------------------------------------%
function [obj,target,mode] = local_parseargs(nin,vargin)
% Parse input arguments

if nin == 3
   obj = vargin{1};
   target = vargin{2};
   mode = vargin{3};
elseif nin==2
   obj = vargin{1};
   arg2 = vargin{2};
   if ischar(arg2)
      mode = arg2;
      ax = ancestor(obj,'hg.axes');
      target = get(ax,'CurrentPoint');
   else
      mode = '-default';
      target = arg2;
   end
elseif nin==1
   obj = vargin{1};   
   ax = ancestor(obj,'hg.axes');
   target = get(ax,'CurrentPoint');
   mode = '-default';
else
  error('MATLAB:vertexpicker:InvalidInputs', 'Invalid input arguments')
end

obj = handle(obj);

if any(isempty(obj)) || any(~ishghandle(obj))
    errmsg = 'Input argument must be a valid graphics handle';
    error(errmsg);
end

%--------------------------------------------------------%
function [pout, vout, viout, pfactor, facevout, faceiout, xdist] = ...
    local_MainVertexPicker(isdebug,mode,axchild,ax,target)
% This function transforms object vertices in dataspace to a translated 
% view space so that the selection point is at the origin. After
% transforming the vertices, the closest vertex in view space is
% determined.

% Output variables
pout=[];vout=[];viout=[];pfactor=[];facevout=[];faceiout=[];xdist=[]; 

% Get vertex, face, and current point data 

% If line object     
if isa(axchild,'hg.line')    
    isDiscrete = strcmpi(get(axchild,'LineStyle'),'none');
    xdata = get(axchild,'xdata');
    ydata = get(axchild,'ydata');
    zdata = get(axchild,'zdata');
    vert = [xdata', ydata',zdata'];
    faces = []; 
    
    
% If surface object
elseif isa(axchild,'hg.surface') 
    % Get surface face and vertices
    fv = surf2patch(axchild);
    vert = fv.vertices;
    faces = fv.faces;
    isDiscrete = strcmpi(get(axchild,'FaceColor'),'none');
    
% If patch object
elseif isa(axchild,'hg.patch')
    vert = get(axchild,'vertices');
    faces = get(axchild,'faces');
    isDiscrete = strcmpi(get(axchild,'FaceColor'),'none');
    
% If image object
elseif isa(axchild,'hg.image')
    % Image doesn't require transforming data
    [pout, vout, viout] = local_ImagePicker(axchild,target);
    return;
    
% Ignore all other axes children
else     
   return;
end
    
% Add z if empty
if size(vert,2)==2
   vert(:,3) = zeros(size(vert(:,2)));
   if isa(axchild,'hg.line')
       zdata = vert(:,3)';
   end
end

dar = get(ax,'DataAspectRatio');

% Transform vertices from data space to pixel space
xvert = local_Data2PixelTransform(ax,vert)';
xtarget = local_Data2PixelTransform(ax,target')';

% Translate so that the selection point is at the origin. 
xvert(1,:) = xvert(1,:) - xtarget(1,2);
xvert(2,:) = xvert(2,:) - xtarget(2,2);

% For debugging only
if isdebug
    local_DisplayDebugInfo(xvert,faces)
end

% Depending on whether the object is a line or patch/surface, call vertex
% picker core implementation.
if isa(axchild,'hg.line')
   [pout, vout, viout, pfactor, facevout, faceiout, xdist] = ...
       local_LinePicker(axchild,isdebug,isDiscrete,xvert,xdata,ydata,zdata,ax);
else % patch | surface
   if isDiscrete
       [pout, vout, viout, pfactor, facevout, faceiout, xdist] = ...
       local_DiscretePicker(xvert,vert);       
   else
       [pout, vout, viout, pfactor, facevout, faceiout, xdist] = ...
       local_GeometryPicker(isdebug,mode,target,xvert,vert,faces,dar);
   end
end

%--------------------------------------------------------%
function local_DisplayDebugInfo(xvert,faces)
% Displays a window showing vertex data in a transformed view 
% space where the origin (0,0) is the mouse click location.

ax1 = getappdata(0,'vertexpicker');
if ~any(ishghandle(ax1))
    fig = figure; 
    ax1 = axes;
    axis(ax1,'equal');
    setappdata(0,'vertexpicker',ax1);
end

cla(ax1);
line('parent',ax1,'xdata',0,'ydata',0,'zdata',0,...
     'marker','o','markerfacecolor','r','erasemode','xor');    

if isa(axchild,'hg.line')
    line('parent',ax1,'xdata',xvert(1,:),'ydata',xvert(2,:),'marker','o');  
else
    patch('parent',ax1,'faces',faces,'vertices',xvert',...
          'facecolor','none','edgecolor','k');  
end
    
%--------------------------------------------------------%
function [p] = local_Data2PixelTransform(ax,vert)
% Transform vertices from data space to pixel space. This code 
% is based on HG's gs_data3matrix_to_pixel internal c-function.

if strcmp(get(ax,'XScale'),'log')
    if all(get(ax,'XLim') >= 0)
        % On a log-scale plot, negative values do not render.
        vert(vert(:,1)<0,1) = NaN;        
        vert(:,1) = log(vert(:,1));
    else
        % On a log-scale plot, negative values do not render.
        vert(vert(:,1)>0,1) = NaN;       
        vert(:,1) = -log(-vert(:,1));
    end
end

if strcmp(get(ax,'YScale'),'log')
    if all(get(ax,'YLim') >= 0)
        % On a log-scale plot, negative values do not render.
        vert(vert(:,2)<0,2) = NaN;        
        vert(:,2) = log(vert(:,2));
    else
        % On a log-scale plot, negative values do not render.
        vert(vert(:,2)>0,2) = NaN;
        vert(:,2) = -log(-vert(:,2));
    end
end

if strcmp(get(ax,'ZScale'),'log')
    if all(get(ax,'ZLim') >= 0)
        % On a log-scale plot, negative values do not render.
        vert(vert(:,3)<0,3) = NaN;
        vert(:,3) = log(vert(:,3));
    else
        % On a log-scale plot, negative values do not render.
        vert(vert(:,3)>0,3) = NaN;
        vert(:,3) = -log(-vert(:,3));
    end
end

% Get needed transforms
xform = get(ax,'x_RenderTransform');
offset = get(ax,'x_RenderOffset');
scale = get(ax,'x_RenderScale');

% Equivalent: nvert = vert/scale - offset;
nvert(:,1) = vert(:,1)./scale(1) - offset(1);
nvert(:,2) = vert(:,2)./scale(2) - offset(2);
nvert(:,3) = vert(:,3)./scale(3) - offset(3);

% Equivalent xvert = xform*xvert;
w = xform(4,1) * nvert(:,1) + xform(4,2) * nvert(:,2) + xform(4,3) * nvert(:,3) + xform(4,4);
xvert(:,1) = xform(1,1) * nvert(:,1) + xform(1,2) * nvert(:,2) + xform(1,3) * nvert(:,3) + xform(1,4);
xvert(:,2) = xform(2,1) * nvert(:,1) + xform(2,2) * nvert(:,2) + xform(2,3) * nvert(:,3) + xform(2,4);

% w may be 0 for perspective plots 
ind = find(w==0);
w(ind) = 1; % avoid divide by zero warning
xvert(ind,:) = 0; % set pixel to 0

p(:,1) = xvert(:,1) ./ w;
p(:,2) = xvert(:,2) ./ w;

%--------------------------------------------------------%
function [pout, vout, viout] = local_ImagePicker(hImage,target,mode)
% Main function for image vertex picking

% Interpolated point is the target
pout(1) = target(1,1);
pout(2) = target(2,1);

% Get image dimensions
xdata = get(hImage,'xdata');
ydata = get(hImage,'ydata');
cdata = get(hImage,'cdata');
[nrows,ncols,ncolors] = size(cdata);

% If the interpolated point is outside the bounds of the image, snap it to
% the edge:
if pout(1) < min(xdata(:))
    pout(1) = min(xdata(:));
elseif pout(1) > max(xdata(:))
    pout(1) = max(xdata(:));
end
if pout(2) < min(ydata(:))
    pout(2) = min(ydata(:));
elseif pout(2) > max(ydata(:));
    pout(2) = max(ydata(:));
end

% Determine viout
viout(1) = local_Image_Util_Axes2Pix(ncols,xdata,pout(1));
viout(2) = local_Image_Util_Axes2Pix(nrows,ydata,pout(2));


% Determine vout based on viout
if size(cdata,2) > 1
   width_x = (xdata(end)-xdata(1)) / (size(cdata,2)-1);
else
   width_x = xdata(end) - xdata(1);   
end
if size(cdata,1) > 1
   width_y = (ydata(end)-ydata(1)) / (size(cdata,1)-1);
else
   width_y = ydata(end) - ydata(1);   
end

vout(1) = width_x*(viout(1)-1)+xdata(1);
vout(2) = width_y*(viout(2)-1)+ydata(1);

%-------------------------------------------------%
function [ind] = local_Image_Util_Axes2Pix(ndim,xdata,xtarget)
% Determine index into image based on target (in one dimension)

% Get extent of image
xfirst = xdata(1);
xlast = xdata(max(size(xdata)));

if (ndim == 1)
  x = xtarget - xfirst + 1;
else
  index_per_data = (ndim - 1) / (xlast - xfirst);
  if (index_per_data == 1) && (xfirst == 1)
     x = xtarget;
  else
     x = index_per_data * (xtarget - xfirst) + 1;
  end
end

% Find ind corresponding to x where (1 < ind < ndim) 
ind = min(ndim,max(1,round(x)));

%--------------------------------------------------------%
function [pout, vout, viout, pfactor, facevout, faceiout] = ...
    local_FastLinePicker(hLine,ax,target)

% Output variables
%pout=[];vout=[];viout=[];pfactor=[];xdist=[]; 
facevout=[];faceiout=[];
x = target(1,1);
y = target(1,2);
xline = get(hLine,'xdata');
yline = get(hLine,'ydata');

if length(xline)==1
    pout = [xline(1),yline(1)];
    vout = pout;
    pfactor = 0;
    viout = 1;
else
   % Copied Control Toolbox LPROJECT function

   in_xline = xline;
   in_yline = yline;

   %Non-finite data-points will be hallucinated as interpolated points:
   [in_xline,in_yline,closest_ind] = localInterpInfNan(in_xline,in_yline,[]);

   [xp ,yp,ip,tmin,imin] = local_lproject(false,x,y,in_xline,in_yline, ax);

   pout = [xp,yp];
   piout = round(ip);
   vout = [xline(piout),yline(piout)];
   viout = round(ip);
       
   len = length(xline);

   % Interpolation factor varies from -.5 to .5
   dip = ip-imin;
   if(dip>.5)
       pfactor = dip-1;
   else
       pfactor = dip;
   end
   
   %If the nearest vertex is non-finite, snap to the closest finite one.
   if ~all(isfinite(vout))
       if floor(ip) == viout
           viout = closest_ind(1,viout);
           vout = [xline(viout),yline(viout)];
           pout = vout;
           piout = viout;
       else
           viout = closest_ind(2,viout);
           vout = [xline(viout),yline(viout)];
           pout = vout;
           piout = viout;
       end
       % Since we snapped, there is no interpolation factor.
       pfactor = 0;
   else
       %Snap to closest visible vertex if we are interpolating near NaNs
       if floor(ip) == piout && piout ~= len && any(~isfinite([xline(piout+1),yline(piout+1)]))
           pout = [xline(piout),yline(piout)];
       elseif ceil(ip) == piout && piout~= 1 && any(~isfinite([xline(piout-1),yline(piout-1)]))
           pout = [xline(piout),yline(piout)];
       end
   end
end

%-------------------------------------------------------%
function [xLine,yLine,closest_ind] = localInterpInfNan(xLine,yLine,zLine)
%LOCALINTERPINFNAN   Interpolate points to patch holes in data caused by NaN
%and Inf.

len = length(xLine);
closest_ind = zeros(2,len);
if ~isempty(zLine)
    ind = find(~isfinite(xLine)|~isfinite(yLine)|~isfinite(zLine));
else
    ind = find(~isfinite(xLine)|~isfinite(yLine));
end
%interp = zeros(1,length(ind));
if ~isempty(ind)
    %It is possible that there are multiple non-finite data-points next to
    %eachother. The interpolation should handle this smoothly. Loop through
    %the non-finite points determining the closest vertices and computing
    %their interpolation factors

    %Find the right-side neighbors
    for i = 1:length(ind)
        %Boundary conditions are different
        if ind(i) ~= 1
            if i==1 || ind(i-1) ~= ind(i)-1
                closest_ind(2,ind(i)) = ind(i)-1;
            else
                closest_ind(2,ind(i)) = closest_ind(2,ind(i-1));
            end
        end
    end

    %Find the left-side neighbors
    for i = length(ind):-1:1
        %Boundary conditions are different
        if ind(i) ~= len
            if i==length(ind) || ind(i+1) ~= ind(i)+1
                closest_ind(1,ind(i)) = ind(i)+1;
            else
                closest_ind(1,ind(i)) = closest_ind(1,ind(i+1));
            end
        end
    end
    
    %Deal with boundaries
    l = length(ind);    
    if ind(1) == 1
        closest_ind(2,1) = closest_ind(1,1);
        i = 2;
        while (i<=l) && (ind(i-1) == ind(i)-1)
            closest_ind(2,ind(i)) = closest_ind(2,ind(i-1));
            i = i+1;
        end
    end
    
    if ind(l) == len;
        closest_ind(1,end) = closest_ind(2,end);
        i = l-1;
        while (i>=1) && (ind(i+1) == ind(i)+1)
            closest_ind(1,ind(i)) = closest_ind(1,ind(i+1));
            i = i-1;
        end
    end
    
    %Compute interpolation factors
    numerator = ind - closest_ind(2,ind);
    denom = closest_ind(1,ind) - closest_ind(2,ind);
    indices = find(denom==0);
    numerator(indices) = 1;
    denom(indices) = 1;
    interp = numerator./denom;
    %Patch the line
    infX = find(~isfinite(xLine(ind)));
    if ~isempty(infX)
        xLine(ind(infX)) = (xLine(closest_ind(1,ind(infX)))-xLine(closest_ind(2,ind(infX)))).*interp(infX)+xLine(closest_ind(2,ind(infX)));
    end
    infY = find(~isfinite(yLine(ind)));
    if ~isempty(infY)
        yLine(ind(infY)) = (yLine(closest_ind(1,ind(infY)))-yLine(closest_ind(2,ind(infY)))).*interp(infY)+yLine(closest_ind(2,ind(infY)));
    end

    %Determine which vertices the data should snap to when we get near the
    %non-finite data-points
    for i = 1:length(ind)
        cr = closest_ind(1,ind(i));
        cl = closest_ind(2,ind(i));
        if cr ~= cl
            %Check for clusters of non-finite data-points
            if cr - cl ~= 2
                v1 = [xLine(cr)-xLine(cl);yLine(cr)-yLine(cl)];
                v2 = [xLine(ind(i))-xLine(cl);yLine(ind(i))-yLine(cl)];
                if norm(v1)/2 <= norm(v2)
                    closest_ind(2,ind(i)) = cr;
                else
                    closest_ind(1,ind(i)) = cl;
                end
            end
        end
    end
end

%-------------------------------------------------------%
function [xp,yp,ip,tmin,imin] = local_lproject(isxform,x,y,xline,yline,ax)
%LPROJECT  Project point on polyline.
%
%   [XP,YP] = LPROJECT(X,Y,XLINE,YLINE) projects the point (X,Y)
%   onto the polyline specified by the points (XLINE(i),YLINE(i)).
%
%   [XP,YP] = LPROJECT(X,Y,XLINE,YLINE,AX) performs the projection
%   in normalized axis units so that (XP,YP) is the "visually
%   nearest" point.  AX should be the handle of the axes containing
%   the line in question.
%
%   Authors: P. Gahinet
%   Revised: A. DiVergilio

%  This code is copied from the Control Toolbox LPROJECT function

% Init
np = length(xline); 
%t = zeros(1,np-1);
%d = zeros(1,np-1);
   
% If the data is not transformed
if ~isxform
   
   % Normalization
   %---Axes handle is provided, so perform visual scaling
   [xs,ys] = local_ScaleFactors(ax);
   x = x/xs; xls = xline/xs;
   y = y/ys; yls = yline/ys;

else
   xls = xline;
   yls = yline;
   x = 0;
   y = 0;
end

% Compute projection P = t*A + (1-t)*B of M(x,y) on each segment [A,B]
xAB = xls(2:np) - xls(1:np-1);
yAB = yls(2:np) - yls(1:np-1);
xMB = xls(2:np)-x;
yMB = yls(2:np)-y;

AB2 = xAB.^2 + yAB.^2;
t = (xMB .* xAB + yMB .* yAB) ./ (AB2+(AB2==0));
t = max(0,min(t,1));

% Compute min distance square
d = (xMB-t.*xAB).^2 + (yMB-t.*yAB).^2;
[dmin,imin] = min(d);

% Nearest point is P(imin)
tmin = t(imin);
xp = tmin * xline(imin) + (1-tmin) * xline(imin+1);
yp = tmin * yline(imin) + (1-tmin) * yline(imin+1);
ip = imin + 1 - tmin;  % relative index

%--------------------------------------------%
function [xs,ys] = local_ScaleFactors(AXES)
 %---Calculate XY scaling factors for axes
 lims = get(AXES,{'XLim','YLim'});
 scales = get(AXES,{'XScale','YScale'});
 if strcmpi(scales{1},'log')
    lims{1} = log10(lims{1});
 end
 if strcmpi(scales{2},'log')
    lims{2} = log10(lims{2});
 end
 if ~all(isfinite(lims{1})) || ~all(isfinite(lims{2})) ...
         || ~all(isreal(lims{1})) || ~all(isreal(lims{2}))
     % This code is duplicated in pan.m
     % If any of the public limits are inf then we need the actual limits
     % by getting the hidden deprecated RenderLimits.
     oldstate = warning('off','MATLAB:HandleGraphics:NonfunctionalProperty:RenderLimits');
     renderlimits = get(AXES,'RenderLimits');
     warning(oldstate);
     lims{1} = renderlimits(1:2);
     if strcmpi(scales{1},'log')
         lims{1} = log10(lims{1});
     end
     lims{2} = renderlimits(3:4);
     if strcmpi(scales{2},'log')
         lims{2} = log10(lims{2});
     end
 end
 NRT = get(AXES,'x_NormRenderTransform');
 xs = (lims{1}(2)-lims{1}(1))/NRT(1,1);
 ys = (lims{2}(2)-lims{2}(1))/abs(NRT(2,2));

%--------------------------------------------------------%
function [pout, vout, viout, pfactor, facevout, faceiout, xdist] = ...
    local_DiscretePicker(xvert,vert)
% Return the closest line vertex to the translated view space origin. 
% The interpolated point will be empty since there is nothing to 
% interpolate on a discrete plot.

% Output variables
%pout=[];vout=[];viout=[];pfactor=[];xdist=[];
facevout=[];faceiout=[]; 

% We are working in translated view space where the origin 
% corresponds to the selection location.
xform_xdata =  xvert(1,:);
xform_ydata =  xvert(2,:);
%np = length(xform_xdata);

d = xform_xdata.^2 + xform_ydata.^2;
[val i] = min(d);
xdist = val;
i = i(1); % enforce only one output
vout = [ vert(i,1) vert(i,2) vert(i,3)];
viout = i;   
pout = vout;
pfactor = 0;

%--------------------------------------------------------%
function [pout, vout, viout, pfactor, facevout, faceiout, xdist] = ...
    local_LinePicker(hLine,isdebug,isDiscrete,xvert,xdata,ydata,zdata,hAx)

% Input variables
% isdebug           debug mode true/false
% mode              not used
% isDiscrete        true if line is discrete (i.e. scatter plot)
% xvert             line vertices transformed to view space
% xdata             x line vertices in absolute data space
% ydata             y line vertices in absolute data space
% zdata             z line vertices in absolute data space

% Output variables
%pout=[];vout=[];viout=[];pfactor=[];xdist=[];
facevout=[];faceiout=[]; 

% We are working in translated view space where the origin 
% corresponds to the selection location.
xform_xdata =  xvert(1,:);
xform_ydata =  xvert(2,:);

% If the line is discrete, then just return the closest line vertex 
% to the translated view space origin. The interpolated point will 
% be empty since there is nothing to interpolate on a discrete plot.
if isDiscrete
    d = xform_xdata.^2 + xform_ydata.^2;
    [val i] = min(d);    
    xdist = val(1);
    i = i(1); % enforce only one output
    vout = [ xdata(i) ydata(i) zdata(i)];
    viout = i;   
    pout = vout;
    pfactor = 0;
    return;
end

% If line is only one point
if length(xdata)==1
   xdist = xform_xdata.^2 + xform_ydata.^2;
   vout = [xdata(1),ydata(1)];
   pout = vout;
   viout = 1;
   pfactor = 0;
   if ~isempty(get(hLine,'zdata'))
     vout = [vout,zdata(1)];
     pout = vout;
   end
   return;
end

%Non-finite data-points will be hallucinated as interpolated points:
[xform_xdata,xform_ydata,closest_ind] = localInterpInfNan(xform_xdata,xform_ydata,zdata);

[xp,yp,ip,tmin,imin] = local_lproject(true,[],[],xform_xdata,xform_ydata,[]);

% Nearest data vertex (i.e. snap to nearest data vertex)
viout = round(ip);
vout = [xdata(viout),ydata(viout)];

% Interpolated point 
xdist = xform_xdata(imin).^2 + xform_ydata(imin).^2;
if strcmpi(get(hAx,'XScale'),'linear')
    xpos = tmin * xdata(imin) + (1-tmin) * xdata(imin+1);
else
    xsign = (-1)^(all(get(hAx,'XLim') < 0));
    xpos = xsign*exp(tmin * log(xsign*xdata(imin)) + (1-tmin) * log(xsign*xdata(imin+1)));
end
if strcmpi(get(hAx,'YScale'),'linear')
    ypos = tmin * ydata(imin) + (1-tmin) * ydata(imin+1);
else
    ysign = (-1)^(all(get(hAx,'YLim') < 0));
    ypos = ysign*exp(tmin * log(ysign*ydata(imin)) + (1-tmin) * log(ysign*ydata(imin+1)));
end

% Add z dimension if necessary
if ~isempty(get(hLine,'zdata'))
    if strcmpi(get(hAx,'ZScale'),'linear')
        zpos = tmin * zdata(imin) + (1-tmin) * zdata(imin+1);
    else
        zsign = (-1)^(all(get(hAx,'ZLim') < 0));
        zpos = zsign*exp(tmin * log(zdata(zsign*imin)) + (1-tmin) * log(zsign*zdata(imin+1)));
    end
    vout = [vout,zdata(viout)];
end

%If the nearest vertex is non-finite, snap to the closest finite one.
if ~all(isfinite(vout))
    if floor(ip) == viout
        viout = closest_ind(1,viout);
        vout = [xdata(viout),ydata(viout)]; 
        pout = vout;
        piout = viout;
    else
        viout = closest_ind(2,viout);
        vout = [xdata(viout),ydata(viout)];
        pout = vout;
        piout = viout;
    end
end

% If nan/infs, snap to nearest data vertex
if isfinite(xpos) && isfinite(ypos)
    pout = [xpos,ypos];
else
    pout = vout;
end

if ~isempty(get(hLine,'zdata'))
    vout = [vout(1:2),zdata(viout)];
    if isfinite(zpos)
        pout = [pout(1:2),zpos];
    else
        pout = vout;
    end
end

% Interpolation factor varies from -.5 to .5
dip = ip-imin;
if(dip>.5)
    pfactor = dip-1;
else
    pfactor = dip;
end

%--------------------------------------------------------%
function [pout, vout, viout, pfactor, facevout, faceiout, xdist] = ...
    local_GeometryPicker(isdebug,mode,cp,xvert,vert,faces,dar)
% Determine the interpolated point and closest data vertex to the
% origin by performing the 2-D crossing test (Jordan Curve Theorem). A 
% polygon is interestected if it traverses an odd number of polygon 
% edges along any positive axis. 

% Output variables
pout=[];vout=[];viout=[];pfactor=[];facevout=[];faceiout=[];xdist=[]; 

% Find all vertices that have y components less than zero
vert_with_negative_y = zeros(size(faces));
face_y_vert = xvert(2,faces);
ind_vert_with_negative_y = find(face_y_vert<0); 
vert_with_negative_y(ind_vert_with_negative_y) = true;

% Find all the line segments that span the x axis
is_line_segment_spanning_x = abs(diff([vert_with_negative_y, vert_with_negative_y(:,1)],1,2));

% Find all the faces that have line segments that span the x axis
ind_is_face_spanning_x = find(any(is_line_segment_spanning_x,2));

% Ignore data that doesn't span the x axis
candidate_faces = faces(ind_is_face_spanning_x,:);
vert_with_negative_y = vert_with_negative_y(ind_is_face_spanning_x,:);
is_line_segment_spanning_x = is_line_segment_spanning_x(ind_is_face_spanning_x,:);

% Ignore faces that include Non-finite vertices:
infMask = ~isfinite(vert);
nonFiniteRows = find(infMask(:,1)|infMask(:,2)|infMask(:,3));
tempFaces = candidate_faces;
for i=1:numel(nonFiniteRows)
    tempMask = (candidate_faces == nonFiniteRows(i));
    tempFaces(tempMask) = NaN;
end
tempRowSums = sum(tempFaces,2);
rowIndicesToRemove = find(isnan(tempRowSums));

candidate_faces(rowIndicesToRemove,:) = [];
vert_with_negative_y(rowIndicesToRemove,:) = [];
is_line_segment_spanning_x(rowIndicesToRemove,:) = [];
ind_is_face_spanning_x(rowIndicesToRemove) = [];

% Create line segment arrays
pt1 = candidate_faces;
pt2 = [candidate_faces(:,2:end), candidate_faces(:,1)];

% Point 1
x1 = reshape(xvert(1,pt1),size(pt1));
y1 = reshape(xvert(2,pt1),size(pt1));

% Point 2
x2 = reshape(xvert(1,pt2),size(pt2));
y2 = reshape(xvert(2,pt2),size(pt2));

% Cross product of vector to origin with line segment
cross_product_test = -x1.*(y2-y1) > -y1.*(x2-x1);

% Find all line segments that cross the positive x axis
crossing_test = (cross_product_test==vert_with_negative_y) & is_line_segment_spanning_x;

% If the number of line segments is odd, then we intersected 
% the polygon (Jordan Curve Theorem)
s = sum(crossing_test,2);
s = mod(s,2);
ind_intersection_test = find(s~=0);

% This index will be empty if no faces were hit 
% (i.e. the mouse click occurred away from the object)
if isempty(ind_intersection_test) 
    
    % Return empty by default
    if strcmp(mode,'-default') 
       pout = [];
       viout = [];
       vout = [];
       
    % Otherwise, find the closest vertex even though the mouse 
    % position (origin in translated view space) does not intersect 
    % any geometry.
    elseif strcmp(mode,'-force') 
       dist = xvert(1,:).^2+ xvert(2,:).^2;
       [val, I] = min(dist);
       viout = I(1);
       vout = vert(viout,:);
       
       % Approximate the interpolated point to be the closest data 
       % vertex. This approximation results in non-intuitive behavior
       % if the polygon face is relatively large on the screen. The 
       % ideal solution will be to interpolate along the closet face 
       % edge line segment in a similar manner that we do for line
       % objects.
       pout = vout; 
    end
    
    return;
end

% Plane/ray intersection test 

% Perform plane/ray intersection with the faces that passed 
% the polygon intersection tests. Grab the only the first 
% three vertices since that is all we need to define a plane).
% assuming planar polygons.
candidate_faces = candidate_faces(ind_intersection_test,1:3);
candidate_faces = reshape(candidate_faces',1,numel(candidate_faces));
vert = vert';
candidate_facev = vert(:,candidate_faces);
candidate_facev = reshape(candidate_facev,3,3,length(ind_intersection_test));

% Get three contiguous vertices along polygon 
v1 = squeeze(candidate_facev(:,1,:));
v2 = squeeze(candidate_facev(:,2,:));
v3 = squeeze(candidate_facev(:,3,:));

% Get normal to face plane
vec1 = (v2-v1);
vec2 = (v3-v2);
crs = cross(vec1,vec2);
mag = sqrt(sum(crs.*crs));

% If triangle vertices (v1,v2,v3) are 
% identical, results will be nan and will not be considered.
nplane(1,:) = crs(1,:)./mag;
nplane(2,:) = crs(2,:)./mag;
nplane(3,:) = crs(3,:)./mag;

% Compute intersection between plane and ray
cp1 = cp(:,1);
cp2 = cp(:,2);
d = cp2-cp1;
dp = dot(-nplane,v1);

% A = dot(nplane,d);
A(1,:) = nplane(1,:).*d(1);
A(2,:) = nplane(2,:).*d(2);
A(3,:) = nplane(3,:).*d(3);
A = sum(A,1);

% B = dot(nplane,pt1) 
B(1,:) = nplane(1,:).*cp1(1);
B(2,:) = nplane(2,:).*cp1(2);
B(3,:) = nplane(3,:).*cp1(3);
B = sum(B,1);

% Distance to intersection point
t = (-dp-B)./A;

% Find "best" distance (smallest)
[tbest ind_best] = min(t);

pfactor = tbest;

% Determine intersection point
pout = cp1 + tbest .* d;
pout = pout'; % row vector
    
% Get face index and vertices
faceiout = ind_is_face_spanning_x(ind_intersection_test(ind_best));
facevout = vert(:,faces(faceiout,:));
    
% Calculate closest vertex in data space (not view space)
tmp(1,:) = facevout(1,:) - pout(1);
tmp(2,:) = facevout(2,:) - pout(2);
tmp(3,:) = facevout(3,:) - pout(3);
    
% Normalize for data aspect ratio to avoid visual artifacts
tmp(1,:) = tmp(1,:) ./ dar(1);
tmp(2,:) = tmp(2,:) ./ dar(2);
tmp(3,:) = tmp(3,:) ./ dar(3);
     
% Calculate distance from interpolated point to face vertices (in
% data space)
dist = tmp(1,:).*tmp(1,:) + tmp(2,:).*tmp(2,:) + tmp(3,:).*tmp(3,:);
        
% Alternative: Calculate closest vertex in view space (not intuitive)
%facexv = xvert(:,faces(faceiout,:));
%dist = sqrt(facexv(1,:).*facexv(1,:) +  facexv(2,:).*facexv(2,:));
    
[min_dist, min_index] = min(dist);
min_index = min_index(1); % force only one output
    
% Get closest vertex index and vertex
viout = faces(faceiout,min_index);
vout = vert(:,viout)'; % row vector


% To Be Done:
% xdist = 
