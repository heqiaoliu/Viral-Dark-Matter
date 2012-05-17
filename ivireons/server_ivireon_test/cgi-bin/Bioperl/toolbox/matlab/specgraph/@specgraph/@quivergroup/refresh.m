function refresh(this)
%REFRESH Refresh quiver plot
  
%   Copyright 1984-2005 The MathWorks, Inc.

is3D = ~isempty(this.zdata);

if ~strcmp(this.dirty,'clean')
  u = this.udata;
  
  listeners = getappdata(0,'SpecgraphQuiverListeners');
  set(listeners(end),'enable','off'); % disable mode listener
  
  if strcmp(this.xdatamode,'auto')
    this.xdata = 1:size(u,2);
  end
  if strcmp(this.ydatamode,'auto')
    this.ydata = 1:size(u,1);
  end
  
  set(listeners(end),'enable','on'); % enable mode listener

  % Arrow head parameters
  alpha = .33;  % Size of arrow head relative to the length of the vector
  beta = .25;  % Width of the base of the arrow head relative to the length

  autoscale = strcmp(this.autoscale,'on');
  
  if is3D
     [msg,x,y,z] = xyzchk(this.xdata,this.ydata,this.zdata);
     u = this.udata;
     v = this.vdata;
     w = this.wdata;
  else
    [msg,x,y,u,v] = xyzchk(this.xdata,this.ydata,this.udata,this.vdata);

    % expand x and y data to be same size as u
    [m,n] = size(u);
    if ~isequal(size(x),size(this.udata))
      x = x(:).';
      x = x(ones(m,1),:);
    end
    if ~isequal(size(y),size(this.udata))
      y = y(:);
      y = y(:,ones(n,1));
    end

    z = 0;
    w = 0;
  end
  
  if ~isempty(msg) || isempty(x) || isempty(y) || isempty(z) ...
        || isempty(u) || isempty(v) || isempty(w)
    this.dirty = 'inconsistent';
  else
    % reshape and expand data
    if prod(size(u))==1, u = u(ones(size(x))); end
    if prod(size(v))==1, v = v(ones(size(x))); end
    if (is3D && prod(size(w))==1)
       w = w(ones(size(x))); 
    end
    
    if autoscale,
      
      % Base autoscale value on average spacing in the x, y and z
      % directions.  Estimate number of points in each direction as
      % either the size of the input arrays or the effective square
      % spacing if x and y are vectors.
      if min(size(x))==1, n=sqrt(prod(size(x))); m=n; else [m,n]=size(x); end
      delx = diff([min(x(:)) max(x(:))])/n;
      dely = diff([min(y(:)) max(y(:))])/m;
      if is3D
        delz = diff([min(z(:)) max(z(:))])/max(m,n);
        del = delx.^2 + dely.^2 + delz.^2;
      else
        del = delx.^2 + dely.^2;
      end
      
      if del>0
        if is3D
          len = sqrt((u.^2 + v.^2 + w.^2)/del);
        else
	  len = sqrt((u.^2 + v.^2)/del);
        end
	maxlen = max(len(:));
      else
	maxlen = 0;
      end
      
      if maxlen>0
	autoscale = autoscale*this.autoscalefactor / maxlen;
      else
	autoscale = autoscale*this.autoscalefactor;
      end
      
      u = u*autoscale; v = v*autoscale;
      if is3D, w = w*autoscale; end
      
    end

    % Make velocity vectors
    x = x(:).'; y = y(:).'; 
    u = u(:).'; v = v(:).';
    if is3D
       z = z(:).';
       w = w(:).';
    end
    
    uu = [x;x+u;repmat(NaN,size(u))];
    vv = [y;y+v;repmat(NaN,size(u))];
    if is3D
       ww = [z;z+w;repmat(NaN,size(u))];
    end
    
    ch = get(this,'children');

    hu = x; hv = y;
    
    if is3D
        hw = z;
        set(ch(3),'xdata',hu(:),'ydata',hv(:),'zdata',hw(:));
    else
        set(ch(3),'xdata',hu(:),'ydata',hv(:));
    end
    
    uu = uu(:);
    vv = vv(:);
    if is3D, ww = ww(:); end
    
    if is3D
       set(ch(1),'xdata',uu,'ydata',vv,'zdata',ww);      
    else
       set(ch(1),'xdata',uu,'ydata',vv);
    end
    
    % Draw arrow head
    if strcmp(this.showarrowhead,'on'),
      if is3D
         norm = sqrt(u.*u + v.*v + w.*w);
      else
         norm = sqrt(u.*u + v.*v);    
      end
      normxy = sqrt(u.*u + v.*v)+eps;
      allx = [x(:); x(:)+u(:)];
      spanx = max(allx) - min(allx);
      ally = [y(:); y(:)+v(:)];
      spany = max(ally) - min(ally);
      
      if is3D
         allz = [z(:); z(:)+w(:)];
         spanz = max(allz) - min(allz);
      end

      if is3D
         cutoff = this.maxheadsize * max(spanx,max(spany,spanz));
      else
         cutoff = this.maxheadsize * max(spanx,spany);
      end
      
      beta = beta .* norm ./ normxy;
      norm2 = norm;
      norm2(norm < cutoff) = 1;
      norm2(norm > cutoff) = norm(norm > cutoff)./cutoff;
      alpha = alpha ./ norm2;
      
      % Make arrow heads and plot them
      hu = [x+u-alpha.*(u+beta.*(v+eps));x+u; ...
	    x+u-alpha.*(u-beta.*(v+eps));repmat(NaN,size(u))];
      hv = [y+v-alpha.*(v-beta.*(u+eps));y+v; ...
	    y+v-alpha.*(v+beta.*(u+eps));repmat(NaN,size(v))];

      if is3D
          hw = [z+w-alpha.*w;z+w; ...
                z+w-alpha.*w;repmat(NaN,size(w))];
      else
          hw = [];  
      end
      
      set(ch(2),'xdata',hu(:),'ydata',hv(:),'zdata',hw(:),...
                'visible',this.visible);
    else
      set(ch(2),'visible','off');
    end

    this.dirty = 'clean';
    update(this);
    setLegendInfo(this);
  end
end