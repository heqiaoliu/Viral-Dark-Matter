function res=islegendable(h)
%ISLEGENDABLE Tests if an object should be can in a legend
%    RES = ISLEGENDABLE(H) returns true if graphics object H can
%    be shown in a legend.

%   Copyright 1984-2010 The MathWorks, Inc.

% islegendable method takes precedence if it exists
if ismethod(h,'islegendable')
   res = h.islegendable;
   return
end
      
res= true;
switch get(h,'Type')
 case {'line','patch','surface'}
  if ( (isempty(get(h,'xdata')) || isallnan(get(h,'xdata'))) && ...
       (isempty(get(h,'ydata')) || isallnan(get(h,'ydata'))) && ...
       (isempty(get(h,'zdata')) || isallnan(get(h,'zdata'))) ) || ...
        ~hasbehavior(h,'legend')
    res = false;
  end
 case {'hggroup','hgtransform'}
     if isempty(get(h,'Children'))
         res = false;
     end         
otherwise
  res = false;
end

% Take the "LegendEntry" display property into account.
if res
    hA = get(h,'Annotation');
    if ishandle(hA) || (isobject(hA) && isvalid(hA))
        hL = hA.LegendInformation;
        if ishandle(hL) || (isobject(hL) && isvalid(hL))
            res =  ~strcmpi(hL.IconDisplayStyle,'off');
        end
    end
end

if res
    res = hasbehavior(h,'legend');
end

%----------------------------------------------------------------%
function allnan = isallnan(d)

nans = isnan(d);
allnan = all(nans(:));
