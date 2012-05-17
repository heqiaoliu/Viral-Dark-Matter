function paste(h)

% Paste the current selection to the command line

import com.mathworks.mlservices.*;
import com.mathworks.mde.cmdwin.*;
import com.mathworks.page.datamgr.brushing.*;
import com.mathworks.page.datamgr.linkedplots.*;
import com.mathworks.page.datamgr.utils.*;

sibs = findobj(get(h.HGHandle,'Parent'),'-Property','Brushdata','HandleVisibility','on');
sibs = findobj(sibs,'-function',@(x) ~isempty(get(x,'Brushdata')));
if length(sibs)==1
    localMultiObjCallback(sibs);
else
    datamanager.disambiguate(handle(sibs),{@localMultiObjCallback});
end

function localMultiObjCallback(gobj)

import com.mathworks.page.datamgr.brushing.*;
import com.mathworks.mde.cmdwin.*;

this = getappdata(double(gobj),'Brushing__');
cmdStr = datamanager.var2string(this.getArraySelection);
cmd = CmdWinDocument.getInstance;
awtinvoke(cmd,'insertString',cmd.getLength,cmdStr,[]);