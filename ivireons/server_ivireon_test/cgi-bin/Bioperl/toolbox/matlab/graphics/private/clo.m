function ret_obj = clo(obj, in1, in2)
%CLO Clear object
%   CLO(H) deletes all children of the object with visible handles.
%
%   CLO(..., 'reset') deletes all children (including ones with hidden
%   handles) and also resets all object properties to their default
%   values.
%
%   CLO(..., HSAVE) deletes all children except those specified in
%   HSAVE.
%
%   See also CLF, CLA, RESET, HOLD.

%   Copyright 1984-2009 The MathWorks, Inc.

% decode input args:
hsave    = [];
do_reset = '';

error(nargchk(1, 3, nargin));

if nargin > 1
    if   ischar(in1), do_reset = in1; else hsave = in1; end
    if nargin > 2
        if ischar(in2), do_reset = in2; else hsave = in2; end
    end
end

% error-check input args
if ~isempty(do_reset)
  if ~strcmp(do_reset, 'reset')
    error('MATLAB:clo:unknownOption','Unknown command option.')
  else
    do_reset = 1;
  end
else
  do_reset = 0;
end

if any(~ishghandle(hsave))
  error('MATLAB:clo:invalidHandle','Bad handle')
end

hsave = find_kids(obj, hsave);

if do_reset
    if ishghandle(obj)
        if ~feature('HgUsingMATLABClasses')
            kids_to_delete = setdiff(findall(obj,'serializable','on','-depth',1),obj);
        else
            % HG2 does not hide the data brushing toolbar which leaves an
            % additional uimenu object. Filtering this additional object till 
            % g586144 is completed.
            uiMenuChild = findall(obj, 'Label','Building...');
            kids = setdiff(allchild(obj), uiMenuChild);
            kids_to_delete = intersect(findall(kids, 'serializable', 'on'), kids);
        end
    else
        kids_to_delete = get(obj,'Children'); % Only get 'real' children
        kids_to_delete = findobj(kids_to_delete,'flat', 'serializable','on');
    end
else
    kids_to_delete =  findobj(get(obj,'Children'),'flat',...
      'HandleVisibility','on', 'serializable','on');
end

if feature('HgUsingMatlabClasses')
    hlen = length(hsave);
    for i=1:hlen
        mask = kids_to_delete == hsave(i);
        if any(mask)
            kids_to_delete = kids_to_delete(~mask);
        end
    end
else   
    kids_to_delete = setdiff(kids_to_delete, hsave);
end

delete(kids_to_delete);

if do_reset, 
  handleobj = obj(ishghandle(obj));
  reset(handleobj);
  % reset might have invalidated more handles
  handleobj = handleobj(ishghandle(handleobj));
  % look for appdata for holding color and linestyle
  for k=1:length(handleobj)
    tobj = handleobj(k);
    if isappdata(tobj,'PlotHoldStyle')
      rmappdata(tobj,'PlotHoldStyle')
    end
    if isappdata(tobj,'PlotColorIndex')
      rmappdata(tobj,'PlotColorIndex')
      rmappdata(tobj,'PlotLineStyleIndex')
    end
    if isprop(tobj,'ColorIndex')
        set(tobj,'ColorIndex',1);
        set(tobj,'LineStyleIndex',1);
    end
  end
end

% now that IntegerHandle can be changed by reset, make sure
% we're returning the new handle:
if (nargout ~= 0)
    ret_obj = obj(ishghandle(obj));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function hsave_out = find_kids(obj, hsave)
%
%
%
hsave_out = [];
for kid=hsave(:)'
  while ~isempty(kid)
    parent = get(kid,'parent');
    if ~isempty(parent) & parent == obj
      hsave_out(end + 1) = kid;
      break;
    else
      kid = parent;
    end
  end
end
  
