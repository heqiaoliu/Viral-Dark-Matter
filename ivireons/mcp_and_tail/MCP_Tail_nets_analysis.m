function [totalmeansandsds] = TestNets(data_name, descriptions_name)


totalcount = 1;
save counting totalcount


countation = 1;
until = 140;

%#function network
uno = ['load ' data_name ' -ascii'];
eval(uno);
dos = ['names = importdata(''' descriptions_name ''');'];
eval(dos);
tres = ['hypotheticalsUnitywrongway = ' data_name ';'];
eval(tres);
hypotheticalsUnity = hypotheticalsUnitywrongway';


[namesize, namecolumns] = size(names);
predictionmatrix = zeros(namesize,10); %10 is the number of columns, because there are 10 ANNs trained per group. used to be "until"
proteinnamematrix = zeros(namesize,10);
positivesandnegativesmatrix = zeros(7,10);

totalmeansandsds = zeros(namesize,29);
whichannnumber = 0;

while (totalcount <= until) %make 11

[neurons, countation, ANNname, datastring] = GetCountationNameAndData(totalcount);
    
ANNname;
countation;


    
%diarystatement = ['diary optimal_predictions_junerefseqtest_mcp_OneToOneRatio' int2str(countation) '.txt'];
%eval(diarystatement);

ANNnameAndNumber = [ANNname int2str(countation)];
loadANN = ['load ' ANNnameAndNumber ' -mat;'];
eval(loadANN);


[rows , cols] = size(hypotheticalsUnity);
rows;
cols;





%out = sim(ANN_T4Ratio_MCP_United8, Lambda_united'); %simulate neural network. ANN_TRAINED is the network, while RAMY_DATA are the inputs.
outing = ['out = sim(' ANNnameAndNumber ',  hypotheticalsUnity );'];


eval(outing);

AllScoresAndProteinsName = ['AllScoresAndProteins'];
AllScoresAndProteinsNameAndNumber = [AllScoresAndProteinsName int2str(countation)]; %Here's the changing variable name for the cell, according to number.

CurrentAllScoresAndProteins = cell(size(names)); %Here's the ACTUAL cell. 

settingup = [AllScoresAndProteinsNameAndNumber ' = CurrentAllScoresAndProteins;'];
eval(settingup);                    %%%%%now AllScoresAndProteinsName1/2/3 etc, will become cell(size(names))

countation;
resultingResults = [];

duh='';
cnt = 0; %what is s? what is errmsg? documentation didn't help. 
for i=1:cols %from 1 to however many columns there are...
%if out(1,i) > 0 %if the neural network _________ at the current i is greater than 1...
    
thescore = out(1,i);

[prediction,errmsg] = sprintf('%f', out(1,i)); %sprintf writes data to a string
%[protein_name,errmsg] = sprintf('%s', char(names(i,:))); %sprintf writes data to a string
%[s,errmsg] = sprintf('%f � �%s', out(1,i), char(names(i,:))); %sprintf writes data to a string
i;
w = str2num(prediction);
predictionmatrix(i,countation) = w;

cnt=cnt+1; %add one to count

scoreAsString = [num2str(thescore)];

end;

cnt;
cols;
cnt/cols;





countation = countation + 1;
totalcount = totalcount + 1;
save counting totalcount '-APPEND';


if countation > 10
    whichannnumber = whichannnumber + 1;
    whichsdnumber = whichannnumber + 15;
    
    transposed_predictionmatrix = predictionmatrix';
    averages = mean(transposed_predictionmatrix)';
    standarddeviations = std(transposed_predictionmatrix)';

    transposedpositivesandnegativesmatrix = positivesandnegativesmatrix';
    averagestats = mean(transposedpositivesandnegativesmatrix)';
    standarddeviationsofstats = std(transposedpositivesandnegativesmatrix)';
    
    
    for i=1:namesize
    totalmeansandsds(i,whichannnumber) = averages(i,1);
    totalmeansandsds(i,whichsdnumber) = standarddeviations(i,1);
    end
    
    predictionstring = ['all_hypotheticals_predictions_' ANNname '.xls'];
    avgstring = ['all_hypotheticals_avgs_' ANNname '.xls'];
    sdstring = ['all_hypotheticals_sds_' ANNname '.xls'];
    
    %xlswrite(predictionstring, predictionmatrix, 'dunno', 'A1');
    %xlswrite(avgstring, averages, 'dunno', 'A1');
    %xlswrite(sdstring, standarddeviations, 'dunno', 'A1');

end


end;

[path, fname, fext]=fileparts(data_name);

new_fname=strrep(fname, '_data','');

out_file=[new_fname '.mcpt.ann.out'];

%diary 'mcp_tail_analysis.out';
eval(sprintf('diary %s', out_file));

[s,errmsg] = sprintf('Annotation\t MCP 1:1\t MCP 2:1\t MCP 3:1\t MCP 4:1\t MCP 7:1\t MCP Lambda:1\t MCP Lambda2:1\t Tail 1:1\t Tail 2:1\t Tail 3:1\t Tail 4:1\t Tail 7:1\t Tail Lambda:1\t Tail Lambda2:1\t SDS \t SD MCP 1:1\t SD MCP 2:1\t SD MCP 3:1\t SD MCP 4:1\t SD MCP 7:1\t SD MCP Lambda:1\t SD MCP Lambda2:1\t SD Tail 1:1\t SD Tail 2:1\t SD Tail 3:1\t SD Tail 4:1\t SD Tail 7:1\t SD Tail Lambda:1\t SD Tail Lambda2:1');
disp(s);
for i=1:namesize
    [s,errmsg] = sprintf('%s\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t ', char(names(i,:)), totalmeansandsds(i,1), totalmeansandsds(i,2), totalmeansandsds(i,3), totalmeansandsds(i,4), totalmeansandsds(i,5), totalmeansandsds(i,6), totalmeansandsds(i,7), totalmeansandsds(i,8), totalmeansandsds(i,9), totalmeansandsds(i,10), totalmeansandsds(i,11), totalmeansandsds(i,12), totalmeansandsds(i,13), totalmeansandsds(i,14), totalmeansandsds(i,15), totalmeansandsds(i,16), totalmeansandsds(i,17), totalmeansandsds(i,18), totalmeansandsds(i,19), totalmeansandsds(i,20), totalmeansandsds(i,21), totalmeansandsds(i,22), totalmeansandsds(i,23), totalmeansandsds(i,24), totalmeansandsds(i,25), totalmeansandsds(i,26), totalmeansandsds(i,27), totalmeansandsds(i,28), totalmeansandsds(i,29));
    disp(s);
end

disp('The End.');

diary off;
%diary 'herro.txt';
%disp(names);
%diary off;

%for i=1:namesize
    
%end;

%ANNnameAndNumber
%sxlswrite('ANN_prediction_averages_and_sds.xls', totalmeansandsds, 'blank', 'A1');
%dlmwrite('ANN_prediction_averages_and_sds.txt',totalmeansandsds, 'delimiter', '\t');
%exit;
end
