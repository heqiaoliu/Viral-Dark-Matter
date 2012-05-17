function display(this)
%Display method for the OutputReport object.

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2007 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2007/06/07 14:51:52 $

for ct1 = 1:length(this)
    %% Display the block    
    Block = regexprep(this(ct1).Block,'\n',' ');
    str = sprintf('dynamicHiliteSystem(slcontrol.Utilities,''%s'');',Block);
    if usejava('Swing') && desktop('-inuse') && feature('hotlinks')
        str1 = sprintf('<a href="matlab:%s">%s</a>',str,Block);
    else
        str1 = sprintf('%s',Block);
    end
    
    disp(sprintf('(%d.) %s',ct1,str1))
   
    for ct2 = 1:length(this(ct1).y)
        Value = sprintf('%0.3g',this(ct1).y(ct2));
        Value = LocalPadValue(Value,13);
            if this(ct1).Known(ct2)
                disp(sprintf('      y: %s    (%0.3g)', Value, this(ct1).yspec(ct2)));
            else
                disp(sprintf('      y: %s    [%0.3g %0.3g]', Value, ...
                                this(ct1).Min(ct2), this(ct1).Max(ct2)));
            end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Local function to pad the value string
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Value = LocalPadValue(Value,nels)

if numel(Value) < nels
    Value = [repmat(' ',1,nels-numel(Value)),Value];
end
