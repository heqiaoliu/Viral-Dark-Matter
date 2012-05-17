function d = numderivn(fcn,x0,da,maxstep)

% Copyright 2010 The MathWorks, Inc.

if nargin < 4
  maxstep = 100;
end

if nargin < 3
  d = nntest.dnumn(fcn,x0,'maxstep',maxstep);
else
  d = NaN;
  e = inf;
  while (e > 1e-10) && (maxstep > 1e-32)
    shift = maxstep * 2^-26;
    df = nntest.dnumn(fcn,x0+shift,'style','forward','maxstep',maxstep);
    db = nntest.dnumn(fcn,x0-shift,'style','backward','maxstep',maxstep);
    dc = (df + db) / 2;
    dd = [df db dc];
    [newe,i] = min(abs(dd-da));
    if (newe < e)
      d = dd(i);
      e = newe;
    end
    if (e > 1e-10)
      dc = nntest.dnumn(fcn,x0,'style','central','maxstep',maxstep);
      newe = abs(da-dc);
      if (newe < e)
        d = dc;
        e = newe;
      end
    end
    maxstep = maxstep / 4;
  end
end
