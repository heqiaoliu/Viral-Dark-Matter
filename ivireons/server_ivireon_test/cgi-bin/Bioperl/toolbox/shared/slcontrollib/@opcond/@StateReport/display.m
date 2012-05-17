function display(this,varargin)
%Display method for the StateReport object.

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2007 The MathWorks, Inc.
% $Revision: 1.1.6.8 $ $Date: 2007/12/14 15:02:06 $

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
    
    for ct2 = 1:length(this(ct1).x)
        xValue = sprintf('%0.3g',this(ct1).x(ct2));
        xValue = LocalPadValue(xValue,13);
        dxValue = sprintf('%0.3g',this(ct1).dx(ct2));
        dxValue = LocalPadValue(dxValue,13);
        
        if this(ct1).SteadyState(ct2)
            disp(sprintf('      x: %s      dx: %s (0)', xValue, dxValue));
        else
            disp(sprintf('      x: %s      dx: %s', xValue, dxValue));
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
