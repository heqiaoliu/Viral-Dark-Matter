function display(this,varargin)
%Display method for the StateSpec object.

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2007 The MathWorks, Inc.
% $Revision: 1.1.6.7 $ $Date: 2007/12/14 15:02:08 $

for ct1 = 1:length(this)
    %% Be sure to remove returns and insert spaces
    BlockName = regexprep(this(ct1).Block,'\n',' ');
    if isempty(this(ct1).StateName)
        StateName = BlockName;
    else
        StateName = regexprep(this(ct1).StateName,'\n',' ');
    end
    
    str = sprintf('dynamicHiliteSystem(slcontrol.Utilities,''%s'');',BlockName);
    if usejava('Swing') && desktop('-inuse') && feature('hotlinks')
        str1 = sprintf('<a href="matlab:%s">%s</a>',str,StateName);
    else
        str1 = sprintf('%s',StateName);
    end
    disp(sprintf('(%d.) %s',ct1,str1))
    
    for ct2 = 1:this(ct1).Nx
        Value = sprintf('%0.3g',this(ct1).x(ct2));
        Value = LocalPadValue(Value,13);
        if this(ct1).SteadyState(ct2)
            if this(ct1).Known(ct2)
                disp(sprintf('      spec:  dx = 0,  x: %s', Value));
            else
                disp(sprintf('      spec:  dx = 0,  initial guess: %s', Value));
            end
        else
            if this(ct1).Known(ct2)
                disp(sprintf('      x: %s', Value));
            else
                disp(sprintf('      initial guess: %s', Value));
            end
        end
    end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Local function to pad the value string
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Value = LocalPadValue(Value,nels)

if numel(Value) < nels
    Value = [repmat(' ',1,nels-numel(Value)),Value];
end