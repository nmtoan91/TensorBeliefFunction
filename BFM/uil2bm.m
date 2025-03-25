function protocol = uil2bm(uilfilename, bmfilename)
% UIL2BM converts belief data from the Unified Interface Language to the format that BM accepts
% uilfilename: is the name of the file (text) that contains the data in UIL format
% bmfilename: is the file name for the file that contains converted data
% nrofbelief: number of beliefs in the converted data
% TRANPROTOCOL is a structure with following fields
%   .date:      the date of translation
%   .uilfile:   input file name
%   .bmfile:    output file name
%   .listbels:  the list of beliefs created
%   .listvars:  the list of variales created
%   .listframes:the list of frames
%   .comprequest()  array of computation requests
%       .lastbelnumber:  the last belief used in computation
%       .reqlistvars:   variable list on which marginals are required

global VARIABLE FRAME BELIEF TRANPROTOCOL;

existence = exist(uilfilename, 'file');
if existence==0
    fprintf('Input UIL file %s does not exist.\n', uilfilename);
    return
end
stmt_cells = local_readstmt(uilfilename);
stmt_counter = length(stmt_cells);

uilrelcount = 0;
uilfsmcount = 0;

bmvarcount = 0;
bmfracount = 0;
bmbelcount = 0;
bmrequest = 0;

frametype = cell(1,7);
frametype{1}='logical';
frametype{2}='binary';
frametype{3}='class unordered';
frametype{4}='class ordered';
frametype{5}='integer';
frametype{6}='interval';
frametype{7}='continuous';

belieflist = [];            % initiate values
variablelist = [];
framelist = [];

for i=1:stmt_counter
	thestatement=stmt_cells{i};
	if strncmp(thestatement, 'DEFINE VARIABLE', 15)
        thestatement(1:16)=[];
        readcells = readwords(thestatement);
        nofcells = length(readcells);
        if (nofcells == 1) & isempty(readcells{1})
            fprintf('Error occurs in statement # %d (DEFINE VARIABLE).\n', i);
            return
        elseif (nofcells > 1) & isempty(readcells{nofcells})
            readcells(nofcells)=[];
        end
            
        nrofword = length(readcells);
        if nrofword <= 1
            fprintf('Error occurs in statement # %d (DEFINE VARIABLE).\n', i);
            return
        end
        
        bmfracount=bmfracount+1;
        bmframe(bmfracount).number = bmfracount;
        bmframe(bmfracount).full_name = sprintf('Frame_%u', bmfracount);
        bmframe(bmfracount).short_name = sprintf('F%u', bmfracount);
        bmframe(bmfracount).type = frametype{4};
        bmframe(bmfracount).cardinality = nrofword -1;
        bmframe(bmfracount).elements = strvcat(readcells{2:nrofword});
        framelist = [framelist bmfracount];     % add frame idnumber into framelist
        
        bmvarcount = bmvarcount+1;
        bmvariable(bmvarcount).number = bmvarcount;
        bmvariable(bmvarcount).full_name = readcells{1};
        if length(readcells{1}) >= 5
            strshortname = readcells{1}(1:5);
        else
            strshortname = readcells{1};
        end
        bmvariable(bmvarcount).short_name = strshortname;
        bmvariable(bmvarcount).attribute = [];
        bmvariable(bmvarcount).index_value = [];
        bmvariable(bmvarcount).frame = bmfracount;
        variablelist = [variablelist bmvarcount];   % add var idnumber

    elseif strncmp(thestatement, 'DEFINE RELATION', 15)
        thestatement(1:16)=[];
        readcells = readwords(thestatement);
        nofcells = length(readcells);
        if (nofcells == 1) & isempty(readcells{1})
            fprintf('Error occurs in statement # %d (DEFINE RELATION).\n', i);
            return
        elseif (nofcells > 1) & isempty(readcells{nofcells})
            readcells(nofcells)=[];
        end
        
        nrofword = length(readcells);
        if nrofword <= 1
            fprintf('Error occurs in statement # %d (DEFINE RELATION).\n', i);
            return
        end

        uilrelcount=uilrelcount+1;
        uilrelations(uilrelcount).name = readcells{1};
        uilrelations(uilrelcount).domain = readcells(2:nrofword);

        listofindx = extstrmatch(uilrelations(uilrelcount).domain, {bmvariable(:).full_name});
        if ~isempty(find(listofindx==0))
            fprintf('Error occurs in statement # %d (DEFINE RELATION).\n', i);
            fprintf('A variable in the domain is not defined.\n');
            return
        end
        listofvarid = [bmvariable(listofindx).number];
        uilrelations(uilrelcount).domvarid = listofvarid;

    %%%%%%%%%%%%%%%%%%%% begin for DEFINE CONDITIONAL RELATION
    elseif strncmp(thestatement, 'DEFINE CONDITIONAL RELATION', 27)
        thestatement(1:28)=[];
        readcells = readwords(thestatement);
        nofcells = length(readcells);
        if (nofcells == 1) & isempty(readcells{1})
            fprintf('Error occurs in statement # %d (DEFINE CONDITIONAL RELATION).\n', i);
            return
        elseif (nofcells > 1) & isempty(readcells{nofcells})
            readcells(nofcells)=[];
        end
        
        nrofword = length(readcells);
        if nrofword <= 1
            fprintf('Error occurs in statement # %d (DEFINE CONDITIONAL RELATION).\n', i);
            return
        end

        uilrelcount=uilrelcount+1;
        uilrelations(uilrelcount).name = readcells{1};
        matchlist = extstrmatch(readcells, 'GIVEN');
        wordgivenpos = find(matchlist);
        if isempty(wordgivenpos)
            fprintf('Word GIVEN is not found.\n');
            return
        end
        
        uilrelations(uilrelcount).domain = readcells(2:wordgivenpos-1);
        uilrelations(uilrelcount).condidomain = readcells(wordgivenpos+1:nrofword);

        listofindx = extstrmatch(uilrelations(uilrelcount).domain, {bmvariable(:).full_name});
        if ~isempty(find(listofindx==0))
            fprintf('Error occurs in statement # %d (DEFINE CONDITIONAL RELATION).\n', i);
            fprintf('A variable %s in the domain is not defined.\n', uilrelations(uilrelcount).domain{find(listofindx==0)});
            return
        end
        listofvarid = [bmvariable(listofindx).number];
        uilrelations(uilrelcount).domvarid = listofvarid;

        listofindx = extstrmatch(uilrelations(uilrelcount).condidomain, {bmvariable(:).full_name});
        if ~isempty(find(listofindx==0))
            fprintf('Error occurs in statement # %d (DEFINE CONDITIONAL RELATION).\n', i);
            fprintf('A variable %s in the domain is not defined.\n', uilrelations(uilrelcount).condidomain{find(listofindx==0)});
            return
        end
        listofcondvarid = [bmvariable(listofindx).number];
        uilrelations(uilrelcount).condvarid = listofcondvarid;
    %%%%%%%%%%%%%%%%%%%% begin for DEFINE CONDITIONAL RELATION

    %%%%%%%%% begin for SET CONDITIONAL VALUATION
    elseif strncmp(thestatement, 'SET CONDITIONAL VALUATION', 25)
        thestatement(1:26)=[];
        
        strtfspos = find(thestatement == '{');
        finifspos = find(thestatement == '}');
        if ~(length(strtfspos)==length(finifspos))
            fprintf('Error occurs in statement # %d (SET CONDITIONAL VALUATION).\n', i);
            fprintf('Mismatch numbers of openning and closing brackets.\n');
            return
        elseif ~isempty(find(strtfspos > finifspos))
            fprintf('Error occurs in statement # %d (SET CONDITIONAL VALUATION).\n', i);
            fprintf('Mismatch positions of brackets.\n');
            return
        end
        
        wordpos = read1word(thestatement,1);    % read the first word
        relname = wordpos.word;                 % take the name of relation
        currposition = wordpos.lastpos + 1;     % the position after the word
        wordpos = read1word(thestatement,currposition);
        
        atoken = wordpos.word;
        if ~strncmp(atoken, 'GIVEN', 5)
            fprintf('Error occurs in statement # %d (SET CONDITIONAL VALUATION).\n', i);
            fprintf('Key word GIVEN not found.\n');
            return
        end
        
        if exist('uilrelations')
            rel_id = strmatch(relname, {uilrelations(:).name}, 'exact');     % determine relation_id from relation_name
        else
            rel_id = [];
        end

        if isempty(rel_id)
            fprintf('Error occurs in statement # %d (SET CONDITIONAL VALUATION).\n', i);
            fprintf('The name of relation is not declared.\n');
            return
        else
            nvarindom = length(uilrelations(rel_id).domain);        % nr of vars in domain
            thedomain = uilrelations(rel_id).domvarid;              % the list of var_ids in the domain
            theframes = cell(length(thedomain));
            for j=1:length(thedomain)           % extract frames
                theframes(j) = {bmframe(bmvariable(thedomain(j)).frame).elements};
            end
            condidomain = uilrelations(rel_id).condvarid;
            condiframes = cell(length(condidomain));
            for j=1:length(condidomain)           % extract frames
                condiframes(j) = {bmframe(bmvariable(condidomain(j)).frame).elements};
            end
        end
        
        nrofopenbraket = length(strtfspos);

        % extract conditioning instance
        tmp_strfoset = thestatement(strtfspos(1):finifspos(1));
        strelems = readwords(tmp_strfoset);
        nofcells = length(strelems);
        if (nofcells == 1) & isempty(strelems{1})      % empty focal set
            fprintf('Error occurs in statement # %d (SET CONDITIONAL VALUATION).\n', i);
            fprintf('Conditioning instance is not found.\n');
            return
        else                                            % normal focal set
            if (nofcells > 1) & isempty(strelems{nofcells})    % the last word is empty
                strelems(nofcells)=[];
            end
            nrofword = length(strelems);
            condicode = zeros(nrofword, 1);
            for j=1:nrofword            % convert elem given as strings to their code
                theword = strelems{j};
                thecode = strmatch(theword, condiframes(j), 'exact');
                if ~isempty(thecode)
                    condicode(j) = thecode(1);
                else
                    fprintf('Error occurs in statement # %d (SET or COMBINE RELATION).\n', i);
                    fprintf('The element %s is not defined in its frame.\n', theword);
                    return
                end
            end
        end
        % end of conditioning extraction
        
        noffosets = nrofopenbraket;             % each foset is begin with '{'
        massvalues = zeros(1, noffosets-1);       % to store the masses
        for k=1:noffosets-1                       % skip the first for conditioning instance
            wordpos = read1word(thestatement, finifspos(k+1)+1);
            if ~isempty(wordpos)
                
                massvalues(k) = str2num(wordpos.word);
            else
                warning('Cann''t find mass after a focal set.')
            end
        end
        
        bmcodefos = cell(noffosets,1);          % to store bm coding of focal sets
        for k=2:noffosets
            tmp_strfoset = thestatement(strtfspos(k):finifspos(k));
            strelems = readwords(tmp_strfoset);
            nofcells = length(strelems);
            if (nofcells == 1) & isempty(strelems{1})      % empty focal set
                tmpcodefos = zeros(2*nvarindom,1);
                tmpcodefos(nvarindom+1:2*nvarindom) = repmat(-1, [nvarindom, 1]);
                nrows = 2;
                ncols = nvarindom;
            else                                            % normal focal set
                if (nofcells > 1) & isempty(strelems{nofcells})    % the last word is empty
                    strelems(nofcells)=[];
                end
                nrofword = length(strelems);
                tmpcodefos = zeros(nrofword+nvarindom, 1);
                for j=1:nrofword            % convert elem given as strings to their code
                    theword = strelems{j};
                    indxfrm = mod(j, nvarindom);
                    if indxfrm==0
                        indxfrm=nvarindom;
                    end
                    thecode = strmatch(theword, theframes(indxfrm), 'exact');
                    if ~isempty(thecode)
                        tmpcodefos(j) = thecode(1);
                    else
                        fprintf('Error occurs in statement # %d (SET or COMBINE RELATION).\n', i);
                        fprintf('The element %s is not defined in its frame.\n', theword);
                        return
                    end
                end
                tmpcodefos(nrofword+1:nrofword+nvarindom)=repmat(-1, [nvarindom, 1]); % separation line
                nrows = nrofword/nvarindom + 1;
                ncols = nvarindom;
            end
            
            if ~(floor(nrows)==nrows)
                fprintf('Error occurs in statement # %d (SET or COMBINE RELATION).\n', i);
                fprintf('Foset number = %d\n', i);
                fprintf('Number of words = %d\n', nrofword);
                fprintf('Number of variables = %d\n', nvarindom);
                return
            end
            bmcodefos{k}=reshape(tmpcodefos, [ncols, nrows])';
        end
        
        fosets = cat(1, bmcodefos{:});
        
        % prepare data for set2intmat.m
        varsum.nums = [bmvariable(:).number];
        frmnums = [bmvariable(:).frame];
        allfrmnumbers = [bmframe(:).number];
        frmindx = extfind(frmnums, allfrmnumbers);
        varsum.card = [bmframe(frmindx).cardinality];
        
        bmfs.domain = thedomain;
        bmfs.indices = fosets;
        bmfs.values = massvalues';

        intfosets = set2intmat(varsum, bmfs);   % conversion into integer mat form
		mvalues = bmfs.values;                  % masses given

        if sum(massvalues) < 1          % check if there is a mass to tautology
            remmass = 1 - sum(massvalues);
            [nfoset, nwords] = size(intfosets);
            thisdomainindx = extfind(thedomain, varsum.nums);
            thiscardvec = varsum.card(thisdomainindx);
            framesize = prod(thiscardvec);
            lastwordsize = mod(framesize, 50);  % the size of last words in int matrix
            if lastwordsize == 0
                lastwordsize = 50;
            end
            intvectauto = zeros(1, nwords);
            intvectauto(nwords) = bin2dec(repmat('1', [1 lastwordsize]));   % the last int
            if nwords > 1
                num50bit = bin2dec(repmat('1', [1 50]));
                for h = 1:nwords-1
                    intvectauto(h) = num50bit;
                end
            end
            intfosets = cat(1, intfosets, intvectauto);
            mvalues = cat(1, mvalues, remmass);
        end
        
        sortintfoset = cat(2,intfosets, mvalues);   % for sorting by mass values
        [srtrows, srtcols] = size(sortintfoset);
        sortintfoset = sortrows(sortintfoset, srtcols);
        sortintfoset = sortintfoset(srtrows:-1:1,:);    % reverse order
        intfosets = sortintfoset(:, 1:srtcols-1);       % recover intfoset
        mvalues = sortintfoset(:, srtcols);

        dmindx = extfind(thedomain, varsum.nums);
        if ~isempty(find(dmindx==0))
            fprintf('Error occurs in statement # %d (SET or COMBINE RELATION).\n', i);
            fprintf('A variable in domain not defined.\n');
            return
        end
        dmcard = varsum.card(dmindx);

        bmbelcount = bmbelcount+1;
        bmbelief(bmbelcount).number = bmbelcount;
        bmbelief(bmbelcount).full_name = relname;
        if length(relname) >= 5
            strshortname = relname(1:5);
        else
            strshortname = relname;
        end
        bmbelief(bmbelcount).short_name = strshortname;
		bmbelief(bmbelcount).disposable = 0;		
		bmbelief(bmbelcount).agent = 'You';		  
		bmbelief(bmbelcount).time = 1;			
		bmbelief(bmbelcount).ec = [];
		bmbelief(bmbelcount).domain_variable = thedomain;
		bmbelief(bmbelcount).domain_cardinality = dmcard;

        bmbelief(bmbelcount).conditioning_variable.var_num = condidomain;
		bmbelief(bmbelcount).conditioning_variable.instance = condicode;
        
        bmbelief(bmbelcount).bp(1).form(1).type = 'm'; 
        bmbelief(bmbelcount).bp(1).form(1).ordered = 1;             % 1 = ordered by masses
		bmbelief(bmbelcount).bp(1).form(1).focal_sets = intfosets;   
		bmbelief(bmbelcount).bp(1).form(1).values = mvalues;        % masses given
        belieflist = [belieflist bmbelcount];
        %%%%%%%%% end of SET CONDITIONAL VALUATION

    elseif strncmp(thestatement, 'SET VALUATION', 13) | strncmp(thestatement, 'COMBINE VALUATION', 17)
        if strncmp(thestatement, 'SET VALUATION', 13)
            thestatement(1:14)=[];
        else
            thestatement(1:18)=[];
        end
        
        strtfspos = find(thestatement == '{');
        finifspos = find(thestatement == '}');
        if ~(length(strtfspos)==length(finifspos))
            fprintf('Error occurs in statement # %d (SET or COMBINE RELATION).\n', i);
            fprintf('Mismatch numbers of openning and closing brackets.\n');
            return
        elseif ~isempty(find(strtfspos > finifspos))
            fprintf('Error occurs in statement # %d (SET or COMBINE RELATION).\n', i);
            fprintf('Mismatch positions of brackets.\n');
            return
        end
        
        wordpos = read1word(thestatement,1);  % read the first word
        relname = wordpos.word;               % take the name of relation
        if exist('uilrelations')
            rel_id = strmatch(relname, {uilrelations(:).name}, 'exact');     % determine relation_id from relation_name
        else
            rel_id = [];
        end
        if ~isempty(rel_id)
            nvarindom = length(uilrelations(rel_id).domain);        % nr of vars in domain
            thedomain = uilrelations(rel_id).domvarid;              % the list of var_ids in the domain
            theframes = cell(length(thedomain));
            for j=1:length(thedomain)           % extract frames
                theframes(j) = {bmframe(bmvariable(thedomain(j)).frame).elements};
            end
        else                                    % belief on one variable
            varname = wordpos.word;
            var_indx = strmatch(varname, {bmvariable(:).full_name}, 'exact');    % look for variable id
            if ~isempty(var_indx)
                nvarindom = 1;          % consists of 1 var 
                thedomain = bmvariable(var_indx).number;
                theframes = {bmframe(bmvariable(var_indx).frame).elements};
            else
                fprintf('Error occurs in statement # %d (SET or COMBINE RELATION).\n', i);
                fprintf('Valuation name is not defined. Relation name: %s.\n', relname);
                return
            end
        end
        
        noffosets = length(strtfspos);          % each foset is begin with '{'
        massvalues = zeros(1, noffosets);       % to store the masses
        for k=1:noffosets
            wordpos = read1word(thestatement, finifspos(k)+1);
            if ~isempty(wordpos)
                massvalues(k) = str2num(wordpos.word);
            else
                warning('Cann''t find mass after a focal set.')
            end
        end
        
        bmcodefos = cell(noffosets,1);          % to store bm coding of focal sets
        for k=1:noffosets
            tmp_strfoset = thestatement(strtfspos(k):finifspos(k));
            strelems = readwords(tmp_strfoset);
            nofcells = length(strelems);
            if (nofcells == 1) & isempty(strelems{1})      % empty focal set
                tmpcodefos = zeros(2*nvarindom,1);
                tmpcodefos(nvarindom+1:2*nvarindom) = repmat(-1, [nvarindom, 1]);
                nrows = 2;
                ncols = nvarindom;
            else                                            % normal focal set
                if (nofcells > 1) & isempty(strelems{nofcells})    % the last word is empty
                    strelems(nofcells)=[];
                end
                nrofword = length(strelems);
                tmpcodefos = zeros(nrofword+nvarindom, 1);
                for j=1:nrofword            % convert elem given as strings to their code
                    theword = strelems{j};
                    indxfrm = mod(j, nvarindom);
                    if indxfrm==0
                        indxfrm=nvarindom;
                    end
                    thecode = strmatch(theword, theframes(indxfrm), 'exact');
                    if ~isempty(thecode)
                        tmpcodefos(j) = thecode(1);
                    else
                        fprintf('Error occurs in statement # %d (SET or COMBINE RELATION).\n', i);
                        fprintf('The element %s is not defined in its frame.\n', theword);
                        return
                    end
                end
                tmpcodefos(nrofword+1:nrofword+nvarindom)=repmat(-1, [nvarindom, 1]); % separation line
                nrows = nrofword/nvarindom + 1;
                ncols = nvarindom;
            end
            
            if ~(floor(nrows)==nrows)
                fprintf('Error occurs in statement # %d (SET or COMBINE RELATION).\n', i);
                fprintf('Foset number = %d\n', i);
                fprintf('Number of words = %d\n', nrofword);
                fprintf('Number of variables = %d\n', nvarindom);
                return
            end
            bmcodefos{k}=reshape(tmpcodefos, [ncols, nrows])';
        end
        
        fosets = cat(1, bmcodefos{:});
        
        % prepare data for set2intmat.m
        varsum.nums = [bmvariable(:).number];
        frmnums = [bmvariable(:).frame];
        allfrmnumbers = [bmframe(:).number];
        frmindx = extfind(frmnums, allfrmnumbers);
        varsum.card = [bmframe(frmindx).cardinality];
        
        bmfs.domain = thedomain;
        bmfs.indices = fosets;
        bmfs.values = massvalues';

        intfosets = set2intmat(varsum, bmfs);   % conversion into integer mat form
		mvalues = bmfs.values;                  % masses given

        if sum(massvalues) < 1          % check if there is a mass to tautology
            remmass = 1 - sum(massvalues);
            [nfoset, nwords] = size(intfosets);
            thisdomainindx = extfind(thedomain, varsum.nums);
            thiscardvec = varsum.card(thisdomainindx);
            framesize = prod(thiscardvec);
            lastwordsize = mod(framesize, 50);  % the size of last words in int matrix
            if lastwordsize == 0
                lastwordsize = 50;
            end
            intvectauto = zeros(1, nwords);
            intvectauto(nwords) = bin2dec(repmat('1', [1 lastwordsize]));   % the last int
            if nwords > 1
                num50bit = bin2dec(repmat('1', [1 50]));
                for h = 1:nwords-1
                    intvectauto(h) = num50bit;
                end
            end
            intfosets = cat(1, intfosets, intvectauto);
            mvalues = cat(1, mvalues, remmass);
        end
        
        sortintfoset = cat(2,intfosets, mvalues);   % for sorting by mass values
        [srtrows, srtcols] = size(sortintfoset);
        sortintfoset = sortrows(sortintfoset, srtcols);
        sortintfoset = sortintfoset(srtrows:-1:1,:);    % reverse order
        intfosets = sortintfoset(:, 1:srtcols-1);       % recover intfoset
        mvalues = sortintfoset(:, srtcols);

        dmindx = extfind(thedomain, varsum.nums);
        if ~isempty(find(dmindx==0))
            fprintf('Error occurs in statement # %d (SET or COMBINE RELATION).\n', i);
            fprintf('A variable in domain not defined.\n');
            return
        end
        dmcard = varsum.card(dmindx);

        bmbelcount = bmbelcount+1;
        bmbelief(bmbelcount).number = bmbelcount;
        bmbelief(bmbelcount).full_name = relname;
        if length(relname) >= 5
            strshortname = relname(1:5);
        else
            strshortname = relname;
        end
        bmbelief(bmbelcount).short_name = strshortname;
		bmbelief(bmbelcount).disposable = 0;		
		bmbelief(bmbelcount).agent = 'You';		  
		bmbelief(bmbelcount).time = 1;			
		bmbelief(bmbelcount).ec = [];
		bmbelief(bmbelcount).domain_variable = thedomain;
		bmbelief(bmbelcount).domain_cardinality = dmcard;
		bmbelief(bmbelcount).conditioning_variable = [];
        bmbelief(bmbelcount).bp(1).form(1).type = 'm'; 
        bmbelief(bmbelcount).bp(1).form(1).ordered = 1;             % 1 = ordered by masses
		bmbelief(bmbelcount).bp(1).form(1).focal_sets = intfosets;   
		bmbelief(bmbelcount).bp(1).form(1).values = mvalues;        % masses given
        belieflist = [belieflist bmbelcount];
    
    elseif strncmp(thestatement, 'PRINT VALUATION', 15)
        thestatement(1:16)=[];
        wordpos = read1word(thestatement,1);  % read the first word
        relname = wordpos.word;               % take the name of relation
        belindx = strmatch(relname, {bmbelief(:).full_name}, 'exact');
        if ~isempty(belindx)
            if length(belindx) > 1
                belindx = belindx(1);
            end
            bmrequest = bmrequest + 1;
            crequest(bmrequest).lastbelnumber = bmbelcount;
            crequest(bmrequest).reqlistvars = bmbelief(belindx).domain_variable;
        else
            belindx = strmatch(relname, {bmvariable(:).full_name}, 'exact');
            if ~isempty(belindx)
                bmrequest = bmrequest + 1;
                crequest(bmrequest).lastbelnumber = bmbelcount;
                crequest(bmrequest).reqlistvars = bmvariable(belindx).number;
            else
                fprintf('PRINT relation does not exist.\n');
            end
        end
    end
end

VARIABLE = bmvariable;
FRAME = bmframe;
BELIEF = bmbelief;
TRANPROTOCOL.datetime = now;
TRANPROTOCOL.uilfile = uilfilename;
TRANPROTOCOL.bmfile = bmfilename;
TRANPROTOCOL.listbels = belieflist;
TRANPROTOCOL.listvars = variablelist;
TRANPROTOCOL.listframes = framelist;
if exist('crequest')
    TRANPROTOCOL.comprequest = crequest;
else
    TRANPROTOCOL.comprequest = [];
end

[commandsave errmessage] = sprintf('save %s VARIABLE FRAME BELIEF TRANPROTOCOL', bmfilename);
eval(commandsave);

%%%%%%%%%%%%%%%% end of UIL2BM

function stmtcellarray = local_readstmt(readfname)
% LOCAL_READSTMT reads lines from READFNAME and put statements in an cell array STMTCELLARRAY
% input: readfname is a text file name (default extension .txt)
% output: stmtcellarray a cell array in each cell is a statement

isfullname = ~isempty(find(readfname=='.'));
if isfullname
	fid = fopen(readfname, 'rt');
else 
    readfname = [readfname '.txt'];
    fid = fopen(readfname, 'rt');
end
if isempty(fid)
    fprintf('Could not find file %s', readfname);
    error('Error in open file.'); 
end

comment_sym='#';
endstmt_sym=';';
blank_sym = ' ';

stmt_len  = 10000;                      % the max length of a statement
maxofstmt = 10000;

tmp_stmt = repmat(blank_sym, stmt_len);       % to store the current statement

stmtcellarray = cell(maxofstmt,1);      % cell array containing statements
stmt_counter = 0;
tmpstmt_pos = 1;                        % the next position

% read uil file line by line
while ~feof(fid)
    tline = fgetl(fid);
    if isempty(tline) | strncmp(tline, comment_sym, 1)      % the line is a comment line or empty line
        continue
    end
    
    tline = local_cleanup(tline);       % remove unnecessary (successive) blanks, comments
    if isempty(tline)
        continue
    end
    smcolon_pos = find(endstmt_sym == tline);   % find positions of ';'
    lentline=length(tline);
    seensmcolon = 0;

    if isempty(smcolon_pos)     % no ';' in the line, copy into tmp_stmt
        seensmcolon = 0;        % the statement is not finished 
        tmp_stmt(tmpstmt_pos: (tmpstmt_pos + lentline - 1))=tline;
        tmpstmt_pos = tmpstmt_pos + lentline;
    else
        nrofcmcolon = length(smcolon_pos);
        startpos = [1, smcolon_pos+1];              % starting position of a statement
        endinpos = [smcolon_pos-1, length(tline)];  % ending position 
        
        for i = 1:nrofcmcolon
            if seensmcolon == 0         % previous line does not complete the statement
                if smcolon_pos(i) > 1   % symbol ';' does not occurs at the beginning of line
                    tmp_stmt(tmpstmt_pos:(tmpstmt_pos + smcolon_pos(i) - 2))=tline(1:smcolon_pos(i)-1);
                    tmpstmt_pos = tmpstmt_pos + smcolon_pos(i)-1;
                    seensmcolon=1;
                end
                stmt_counter=stmt_counter+1;        % add the statement into the cell array
                stmtcellarray(stmt_counter) = {tmp_stmt(1:tmpstmt_pos-1)};
                tmpstmt_pos = 1;
            else    % seensmcolon == 1 when previous statement has been complete
                if startpos(i) < endinpos(i) 
                    stmt_counter=stmt_counter+1;        % add the statement into the cell array
                    stmtcellarray(stmt_counter) = {tline(startpos(i):endinpos(i))};
                end
            end
        end
        
        if startpos(nrofcmcolon+1) < endinpos(nrofcmcolon+1)  % last ';' does not occur at line's end
            len = endinpos(nrofcmcolon+1) - startpos(nrofcmcolon+1)+1;
            tmp_stmt(1:len)=tline(startpos(nrofcmcolon+1): endinpos(nrofcmcolon+1));
            seensmcolon=0;
            tmpstmt_pos=len+1;
        end
    end
end

status = fclose(fid);       % close the file
stmtcellarray(stmt_counter+1:maxofstmt)=[];        % remove unused cells

%%%%%%%%%%%%%%% end of LOCAL_READSTMT

function outline = local_cleanup(inline)
% LOCAL_CLEANUP cleans the inline
% Input: inline -- a line of text
% Output: outline -- cleaned line

comment_sym = '#';
blank_sym = ' ';

len = length(inline);
markline = zeros(1, len);

comment_pos = find(inline == comment_sym);
if ~isempty(comment_pos)
    inline(comment_pos(1):end)=[];
end

len = length(inline);

spacepos = isspace(inline);         % replace tab by space
inline(spacepos)=blank_sym;

blankbefore = 1;
for i = 1:len
    if inline(i)==blank_sym
        if blankbefore == 1
            markline(i)=1;
        else
            blankbefore = 1;
        end
    elseif (inline(i) == ';' | inline(i) == ',')
        blankbefore = 1;
    else
        blankbefore = 0;
    end
end
pos_vec=find(markline);
if ~isempty(pos_vec)
    inline(pos_vec)=[];
end

if ~isempty(inline)
    if inline(end) ~= blank_sym     % add a blank to the end of line as separation
        inline = [inline blank_sym];
    end
else
    fprintf('Warning: An empty command line.\n');
end
outline = inline;
%%%%%%%%%% end of LOCAL_CLEANUP