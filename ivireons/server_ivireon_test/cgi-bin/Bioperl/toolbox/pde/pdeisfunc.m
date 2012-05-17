function tf=pdeisfunc(f)
%PDEISFUNC True if input name is a function.

%       A. Nordmark 7-1-96.
%       Copyright 1994-2006 The MathWorks, Inc.
%       $Revision: 1.5.4.2 $  $Date: 2006/12/15 19:29:28 $


tf=0;
if ischar(f) && size(f,1)==1
  if size(f,2)>0
    % We assume function names start with a letter and then is
    % letters/digits/underscores
    il=isletter(f);
    in=abs('0')<=abs(f) & abs(f)<=abs('9') | abs(f)==abs('_'); 
    if il(1) & all(il(2:end) | in(2:end))
      tf=~all(exist(f)-[2 3 5 6]);
    end
  end
elseif isa(f, 'function_handle')
  tf=1;
end

