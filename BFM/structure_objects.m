function [var, belief] = structure_var
% structure of the belief functions, May 1, 2002, 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Static components: object attribute value
% a matter of interest (mofi) is "the value of the attibute of the object in a certain context (time, spatial coordinates, etc.)"
% a variable is a matter of interest expressed on a given frame (its domain)
% a belief function is attached to a variable, or a list of variables (joint BF)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% THE GENERAL STRUCTURE
%
% belief potentials are defined on frame of discernement = a variable
%
% variable 	= (mofi, frame) 
%			= age of John in years
%
% frame 	= [0 1 2 ... 120]
%
% mofi  	= (attribute, individual) (mofi = matter of interest)
%			= age of John
%
% individual= John
%
% attribute = age : refers to a structure

% structure = several frames that are domains for same attribute. 
%     		  integers from 0 to 120 for age in year, 
%             integers from 0 to 120 for young people age in year
%             bianry as in Young Not_Young
%     	It contains the interelations: coarsening or inclusion 
% 		coarsening : mapping between frames
%		inclusion  : mapping between frames
%
% coarsening = detail on the coarsening 
%
% inclusion	 = detail on the inclusion
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FRAME
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% A frame is a set of values for a variable. It can be of three types:
% 		Binary
% 		Classes Un_ordered
% 		Classes Ordered
% 		Integers
% 		Intervals
% 		Continuous (it will wotk only for one dimensional closed intervals)
%
% The definition of a frame depends on its type
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A frame of type 'finite'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
frame(1).number = 5;
frame(1).name='Theta';
frame(1).short_name='Th';	
frame(1).type = 'Classes Ordered';
frame(1).cardinality = 3;
frame(1).elements = strvcat('young','middle-aged','old'); 
% call .element(1,:) and you get young, 
frame(1).ordered = 1;           % a finite frame can be ordered or not (if it is ordered, 
                                % the order in frame(1).elements is assumed
								
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Another frame of type 'finite'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
frame(2).number = 10;
frame(2).name='Theta_1';
frame(2).type = 'Classes Ordered';
frame(2).cardinality = 10;
frame(2).elements = strvcat('00-10';'11-20';'21-30';'31-40';'41-50';'51-60';'61-70';'71-80';'81-90';'91-100');
frame(2).ordered = 1;           

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A frame of type 'integer'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
frame(3).number = 6;
frame(3).name='Omega';
frame(3).type = 'Integer';
frame(3).min = 0;
frame(3).max = 100;   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Another frame of type 'integer', can be seen as a subset of the above
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
frame(4).number = 7;
frame(4).name='Omega_1';
frame(4).type = 'integer';
frame(4).mi = 0;
frame(4).max = 20;   

% note for intervals, they are by definition mutually exclusive 
% so 0-10 intersection 10-20 is empty, user must be careful about that



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% STRUCTURE
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Note:
% A structure is a collection of frames which can be used to express information
% regarding the value of an uncertain quantity, or "matter of interest".

% A mofi is defined on a structure (a collection of frames).
% If you pick a frame in the structure, you define a variable. 
% So variable =(mofi,frame). 
% Defining a structure is a way to designate a collection of frame 
% and express the fact that they can be used to sepecify the value of a mofi.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

structure(1).number = 5;
structure(1).name = 'age';
structure(1).list = [5 10 6 7];     % the list of frames in the structure
structure(1).coarsenings = [ 0 3 2 0;
                             0 0 1 0;
                             0 0 0 0;
                             0 0 0 0];
% the above matrix R summarizes the coarsening relations. 
% If frame indicated in row i is a coarsening of frame indicetaed in column j,
% then R(i,j) is the number
% of the corresponding coarsening object in the data base. Otherwise R(i,j)=0
structure(1).inclusion = [ 0 0 0 0;
                           0 0 0 0;
                           0 0 0 0;
                           0 0 1 0]; 
% the inclusion relation: T(i,j)=1 if frame row i is a srict subset of frame column j, 
% and T(i,j)=0 otherwise



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% COARSENING
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A coarsening (a description of the relation between two frames, one of which is a coarsening of the other)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

coarsening(1).number = 1;
coarsening(1).finer = 6;
coarsening(1).coarser = 10;
coarsening(1).thresholds = 0:10:100;
% In that case, the finer frame is of type interval. 
% Hence a coarsening can be defined by a list of thresholds.
% Here 0-10) 10_20... 90-100

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Another coarsening with 3 intervals
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
coarsening(2).number = 2;
coarsening(2).finer = 6;
coarsening(2).coarser = 5
coarsening(2).thresholds = [0 30 70 100];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A coarsening with two finite frames
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
coarsening(3).number = 3;
coarsening(3).finer = 10;
coarsening(3).coarser = 5;
coarsening(3).partition = [1 1 1 2 1 2 2 3 3 3] 
% Elements 1 2 3 5 of finer frame map into element 1 in coarser frame.
% Elements 4 6 7   of finer frame map into element 2 in coarser frame.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Another coarsening with two finite frames
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
coarsening(4).number = 2;
coarsening(4).finer = 6; % remenber 6 is an integer from 0 to 100
coarsening(4).coarser = 5
coarsening(4).mapping = [ 0*ones(20,1); 1*ones(30,1); 2*ones(51,1)];
% this is not a very smart way to build a vector with 20 0's, 30 1's and 51 2's, but it works



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ATTRIBUTE
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

attribute(1).number = 17;   					% the number of the attribute
attribute(1).full_name = 'age of a person';   	% full name of the attribute
attribute(1).short_name = 'age';				% short name of the attribute
attribute(1).structure = 5;                     % an attribute is defined on a structure (a collection of frames)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% INDIVIDUAL
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

individual(13).number = 115;   					% the number of the individual
individual(13).full_name = 'John Doe';			% full name of the individual
individual(13).short_name = 'JD';				% short name of the individual



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% MOFI
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A matter of interest (mofi) is the value of an attribute for an individual 
% in a given context, defined by one or several indices,
% such as time
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mofi(1).number = 53;
mofi(1).full_name = 'age of John Doe';
mofi(1).short_name = 'age_JD';
mofi(1).attribute = 17;
mofi(1).individual = 115   
mofi(1).index(1).name = time;
mofi(1).index(1).value = 'March_2002';



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% VARIABLE
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% A variable : a mofi + a frame
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

variable(189).number = 93;   							% the number of the variable
variable(189).full_name = 'John Doe age in decades';	% full name of the variable
variable(189).short_name = 'age_JD_dec';				% short name of the variable
variable(189).mofi = 53;
variable(189).frame = 10;			



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% BELIEF POTENTIAL
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% A belief is a set of belief potentials (one if marginal, K if conditional)
% with one or several forms for each potential
%
% a belief is an object which contains a belief potential under some form (m,b,...)
% it is linked to a variable
% it is hold by an agent, at a given time, 
% based on some evidential corpus
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

belief(1).number = 24; 			% each belief state has a number
belief(1).disposable = [];		% 1 = may be erased (clear) , 0 = [] = must be kept (default)

belief(1).agent = 'You'			% who is the belief holder
belief(1).time = 4;				% at what epoch
belief(1).ec = []				% ec = evidential corpus, on what bel is based, blabla	

belief(1).variable = 93 ;		% the domain can be a variable  ???? prodcutct space????

belief(1).conditioning_variable = 45; 	% the domain of the conditioning variable 
% if not empty, belief potential given for each singleton of the conditioning_variable
% if empty, belief is a marginal belief potential

% so we have as many belief potentials as there are singletons in the conditioning_variable 
% or 1 if marginal, the k index states which belief potential we are speaking about.

% .type state what exists 
% bf(k).form(1).type = 'm'; 
% capital = normalized
% m   / M   = bba
% b   / B   = implicability fct
% bel / Bel = belief function
% pl  / Pl	= plausibility function
% q   / Q   = commonality function
% wc  / Wc	= conjuncitve decomposition
% wd  / Wd  = disjunctive decomposition
% kappaq	= log_natural of q
% lower_appox
% upper_approx
% BetP
% we write belief(1).m, belief(1).b, belief(1).q etc... 

% the index of bp goes from 1 to k

% wa can have several forms, as we might have stored m and q for the same belief potential
belief(1).bp(1).form(1).type = 'm'; 
belief(1).bp(1).form(2).type = 'b'; 

belief(1).bp(2).form(1).type = 'pl'; 
belief(1).bp(2).form(2).type = 'BetP';  

belief(1).bp(3).form(1).type = 'BetP'; 
	% bp(1) because with conditional bp there are several, beware BedtP needs also a betting frame
	% by default the same as the one on which belief is defined
	% otherwise, build first the coarsening and then OK
    
belief(1).bp(1).form(1).representation = 'ordered'; 	 
			% states how the focal elements are listed. It can be
			% ordered = the whole power set ordered according to binary representation
			% selected = some of the focal elements only, listed in .focal_set

belief(1).bp(1).form(1).focal_sets = [];		
			% list of focal sets when not 'ordered', vertical
			% if more than 50 elements, focal_set is a line vectore with enough component 
			% to represent the elements
belief(1).bp(1).form(1).values = [.15; .05; .03; .02; .20; .12; .08; .37];
			% list of the values, vertical vector

% another example
belief(35).bp(1).form(1).type = 'm'; 
belief(35).bp(1).form(1).representation = 'selected'; 
belief(35).bp(1).form(1).focal_sets = [	12 234512 234; 
										34 44 543;
										2341 34 32;
										4654 454243 55454];
% 4 focal elements, frame with 140 elements (so we need 3 memories)
belief(35).bp(1).form(1).values = [.3 .2 .1 .4]';



belief(1).bp(1).form(2).representation = 'selected';  	% the b 	for cond bp given granule 1
belief(1).bp(2).form(1).representation = 'ordered'; 	% the pl 	for cond bp given granule 2
belief(1).bp(2).form(2).representation = 'ordered'; 	% the BetP 	for cond bp given granule 2
belief(1).bp(3).form(2).representation = 'selected'; 	% the BetP	for cond bp given granule 3



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% storing how the belief potentilal was computed
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

belief_origin(44).number = 35;
belief_origin(44).belief = 45; % it concerns belief(45)
belief_origin(44).input_beliefs = [12 13 21 34] % the bp I am using

		
% the un-informative modifications
belief_origin(44).computed = 'concat [12 13 21 34] '; % concatenation for set of conditional bp
% set of simple operation that can be perfomred on a bp
belief_origin(44).computed = 'downarrow = 45';  % = marginalize on the variable 45 domain
belief_origin(44).computed = 'uparrow = 32';	% = vacuous extension on the variable 32 domain
belief_origin(44).computed = 'balloon_ext 21';	% = ballooning extension on product space variable 21 (to be created)
% the monitoring control unit will read belief(1).input.to_be_computed
% and ask the adequate function ot evaluate (with eval)

% the informative revisions
% we tell which computation was perfomred on the input bp in order to get the bp #35
belief_origin(44).computed =  '(15 or 13) and 21 or not 34' % by default and or are for distinct pev
		% telling how to combine them when distinct (ready for cautious combi)
		% '12 and 17' means conj combi of bel 12 and bel 17 (handle domains if not =)
		% bel[bel[E1],bel[E2],E1 and E2] = = bel[E1] conjunction bel[E2]
		% '(15 or 13) and 21 or not 34' = disj(conj(disj(15,13), 21),neg 34)
belief_origin(44).computed =  '(15 minus_or 13) minus_and 21 or not 34'		
		% we also need  minus_and, minus_or, the inverse of conj, disj when distinct
belief_origin(44).computed =  '(15 cautious_or 13) cautious_and 21 or not 34'	
		% the case of cautious and and or
belief_origin(44).computed =  'DRC 12 34'	% disjunctgive rule of combination
		% the input is made of two components: the set of bel on X given T (the 12) and a bp on T (the 34) (a priori).
belief_origin(44).computed =  'GBT 12 34'	% general Bayesian Theorem
		% the input is made of two components: the set of bel on X given T (the 12) and a bp on X (the 34) (observation).

% etc....... open list		

belief_origin(44).computed = 'discounting .7'; 
		% the result of the computation or the only one received to discount
		% [discouning .7] = the resulting bba has been discounted by disc.factor = .7
		% bel_Y[bel_Z,disc^Y_Z = .7] == disc bel_Z by .7  (disc^Y_Z = Y disc Z by ...)
belief_origin(44).computed = 'conditioning  9';
		% conditioning on set with binary represented by 9 = 1001

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% belief_nodes = b_nodes 
% TO BE DONE BY PHAN
%
%	in hypertree: 	a b_node is a list of varibles (those involved to build bp)
%					and with one joint bp on the product space
%	in DAG:			a b_node is a list of variables
%					and one of them is end of the arrow (domain of cond bp)
%	decisions nodes ? for utilities 
%	??? if mixing cond bp and joint bp?
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

node.num = 67;				% the name of the node (a number)
node.type = 'dag' 			% 'dag' or 'hypertree' (or 'utilities' ?) 
node.var = [17 45 34 6]		% involved variables
