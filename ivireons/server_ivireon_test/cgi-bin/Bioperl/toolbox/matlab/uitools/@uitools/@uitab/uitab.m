function h = uitab(varargin)
%Constructor for the uitab class.

%   Copyright 2004-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2006/11/29 21:53:29 $

hg = findpackage('hg');
pc = hg.findclass('uicontainer');

% Cycle through parameter list and separate the P/V paires into two groups.
% Those acceptable by super class and those only acceptable by this class
argin = varargin;
len = length(varargin);

% If the input is a p-v structure, then break it up into a p-v array.
if (len == 1 && isstruct(argin{:}))
    props = argin{:};
    fields = fieldnames(props);
    pvals = {};
    for i = 1:length(fields)
        pvals{end+1} = fields{i};
        pvals{end+1} = props.(fields{i});
    end
    argin = pvals(:);
    len = length(argin);
end

propsToPass = {};
propsToSet = {};

hParent = [];

if len > 0 
  % must be even number for param-value syntax
  if mod(len,2)>0       
      argin = {'Parent' argin{:}};
  end
    
  idxsuper = []; 
  idxthis = []; 
  for i = 1:2:len     
      passtosuper = 0;
      try
         %if (strcmpi(argin(i), 'parent'))
         lower_argin_i = lower(argin{i});
         if ( strfind('parent', lower_argin_i) && ...
              strfind(lower_argin_i, 'pa') )
             hParent = argin{i+1};
         end
         % property accepted by super class
         p = pc.findprop(argin{i});
         if ~isempty(p)
             passtosuper =1;
         end
      catch
      end
      
      if passtosuper
         idxsuper = [idxsuper, i, i+1];
      else
         idxthis = [idxthis, i, i+1];
      end
  end % for
  
  propsToPass = {argin{idxsuper}};
  propsToSet = {argin{idxthis}};
end

if (~isscalar(hParent) || ~ishandle(hParent))
    error('MATLAB:uitab:InvalidObjHandle', 'Invalid object handle.');
end
if (~isa(handle(hParent), 'uitools.uitabgroup'))
    error('MATLAB:uitab:ObjMustBeChild', 'An object of class uitab has to be a child of class uitabgroup.');
end

% create object with possibly 'Parent' and 'CreateFcn'
h = uitools.uitab(propsToPass{:});

% set properties only recognized by subclass
if length(propsToSet)>1
   set(double(h),propsToSet{:});
end

