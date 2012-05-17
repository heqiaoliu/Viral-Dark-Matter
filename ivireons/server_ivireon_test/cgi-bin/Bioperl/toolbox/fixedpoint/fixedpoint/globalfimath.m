function g = globalfimath(varargin)
% GLOBALFIMATH Configure global fimath and return a handle-object
%
%   G = GLOBALFIMATH returns a handle-object to the global fimath.   
%    
%   G = GLOBALFIMATH(F) sets the global fimath to F and returns a handle-object to it.
%
%   G = GLOBALFIMATH('PropertyName1',PropertyValue1,...) sets the global fimath with the named properties
%   set to their corresponding values. Properties that are not specified will automatically be set to that 
%   of the current global fimath.
%
%    
%    
%   Examples:
%     F = fimath('RoundMode','Floor','OverflowMode','Wrap');
%     globalfimath(F);
%     F1 = fimath; % Will be the same as F
%     A = fi(pi); % A will now associate with the global fimath
%
%     % Now set the global fimath's "SumMode" property to be "KeepMSB" while retaining
%     % all the other property values of the current global fimath.
%     G = globalfimath('SumMode','KeepMSB');
%
%     % It is also possible to change the global fimath by directly interacting with the 
%     % handle object G
%     G.ProductMode = 'SpecifyPrecision';
%     
%     % The global fimath may also be reset to the factory setting by calling the reset 
%     % function on G. This is equivalent to calling the resetglobalfimath function.
%     reset(G);    
%
%   See also RESETGLOBALFIMATH, SAVEGLOBALFIMATHPREF, REMOVEGLOBALFIMATHPREF, FIMATH    
    
%   Copyright 2003-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/10/24 19:04:02 $
    
if nargin == 0
    g = embedded.fimath.GetGlobalFimathState;
elseif nargin == 1
    F = varargin{1};
    if isfimath(F) || (ischar(F) && embedded.fimath.FimathDictionaryTagExists(F))
        embedded.fimath.SetGlobalFimath(F);
        g = embedded.fimath.GetGlobalFimathState;
    elseif ischar(F) && isfimath(eval(F))
        embedded.fimath.SetGlobalFimath(eval(F));
        g = embedded.fimath.GetGlobalFimathState;
    else
        error('fixedpoint:globalfimath:invalidInput',...
              'Input must be or evaluate to a fimath object');
    end
else
    try
        F = fimath(varargin{:});
        embedded.fimath.SetGlobalFimath(F);
        g = embedded.fimath.GetGlobalFimathState;
    catch ME
        error('fixedpoint:globalfimath:inValidInput',ME.message);
    end
end



