function update(h)

% UPDATE Updates the table text based on the inputsignals struct array

% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2005/12/22 17:39:06 $

numinputs = length(h.inputsignals);
thisdata = h.celldata;
thisdata(:)={' '};

for k=1:numinputs
    thisdata{k,1} = h.inputnames{k};
    if ~isempty(h.inputsignals(k).source)
        startPosition = num2str(h.inputsignals(k).interval(1));
        endPosition = num2str(h.inputsignals(k).interval(2));
        varName = h.inputsignals(k).name; 
        
        switch h.inputsignals(k).source(1:3)
        case {'wor','mat','ini'}
            if ~h.inputsignals(k).transposed
                thisdata{k,2} = [varName '(' startPosition ...
                        ':' endPosition ',' num2str(h.inputsignals(k).column) ')'];	
            else
                thisdata{k,2} = [varName '(' num2str(h.inputsignals(k).column) ',' ...
                       startPosition ':' endPosition ')'];              
            end
        case {'xls','csv','asc','sig'}          
            % To do: look to see if sheet is still loaded ...
            thisdata{k,2} = [varName  '( ' startPosition ':' endPosition ')'];
        end
        thisdata{k,3} = [sprintf('%d',h.inputsignals(k).size(1)) 'x' sprintf('%d',h.inputsignals(k).size(2))];
    end
    
end
h.setCells(thisdata);

% update the lastdata prop since this is not a user edit
h.lastcelldata = thisdata;

% fire a summary update
h.javasend('userentry','');