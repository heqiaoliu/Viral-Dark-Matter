function display(this)
%Display method for the operating specification object.

%  Author(s): John Glass
%  Revised:
%   Copyright 1986-2010 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2010/02/17 18:58:53 $

if (length(this) == 1)
    disp(ctrlMsgUtils.message('SLControllib:opcond:OperatingSpecDisplayTitle',this.Model,sprintf('%g',this.Time)))
    
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
    
    fprintf('\n');
    if isempty(this.Outputs)
        disp(ctrlMsgUtils.message('SLControllib:opcond:NoOutputPointDisplay'))
    else
        disp(ctrlMsgUtils.message('SLControllib:opcond:OutputPointDisplay'))
        %% Display the input point objects
        this.Outputs.display
    end
    fprintf('\n');
else
    disp(ctrlMsgUtils.message('SLControllib:opcond:VectorOperatingPointDisplay'))
end
