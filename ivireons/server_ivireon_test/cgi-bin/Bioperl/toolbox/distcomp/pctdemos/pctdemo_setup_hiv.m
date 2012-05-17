function [fig, pol, description] = pctdemo_setup_hiv(difficulty)
%PCTDEMO_SETUP_HIV Perform the initialization for the Parallel
%Computing Toolbox Gene Sequence Alignment demos.
%   [fig, gag, description, aapol, aaenv] = pctdemo_setup_hiv(difficulty)
%   Outputs:
%     fig           The output figure for the demos.
%     pol           The pol polyproteins of all the viruses.
%     description   A text description of the viruses.

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/11/07 20:52:33 $
    
    % Demo details
    %
    % Mutations accumulate in the genomes of pathogens, in this case the
    % human/simian immunodeficiency virus, during the spread of an
    % infection.  This information can be used to study the history of
    % transmission events, and also as evidence for the origins of the
    % different viral strains. 
    %
    % There are two characterized strains of human AIDS viruses: type 1
    % (HIV-1) and type 2 (HIV-2). Both strains represent cross-species
    % infections. The primate reservoir of HIV-2 has been clearly
    % identified as the sooty mangabey  (Cercocebus atys). The origin of
    % HIV-1 is believed to be the common chimpanzee (Pan troglodytes).
    %
    % References:
    %   "Origin of HIV-1 in the chimpanzee Pan troglodytes troglodytes" 
    %     Nature 397(6718), 436-41 (1999)
    %   "Comparison of simian immunodeficiency virus isolates"
    %     Nature 331(6157), 619-622 (1988)
    %   "Genetic variability of the AIDS virus: nucleotide sequence analysis"
    %     of two isolates from African patients. Cell 46 (1), 63-74 (1986)
    
    fig = pDemoFigure();
    clf(fig);
    set(fig, 'Visible', 'off');
    
    % Retrieve sequence information from GenBank
    %
    % In this example, the variations in three longest coding regions from
    % seventeen different isolated strains of the Human and Simian
    % immunodeficiency virus are used to construct a phylogentic tree. The
    % sequences for these virus strains can be retrieved from GenBank using
    % their accession numbers. The coding region of interest, the POL
    % protein can then be extracted from the sequences using the CDS 
    % information in the GenBank records.
    
    %        Description                   Accession  CDS:gag/pol/env 
    data = {'SIVmon Cercopithecus Monkeys' 'AY340701' [1 2 8]  ;
            'SIVcpzTAN1 Chimpanzee'        'AF447763' [1 2 8]  ;
            'HIV1-NDK (Zaire)'             'M27323'   [1 2 8]  ;
            'HIV-1 (Zaire)'                'K03454'   [1 2 8]  ;
            'CIVcpzUS Chimpanzee'          'AF103818' [1 2 8]  ;
            'SIVcpz Chimpanzees Cameroon'  'AF115393' [1 2 8]  ;
            'SIVsmSL92b Sooty Mangabey'    'AF334679' [1 2 8]  ;
            'SIVMM239 Simian macaque'      'M33262'   [1 2 8]  ;
            'SIVMM251 Macaque'             'M19499'   [1 2 8]  ;
            'HIV-2UC1 (IvoryCoast)'        'L07625'   [1 2 8]  ;
            'HIV2-MCN13'                   'AY509259' [1 2 8]  ;
            'HIV-2 (Senegal)'              'M15390'   [1 2 8]  ;
            'SIVAGM3 Green monkeys'        'M30931'   [1 2 7]  ;
            'SIVAGM677A Green monkey'      'M58410'   [1 2 7]  ;
            'SIVmnd5440 Mandrillus sphinx' 'AY159322' [1 2 8]  ;
            'SIVlhoest L''Hoest monkeys'   'AF075269' [1 2 7]  ;
            };
    maxNumViruses = size(data, 1);
    defaultNumViruses = maxNumViruses;
    minNumViruses = 3;
    % Scale the computations according to the difficulty level.  We know
    % that the computational time grows quadratically by the number of
    % viruses, so we change the number of viruses by the square root of
    % the difficulty level. 
    numViruses = round(defaultNumViruses*sqrt(difficulty));
    numViruses = max(minNumViruses, min(numViruses, maxNumViruses));

    data = data(1:numViruses, :);
    description = data(:,1);

    % You can use the *getgenbank* function to copy the data from NCBI GenBank
    % database into a structure in MATLAB. The SearchURL field of the structure
    % contains the address of the actual GenBank record. You can access
    % this record using the *web* command.
    fprintf('Downloading data from the NCBI GenBank database\n');
    for ind = 1:numViruses
        seqs_hiv(ind) = getgenbank(data{ind, 2});
    end
    fprintf('Finished downloading\n');

    % Extract CDS for the POL coding regions. Then extract the nucleotide
    % sequences  using the CDS pointers.
    pol = struct('Sequence', cell(1, numViruses));
    for ind = 1:numViruses
        temp_seq = seqs_hiv(ind).Sequence; 
        temp_seq = regexprep(temp_seq, '[nry]', 'a');
        CDSs = seqs_hiv(ind).CDS(data{ind, 3});
        pol(ind).Sequence = temp_seq(CDSs(2).indices(1):CDSs(2).indices(2)); 
    end
end % End of pctdemo_setup_hiv.
