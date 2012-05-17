function A = utCheckFRDData(A,PropStr)
% Checks data is properly formatted

%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/03/31 18:36:06 $
switch PropStr
   case 'f'
      % Frequency
      if ~isempty(A)
         if ~(isvector(A) && isnumeric(A) && isreal(A) && all(isfinite(A) & A>=0))
            ctrlMsgUtils.error('Control:ltiobject:frdProperties1')
         elseif any(diff(sort(A))==0)
            ctrlMsgUtils.error('Control:ltiobject:frdProperties5')
         end
      end
      A = double(full(A(:)));
   case 'r'
      if isnumeric(A)
         A = double(full(A));
      elseif ~isa(A,'StaticModel')
         ctrlMsgUtils.error('Control:ltiobject:frdProperties2')
      end
end
