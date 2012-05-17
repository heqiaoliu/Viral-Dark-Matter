function showfixptsimerrors
%SHOWFIXPTSIMERRORS show overflow logs from last simulation

% Copyright 1994-2008 The MathWorks, Inc.
% $Revision: 1.1.4.1 $  
% $Date: 2008/06/26 20:27:09 $

curModel = bdroot;

if isempty(curModel)
    return;
end

FixPtSimRanges = retrievefixptsimranges(curModel, 0);

for i = 1:length(FixPtSimRanges)
    
    bo = isfield(FixPtSimRanges{i},'OverflowOccurred');
    bs = isfield(FixPtSimRanges{i},'SaturationOccurred');
    bp = isfield(FixPtSimRanges{i},'ParameterSaturationOccurred');
    bd = isfield(FixPtSimRanges{i},'DivisionByZeroOccurred');
    
    if bo || bs || bp || bd
    	disp(' ')
    	disp(FixPtSimRanges{i}.Path)
    	
        if bo
            disp(' ')
    	    disp(DAStudio.message('SimulinkFixedPoint:autoscaling:overflowCount',...
                                  FixPtSimRanges{i}.OverflowOccurred))
        end
    	
        if bs
            disp(' ')
            disp(DAStudio.message('SimulinkFixedPoint:autoscaling:saturationCount',...
                                  FixPtSimRanges{i}.SaturationOccurred))
        end
    	
        if bp
            disp(' ')
    	    disp(DAStudio.message('SimulinkFixedPoint:autoscaling:paramSatCount',...
                                  FixPtSimRanges{i}.ParameterSaturationOccurred))
        end
    	
        if bd
            disp(' ')
            disp(DAStudio.message('SimulinkFixedPoint:autoscaling:divByZeroCount',...
                                  FixPtSimRanges{i}.DivisionByZeroOccurred))
        end
    	disp(' ')
    end    	
end
