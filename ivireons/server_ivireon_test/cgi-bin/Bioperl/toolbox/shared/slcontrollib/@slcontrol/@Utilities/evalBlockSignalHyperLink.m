function evalBlockSignalHyperLink(this,hSrc,hData,model)
% EVALBLOCKSIGNALHYPERLINK  Evaluate a hyperlink for a block or signal.
% Pass in the event source and data from the hyperlink callback.
%
 
% Author(s): John W. Glass 01-Nov-2005
% Copyright 2005-2007 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2007/12/14 15:02:12 $

if strcmp(hData.getEventType.toString, 'ACTIVATED')
    Description = char(hData.getDescription);
    typeind = findstr(Description,':');
       
    switch Description(1:typeind(1)-1)
        case 'block'
            try
                block = char(Description(typeind(1)+1:end));
                model = bdroot(block);
                ensureOpenModel(slcontrol.Utilities,model);
                set_param(model,'HiliteAncestors','off');
                dynamicHiliteSystem(slcontrol.Utilities,block)
            catch
                errordlg(sprintf('The block %s is not valid.',block),sprintf('Simulink Control Design'))
            end
        case 'signal'
            try
                block = char(Description(typeind(1)+1:typeind(2)-1));
                model = bdroot(block);
                port_number = str2double(char(Description(typeind(2)+1:end)));
                ensureOpenModel(slcontrol.Utilities,model);
                ph = get_param(block,'PortHandles');
                if strcmp(get_param(block,'BlockType'),'Outport')
                    port = ph.Inport(1);
                else
                    port = ph.Outport(port_number);
                end
                set_param(model,'HiliteAncestors','off');
                feval( 'hilite_system', port, 'find' )
            catch
                errordlg(sprintf('The block %s is not valid.',block),sprintf('Simulink Control Design'))               
            end
    end
end
