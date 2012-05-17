function  varargout = slexist(varargin)
% Check the existence of an input Simulink system (model or block).
% 
%  It provides the following output messages:
%    2 - if the system is existing and it's a model
%    1 - if the system is existing and it's a block
%    0 - if the system is not existing
%   -1 - if there is a hard error.
%  
%   See also SLLASTERROR, SLLASTWARNING, SLLASTDIAGNOSTIC.
%
  
%  Jun Wu, 11/27/2001
  
%   Copyright 1990-2008 The MathWorks, Inc.
%   $Revision: 1.3.4.3 $ $Date: 2008/06/20 08:49:15 $

% Input can be only one argument and output can not have more than one.
inerrmsg = '';
outerrmsg = '';
try
    error(nargchk(1, 1, nargin));
catch e
    inerrmsg = e.message; 
end

try
    error(nargoutchk(0, 1, nargout));
catch e
    outerrmsg = e.message;
end
if ~isempty([inerrmsg outerrmsg])
  error('%s\n%s', inerrmsg, outerrmsg);
end

cache.lastwarn = lastwarn;

cache.sllasterror = sllasterror;
cache.sllastwarn  = sllastwarning;
cache.sllastdiagn = sllastdiagnostic;

sys = varargin{1};

if ischar(sys) || ishandle(sys)
  try 
    hdl = get_param(sys, 'Handle');
    
    if findstr(get_param(hdl, 'Type'), 'diagram')
      val = 2;
    else
      val = 1;
    end
  catch e %#ok
    lastwarn(cache.lastwarn);

    sllasterror(cache.sllasterror);
    sllastwarning(cache.sllastwarn);
    sllastdiagnostic(cache.sllastdiagn);
    
    val = 0;
  end
else
  val = 0;
end

varargout{1} = val;

% end slexist.m

