function refresh(this)
%REFRESH Refresh errorbar plot
  
%   Copyright 1984-2007 The MathWorks, Inc.

if ~strcmp(this.dirty,'clean')
  len = length(this.ydata);
  if (length(this.xdata) ~= len) ||  ...
        ((length(this.udata) ~= len) &&...
         (length(this.udata) ~= 1)) ||...
        ((length(this.ldata) ~= len) && ...
         (length(this.ldata) ~= 1)) || ...
        isempty(this.xdata)
    this.dirty = 'inconsistent';
  else
    [x,y,l,u] = deal(this.xdata,this.ydata,abs(this.ldata),abs(this.udata));

    x = x(:);
    y = y(:);
    hAx = ancestor(this,'Axes');
    if strcmpi(get(hAx,'XScale'),'Linear')
        tee = (max(x(:))-min(x(:)))/100;  % make tee .01 x-distance for error bars
        if tee == 0, tee = abs(x)/100; end
        xl = x - tee;
        xr = x + tee;
    else
        % In log scale, we need to scale the error bars
        % The following line is equivalent to
        % teeX = log(x); tee = (max(teeX(:))-min(teeX(:)))/100;
        % projected back into log space
        tee = (max(x(:))-min(x(:)))^.01;  % make tee .01 x-distance for error bars
        if tee == 0, tee = abs(x).^.01; end
        % The following line is equivalent to
        % xl = 10.^(teeX - tee)
        xl = x ./ tee;
        % The following line is equivalent to
        % xr = 10.^(teeX + tee)
        xr = x .* tee;
    end
    ytop = y + u;
    ybot = y - l;
    n = 1;
    npt = length(y);

    % build up nan-separated vector for bars
    xb = zeros(npt*9,n);
    xb(1:9:end,:) = x;
    xb(2:9:end,:) = x;
    xb(3:9:end,:) = NaN;
    xb(4:9:end,:) = xl;
    xb(5:9:end,:) = xr;
    xb(6:9:end,:) = NaN;
    xb(7:9:end,:) = xl;
    xb(8:9:end,:) = xr;
    xb(9:9:end,:) = NaN;

    yb = zeros(npt*9,n);
    yb(1:9:end,:) = ytop;
    yb(2:9:end,:) = ybot;
    yb(3:9:end,:) = NaN;
    yb(4:9:end,:) = ytop;
    yb(5:9:end,:) = ytop;
    yb(6:9:end,:) = NaN;
    yb(7:9:end,:) = ybot;
    yb(8:9:end,:) = ybot;
    yb(9:9:end,:) = NaN;

    ch = get(this,'children');
    set(ch,'visible',this.visible);
    set(ch(1),'xdata',x,'ydata',y);
    set(ch(2),'xdata',xb,'ydata',yb);
    
    cax = get(this,'Parent');
    if ~strcmp(get(cax,'Type'),'axes')
      cax = ancestor(cax,'axes');
    end
    if ~ishold(cax)
      set(cax,'Box','on');
    end

    this.dirty = 'clean';
    update(this);
    if ~isempty(getappdata(double(this),'LegendLegendInfo'))
      setLegendInfo(this);
    end
  end
end

