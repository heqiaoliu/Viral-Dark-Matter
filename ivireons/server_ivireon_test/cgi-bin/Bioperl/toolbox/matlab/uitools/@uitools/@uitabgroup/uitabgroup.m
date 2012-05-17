function h = uitabgroup(varargin)
%Constructor for the uitabgroup class.

%   Copyright 2004-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2010/04/21 21:34:10 $

hg = findpackage('hg');
pc=  hg.findclass('uiflowcontainer');

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

urlCSHelpWindow = 'matlab:helpview([docroot,''/techdoc/uitools_csh/error_pages/bslcn87.html''],'' '',''CSHelpWindow'')';
warning('MATLAB:uitabgroup:OldVersion', [...
            'The uitabgroup object is undocumented and some of its properties will become obsolete in a future release.\n', ...
            'See this <a href="%s">link</a> for help in rewriting existing code for uitabgroup to use the updated properties.\n'],urlCSHelpWindow);
% create object with possibly 'Parent' and 'CreateFcn'
h = uitools.uitabgroup(propsToPass{:});

% set properties only recognized by subclass
if length(propsToSet)>1
   set(double(h),propsToSet{:});
end
