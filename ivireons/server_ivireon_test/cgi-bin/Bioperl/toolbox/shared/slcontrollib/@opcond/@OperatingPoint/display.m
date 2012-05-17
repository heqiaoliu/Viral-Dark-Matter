function display(this)
%Display method for the operating point object.

%  Author(s): John Glass
%  Revised:
%   Copyright 1986-2010 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2010/02/17 18:58:51 $

if (length(this) == 1)
    disp(ctrlMsgUtils.message('SLControllib:opcond:OperatingPointDisplayTitle',this.Model,sprintf('%g',this.Time)))
        
    if isempty(this.States)
        disp(ctrlMsgUtils.message('SLControllib:opcond:NoStatePointDisplay'))
    else
        disp(ctrlMsgUtils.message('SLControllib:opcond:StatePointDisplay'))
        %% Display the state point objects
        this.States.display;
    end
    
    fprintf('\n');
    if isempty(this.Inputs)
        disp(ctrlMsgUtils.message('SLControllib:opcond:NoInputPointDisplay'))
    else
        disp(ctrlMsgUtils.message('SLControllib:opcond:InputPointDisplay'))
        %% Display the input point objects
        this.Inputs.display
    end
else
    disp(ctrlMsgUtils.message('SLControllib:opcond:VectorOperatingPointDisplay'))
end
