function [charmat] = showbel(toshowlist, showform, numberformat)
%SHOWBEL shows belief potentials
% it prints a belief after another belief
% for each belief information includes
%   a belief's id_number
%   the list of variables in the domain
%   a 2-D matrix contains focal sets in the coordinate forms
%       each elem is represented by a coordinate vector
%       each foset ends by a row of -1s
%       the last column contains masses
% VARIABLE variable cell array
% BELIEF  belief cell array
% FRAME   frame cell array
% TOSHOWLIST: list of belief ids to be shown
% showform -- a variable that can take either 
% showform = 'label' show element's label (this option is default)
% showform = 'code' show element's code or index
% numberformat = 'fixed' shows mass with 5 decimal digits
% numberformat = 'scientific' shows mass in scientific format 
% last update: Nov 22, 2002

global BELIEF VARIABLE FRAME;

if nargin==1
    showform = 'label';         % show labels of elems; otherwise it shows code
    numberformat = 'fixed';     % default is fixed format; otherwise use scientific
elseif nargin==2
    numberformat = 'fixed';
end

if ischar(toshowlist)
    listbel_name = toshowlist;
    cellbelname = readwords(listbel_name);
    indxbelinput = extstrmatch(cellbelname, {BELIEF(:).full_name});
    if ~isempty(find(indxbelinput==0))
        error('Belief(s) in query are not found.')
    end
    toshowlist = [BELIEF(indxbelinput).number];
end

indx_bel=extfind(toshowlist, [BELIEF(:).number]);
remindx = find(indx_bel==0);                % find non-existant bel numbers in input
indx_bel(remindx)=[];                       % remove 0 from indx_bel
if isempty(indx_bel)
    fprintf('Belief not found.\n');
end
varref=varreference([VARIABLE(:).number]);

for counter=1:length(indx_bel)
    currbel_indx=indx_bel(counter);
    
    thisdomain = BELIEF(currbel_indx).domain_variable;
    indxvec=extfind(thisdomain, varref.nums);
    cardvec=varref.card(indxvec);
    framesize=prod(cardvec);
    nrofforms = length(BELIEF(currbel_indx).bp(1).form);    % number of forms (mass, pignistic, plausibilistic)

    for formcounter = 1:nrofforms           % loop on forms of belief potentials
        intfocalsets = BELIEF(currbel_indx).bp(1).form(formcounter).focal_sets;
        masses=BELIEF(currbel_indx).bp(1).form(formcounter).values;

        bitvmat=int2bitv(intfocalsets, framesize);
        var1.nums=thisdomain;
        var1.card=cardvec;
        crdnfoset = bvec2set(bitvmat, var1);
        [nrows, ncols]=size(crdnfoset);
        if strncmp(showform, 'code', 4)         % prepare focal sets in charmatfoset
            charmatfoset=num2str(crdnfoset);
        else
            celllabels=code2label(crdnfoset, thisdomain);
            charmatfoset=cat(2,celllabels{:}); 
        end

        separation_indx=find(crdnfoset(:,1)==-1);
        lensep=length(separation_indx);
        if lensep==1
            acopy_sepa_indx=0;
        else
            acopy_sepa_indx=[0 separation_indx(1:lensep-1)']';
        end
        masspositions=floor((separation_indx+acopy_sepa_indx)./2);

        % start processing a mass column
        [nrfoset, nrofmassvec] = size(masses);      % number of focal sets and number of mass vectors
        for valueveccount = 1:nrofmassvec
            lastcol=zeros(nrows,1);
            thismassvector = masses(:,valueveccount);
            lastcol(masspositions)=thismassvector;
            tnrows = length(lastcol);
            if strcmp(numberformat, 'scientific')
                lennumstr = length(sprintf('%e', lastcol(1)));
            else
                lennumstr = length(sprintf('%.5f', lastcol(1)));
            end

            charmatmasse = repmat(' ',[tnrows lennumstr]);              % '%e' format requires 13 places; former length=7
            if strcmp(numberformat, 'scientific')
                for i=1:tnrows
                    if ~(lastcol(i)==0)
                        charmatmasse(i,:)=sprintf('%e', lastcol(i));     % scientific format
                    end
                end
            else
                for i=1:tnrows
                    if ~(lastcol(i)==0)
                        charmatmasse(i,:)=sprintf('%.5f', lastcol(i));   % fixed format with 5 places after dec
                    end
                end
            end
            sep_col=repmat('| ', size(lastcol));
		
            [nintrows nintcols] = size(intfocalsets);   % prepare for nomalization
            intemptyfoset = zeros(1, nintcols);         % representation of an empty focus
            emptyfosetpos = 0;                          % if no empty foset position == 0
            normaliconst = 1;
            normaliconst2 = 0;
            for i=1:nintrows
                arow = intfocalsets(i,:);
                if isequal(arow, intemptyfoset)
                    emptyfosetpos = i;                  % if yes position is stored
                    normaliconst = 1 - thismassvector(i);
                else
                    normaliconst2 = normaliconst2 + thismassvector(i);
                end
            end
            if normaliconst < 0
                normaliconst = normaliconst2;
            end
            if emptyfosetpos ~= 0
                normalizedmass = thismassvector./normaliconst;
                normalizedmass(emptyfosetpos) = 0;
                normalizedcol = zeros(tnrows, 1);
                normalizedcol(masspositions) = normalizedmass;
		
                normcharmatmasse = repmat(' ',[tnrows lennumstr]);              % '%e' format requires 13 places; former length=7
                if strcmp(numberformat, 'scientific')
                    for i=1:tnrows
                        if ~(normalizedcol(i)==0)
                            normcharmatmasse(i,:)=sprintf('%e', normalizedcol(i));     % scientific format
                        end
                    end
                else
                    for i=1:tnrows
                        if ~(normalizedcol(i)==0)
                            normcharmatmasse(i,:)=sprintf('%.5f', normalizedcol(i));   % fixed format with 5 places after dec
                        end
                    end
                end
            end
            if valueveccount == 1
                if emptyfosetpos == 0
                    cumucharmat = charmatmasse;     % first column
                else
                    cumucharmat = cat(2, charmatmasse, sep_col, normcharmatmasse);
                end
            else
                if (emptyfosetpos == 0)
                    cumucharmat = cat(2, cumucharmat, sep_col, charmatmasse);
                else
                    cumucharmat = cat(2, cumucharmat, sep_col, charmatmasse, sep_col, normcharmatmasse);
                end
            end
        end    

        charmat=cat(2, charmatfoset, sep_col, cumucharmat);
        
        [nrows, ncols]=size(charmat);
        sep_line=repmat('-',[1, ncols]);        % separation line consists of dashes
        for i=1:lensep
            charmat(separation_indx(i),:)=sep_line;
        end
	
        fosetsizes = (separation_indx - acopy_sepa_indx)-1; % interval between two sep lines
        tautoset_indx = find(fosetsizes==framesize);
        
        if ~isempty(tautoset_indx)
            if tautoset_indx(1)-1 == 0      % special case when the tautology is the first focal set
                lowerrow = 1;
            else
                lowerrow = separation_indx(tautoset_indx(1)-1)+1;
            end
            upperrow = separation_indx(tautoset_indx(1))-1;
            rowtokeep = masspositions(tautoset_indx(1));
            rowstoremove = [lowerrow:rowtokeep-1 rowtokeep+1:upperrow];
            tautorow = charmat(rowtokeep,:);
            lefttomaspos = find(tautorow=='|');
            if ~isempty(lefttomaspos)
                tautostr = repmat('*', [1 lefttomaspos(1)-1]);
                tautorow(1:lefttomaspos(1)-1) = tautostr(:);
                charmat(rowtokeep,:) = tautorow(:);
            end
            charmat(rowstoremove,:)=[];
        end
	
        if strcmp(numberformat, 'fixed')
            tmp_col=charmat(:,ncols);               % last column 
            zero_indx=find(tmp_col=='0');
            tmp_col(zero_indx)=' ';
            charmat(:,ncols)=tmp_col;
        end
        
        dom_var_indx=extfind(thisdomain, [VARIABLE(:).number]);
        dom_var_indx=dom_var_indx(find(dom_var_indx));
	
        lendomvar=length(dom_var_indx);
        header=cell(1, lendomvar);
        
        for i=1:lendomvar
            frameid = VARIABLE(dom_var_indx(i)).frame;
            frameindx = extfind(frameid, [FRAME(:).number]);
            if (frameindx==0)
                error('A undefined frame is encountered')
            end
            [nrofelems, lenofelem]=size(FRAME(frameindx).elements);
			if strncmp(showform, 'code', 4)
                lenofelem =2;
            end
            tmpheader = repmat(' ', [1, lenofelem+1]);
            shortname = VARIABLE(dom_var_indx(i)).short_name;
            lenshortname = length(shortname);
            minlen = min(lenshortname, lenofelem);
            tmpheader(1:minlen)=shortname(1:minlen);
            header{i}=tmpheader;
        end
        charheader = cat(2, header{:});
        for valueveccount = 1:nrofmassvec
            if emptyfosetpos == 0
                if strcmp(numberformat, 'scientific')
                    charheader = cat(2, charheader, '| value        ');
                else
                    charheader = cat(2, charheader, '| value  ');
                end
            else
                if strcmp(numberformat, 'scientific')
                    charheader=cat(2, charheader, '| value        ', '| n-mass       ');
                else
                    charheader=cat(2, charheader, '| value  ', '| n-mass ');
                end
            end
        end
        belidnum = BELIEF(currbel_indx).number;
        beltype = BELIEF(currbel_indx).bp(1).form(formcounter).type;
        ss = beltype;
        
        if ~isempty(BELIEF(currbel_indx).conditioning_variable)
            condivarlist = BELIEF(currbel_indx).conditioning_variable.var_num;
            condiinstance = BELIEF(currbel_indx).conditioning_variable.instance;
            strinstance = 'conditional on ';
            for i = 1:length(condivarlist);
                thisvaridnum = condivarlist(i);
                thisvarindx = extfind(thisvaridnum, [VARIABLE(:).number]);
                theframeid = VARIABLE(thisvarindx).frame;
                thisframeindx = extfind(theframeid, [FRAME(:).number]);
                strinstance = cat(2, strinstance, deblank(FRAME(thisframeindx).elements(condiinstance(i),:)), ' ');
            end
            ss = cat(2, beltype, ' ', strinstance);
        end

        fprintf('Belief # %d in %s\n', belidnum, ss);
        strvcat(charheader, sep_line, charmat)
	end         % formcounter
end             % counter
%%%%%%%%%%%%% end of SHOWBEL