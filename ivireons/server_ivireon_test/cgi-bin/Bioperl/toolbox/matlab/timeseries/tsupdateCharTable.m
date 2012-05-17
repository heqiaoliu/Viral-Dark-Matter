function tsupdateCharTable(h,additionalDataProps,addedArgs,charlist1,model,startRow,col)
%
% tstool utility function

%   Copyright 2005-2006 The MathWorks, Inc.

%% Callback for changes in the characteristic table. Additional arg
%% specifies a parsing function to be used to interpret char property
%% values defining in the char table

%% Find the char
charlist = cell(length(charlist1),3);
if iscell(charlist1{1})
    for k=1:length(charlist1);
        charlist(k,:) = charlist1{k}; 
    end
else
    charlist = charlist1;
end
ind = find(strcmp(char(model.getValueAt(startRow,1)),charlist(:,1)));
if isempty(ind)
    return
end
charid = charlist{ind(1),1};
chardataclass = charlist{ind(1),2};
charviewclass = charlist{ind(1),3};

%% Update the plot 

%% Make sure a char exists
thischar = [];
waves = h.allwaves;
if ~isempty(waves) && ~isempty(waves(1).Characteristics)
    thischar = find(waves(1).Characteristics,'Identifier',charid);
end
if model.getValueAt(startRow,0) && (isempty(thischar) || strcmp(thischar.Visible,'off')) 
    h.addchar(charid,chardataclass,charviewclass,'Visible','on'); 
end


%% Parse additonal char data props
for k=1:length(additionalDataProps)
    if isempty(addedArgs)
        adddataprop{k} = eval(char(model.getValueAt(startRow,1+k)),'[]');
    else % Custom parser for additional char props
        adddataprop{k} = feval(addedArgs{:},h,char(model.getValueAt(startRow,1+k)));
    end
end
waves = h.allwaves;

%% Set the char properties based on the char table
for k=1:length(waves)
    if ~isempty(waves(k).Characteristics)
        thischar = find(waves(k).Characteristics,'Identifier',charid);
        if ~isempty(thischar)
            for j=1:length(additionalDataProps)
                if ~isempty(adddataprop{j}) % Do not use invalid entries
                   set(thischar.Data,additionalDataProps{j},adddataprop{j})
                end
            end
            % Update the char visibility and the char menu checked status
            if model.getValueAt(startRow,0)
                set(thischar,'Visible','on')   
            else
                set(thischar,'Visible','off') 
            end
            thischar.draw
        end
    end     
end

%% Invalid entries trigger a ViewChange to refresh the char table
if length(additionalDataProps)>0 && any(cellfun('isempty',adddataprop))
    h.AxesGrid.send('ViewChange');
end

%% Update the char menus
if model.getValueAt(startRow,0)
    set(h.axesgrid.findMenu(charid),'Checked','on')
else
    set(h.axesgrid.findMenu(charid),'Checked','off')
end