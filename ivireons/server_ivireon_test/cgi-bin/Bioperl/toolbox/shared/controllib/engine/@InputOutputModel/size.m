function [s1,varargout] = size(M,x)
%SIZE  Size of input/output models.
%
%   S = SIZE(M) returns
%      * S = [NY NU] for a single model M with NY outputs and NU inputs
%      * S = [NY NU S1 S2 ... Sp] for a model array of size [S1 S2 ... Sp]
%        each system having NY outputs and NU inputs.
%   SIZE(M) by itself displays the size information.
%
%   [NY,NU,S1,...,Sp] = SIZE(M) returns the same information in separate 
%   output arguments. Alternatively,
%      NY = SIZE(M,1)   returns just the number of outputs.
%      NU = SIZE(M,2)   returns just the number of inputs.
%      Sk = SIZE(M,2+k) returns the length of the k-th array dimension.
%
%   For FRD models,
%      NF = SIZE(M,'freq')
%   returns the number of frequency points.
%
%   See also INPUTOUTPUTMODEL/NDIMS, INPUTOUTPUTMODEL/ISEMPTY, ISSISO, ORDER.

%   Author(s): A. Potvin, P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2010/02/08 22:51:58 $
no = nargout;

% Derive vector of sizes
ArraySize = getArraySize(M);
if all(ArraySize==1)
   sizes = M.IOSize_;
else
   sizes = [M.IOSize_ ArraySize];
end
nd = length(sizes);

if nargin==1,
   if no==0,
      % Display only for SIZE(M)
      displaySize(M,sizes)
   elseif no==1,
      % S = SIZE(M)
      s1 = sizes;
   else
      % [S1,..,SK] = SIZE(M)
      s = [sizes(1:2) sizes(3:min(nd,no-1)) prod(sizes(no:nd)) ones(1,no-nd)];
      s1 = s(1);
      varargout = num2cell(s(2:no));
   end
   
else
   % SIZE(M,-)
   if isnumeric(x) && isscalar(x) && isreal(x) && x>0 && x==round(x)
      sizes = [sizes ones(1,x-nd)];
      s1 = sizes(x);
   elseif ischar(x) && any(strncmpi(x,{'o','f'},1))
      switch lower(x(1))
         case 'o'
            % System order 
            % Note: Do not document size(M,'order') users should use ORDER command
            if isa(M,'DynamicSystem')
               try
                  s1 = order(M);
                  if ~isempty(s1) && ~any(s1(2:end)-s1(1:end-1)),
                     % Uniform order
                     s1 = s1(1);
                  end
               catch %#ok<*CTCH>
                  s1 = NaN;
               end
            else
               ctrlMsgUtils.error('Control:ltiobject:size4')
            end
         case 'f'
            % Number of frequencies
            if isa(M,'FRDModel')
               s1 = length(M.Frequency);
            else
               ctrlMsgUtils.error('Control:ltiobject:size3')
            end
      end
   else
      ctrlMsgUtils.error('Control:ltiobject:size2')
   end
end
