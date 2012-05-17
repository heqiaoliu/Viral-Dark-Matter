function set(this,varargin) 
% SET method to set property value pairs for piecewise linear requirements
%

% Author(s): A. Stothert 04-Apr-2005
% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:35:59 $

if ~isempty(varargin)&& rem(numel(varargin),2)==0
   for idx=1:2:numel(varargin)
      try
         this.(varargin{idx}) = varargin{idx+1};
      catch E %#ok<NASGU>
         ctrlMsgUtils.warning('Controllib:graphicalrequirements:warnSetParamValue',varargin{idx},class(this),num2str(varargin{idx+1}));
      end
   end
else
   ctrlMsgUtils.error('Controllib:general:CompleteOptionsValuePairs','set', sprintf('srorequirement.%s.set',class(this)))
end
