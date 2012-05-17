function [x,m]=getframe(varargin)
%GETFRAME Get movie frame.
%   GETFRAME returns a movie frame. The frame is a snapshot
%   of the current axis. GETFRAME is usually used in a FOR loop 
%   to assemble an array of movie frames for playback using MOVIE.  
%   For example:
%
%      for j=1:n
%         plot_command
%         M(j) = getframe;
%      end
%      movie(M)
%
%   GETFRAME(H) gets a frame from object H, where H is a handle
%   to a figure or an axis.
%   GETFRAME(H,RECT) specifies the rectangle to copy the bitmap
%   from, in pixels, relative to the lower-left corner of object H.
%
%   F = GETFRAME(...) returns a movie frame which is a structure 
%   having the fields "cdata" and "colormap" which contain the
%   the image data in a uint8 matrix and the colormap in a double
%   matrix. F.cdata will be Height-by-Width-by-3 and F.colormap  
%   will be empty on systems that use TrueColor graphics.  
%   For example:
%
%      f = getframe(gcf);
%      colormap(f.colormap);
%      image(f.cdata);
%
%   See also MOVIE, IMAGE, IM2FRAME, FRAME2IM.

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 5.13.4.8 $  $Date: 2009/12/28 04:18:27 $

  usingMATLABClasses = feature('HGUsingMATLABClasses');
  if usingMATLABClasses 
     resetVis = false; 
     h = [];
     rect = [];
     switch nargin
         case 0
             h = gca;
         case 1
             h = varargin{1};
         case 2
             h  = varargin{1};
             rect = varargin{2};
     end
     if ~(ishghandle(h, 'Figure') || ishghandle(h, 'Axes'))
         error('MATLAB:capturescreen:BadObject', ...
             'A valid figure or axes handle must be specified');
     end
     parentFig = ancestor(h, 'Figure');
     if strcmpi(get(parentFig, 'Visible'), 'off')
         resetVis = true;
         set(parentFig, 'Visible', 'on');
         drawnow;
     end
     % we want the rectangle in Pixels, so if we're not already in Pixels, convert.
     if ~strcmpi(get(h, 'Units'), 'Pixels')
        pos = hgconvertunits(parentFig, get(h, 'Position'), ...
           get(h, 'Units'), 'Pixels', parentFig);
     else
         pos = get(h, 'Position');
     end
     if ishghandle(h, 'Axes') 
         if ~strcmpi(get(parentFig, 'Units'), 'Pixels')
             figPos = hgconvertunits(parentFig,  get(parentFig, 'Position'), ...
               get(parentFig, 'Units'), 'Pixels', parentFig);
         else
             figPos = get(parentFig, 'Position');
         end
         % adjust rect so it is relative to the figure
         pos(1) = pos(1) + figPos(1);
         pos(2) = pos(2) + figPos(2);
     end
     
     % determine absolute rectangle to retrieve
     if isempty(rect) 
        % use position calculated above
        rect = pos;
     else
        % the rect is an offset from the origin of the position calculated above
        rect = [pos(1:2)+rect(1:2) rect(3:4)];
     end
     rect = [floor(rect(1:2)) ceil(rect(3:4))];
     args{1} = h;
     args{2} = rect;
     wasErr = false;
     try 
         % disp(['before figpos: ' num2str(get(parentFig, 'Position'))])
         % disp(['         rect: ' num2str(rect)])
        x = builtin('capturescreen', args{:});
        % disp(['after  figpos: ' num2str(get(parentFig, 'Position'))])
     catch ex 
         wasErr = true;
     end
     if resetVis 
         set(parentFig, 'Visible', 'off');
     end
     if wasErr 
         rethrow(ex)
     end
  else
     x=builtin('capturescreen', varargin{:});
  end

  if (nargout == 2)
    m=x.colormap;
    x=x.cdata;
  end
  
