function refresh(this)
%REFRESH Refresh bar plot
  
%   Copyright 1984-2008 The MathWorks, Inc. 

if ~strcmp(this.dirty,'clean')
  try
    sibs = get(this,'BarPeers');
    % Throw an error if there are no siblings (
    if isempty(sibs)
        error('MATLAB:specgraph:barseries:inconsistent',...
            'A barseries must have siblings present');
    end
    ok = false(length(sibs),1);
    for k=1:length(sibs);
      if ishandle(sibs(k))
        ok(k) = true;
      end
    end
    sibs = sibs(ok);
    ydata = get(sibs,'ydata');
    xdata = get(sibs,'xdata');
    if length(sibs) > 1
      % create a single matrix from all the vectors, adjusting for lengths
      ylen = max(cellfun('length',ydata));
      xlen = max(cellfun('length',xdata));
      maxlen = max(ylen,xlen);
      ydatafull = repmat(this.basevalue,maxlen,length(sibs));
      xdatafull = this.xdata;
      for k = 1:length(sibs)
	d = ydata{k};
	if length(xdata{k}) == maxlen
	  xdatafull = xdata{k};
	end
	ydatafull(1:length(d),k) = d(:);
      end
      ydata = ydatafull;
      xdata = xdatafull;
    end
    width = this.barwidth;
    barlayout = this.barlayout;
    % In order for makebars to return meaningful information for empty
    % inputs, we will convert any empty input to be of size 0xsibs
    if isempty(xdata)
        xdata = zeros(0,numel(sibs));
    end
    if isempty(ydata)
        ydata = zeros(0,numel(sibs));
    end
    [msg,x,y,xx,yy] = makebars(xdata,ydata,width,barlayout);
  catch err
    msg=err.message;
  end
  if ~isempty(msg)
    this.dirty = 'inconsistent';
  else
    cax = get(sibs(1),'Parent');
    % only call ancestor if needed for performance 
    if ~strcmp(get(cax,'Type'),'axes')
      cax = ancestor(cax,'axes');
    end
    if strcmp(get(sibs(1),'Horizontal'),'on')
      tickstr = 'YTick';
      tickstr2 = 'XTickMode';
    else
      tickstr = 'XTick';
      tickstr2 = 'YTickMode';
    end
    tickdata = get(cax,tickstr);
    
    % update patches of all the sibling barseries objects
    numBars = (size(xx,1)-1)/5;
    if strcmp(this.barlayout,'grouped')
      yy(2:5:(numBars*5),:) = yy(2:5:(numBars*5),:) + this.basevalue;
      yy(5:5:(numBars*5),:) = yy(5:5:(numBars*5),:) + this.basevalue;
    else
      yy(2:5:(numBars*5),1) = yy(2:5:(numBars*5),1) + this.basevalue;
      yy(5:5:(numBars*5),1) = yy(5:5:(numBars*5),1) + this.basevalue;
    end
    f = 1:(numBars*5);
    f(1:5:(numBars*5)) = [];
    f = reshape(f, 4, numBars);
    f = f';
    for k=1:length(sibs)
      s = sibs(k);
      v = [xx(:,k) yy(:,k)];
      if strcmp(s.horizontal,'on')
	v = [yy(:,k) xx(:,k)];
      end
      color = k*ones(size(v,1),1);

      % make axes auto clim picker choose clim=[1 2]
      if k==1 && length(sibs)==1
	color(end) = 2;
      end

      set(s.children,'faces', f, 'vertices', v, ...
		     'facevertexcdata', color);
      s.dirty = 'clean';
      update(s);
      if ~isempty(getappdata(double(s),'LegendLegendInfo'))
	setLegendInfo(s);
      end
    end
    if strcmp(get(sibs(1),'Horizontal'),'on')
      set(get(sibs(1),'BaseLine'),'Orientation','Y');
    else
      set(get(sibs(1),'BaseLine'),'Orientation','X');
    end
    hold_state = ishold(cax);
    if ~hold_state, 
      x = xdata;
      % Set ticks if less than 16 integers and matches previous
      if ~isappdata(cax,['barseries' tickstr]) || ...
            isequal(tickdata,getappdata(cax,['barseries' tickstr])) || ...
            strcmp(get(cax,[tickstr 'Mode']),'auto')
        set(cax,[tickstr 'Mode'],'auto')
        if all(all(floor(x)==x)) && (length(x)<16)
          dd = diff(x);
          if all(dd > 0) 
            set(cax,tickstr,x)
          elseif all(dd < 0)
            set(cax,tickstr,fliplr(x))
          end
          set(cax,tickstr2,'auto')
        end
        setappdata(cax,['barseries' tickstr],get(cax,tickstr));
      end
      view(cax,2);
      set(cax,'Layer','Bottom','Box','on')
    end
  end
end
