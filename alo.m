function [pfinal,efinal] = alo(pn,herrfunc,varargin)

%
% Internal function based on 
% Mirjalili S
% The Ant Lion Optimizer
% Advances of Engineering Software; 2015; Vol. 83; 80-98

% Source Code for ALO obtained from
% https://www.mathworks.com/matlabcentral/fileexchange/49920-ant-lion-optimizer-alo?s_tid=srchtitle

%switch length(varargin) %%set parameter
dim = size(pn,1);
N = size(pn,2);
Max_iter = 100;
ub = 10;
lb = -10;

% rand('twister',sum(pn(1)*clock))
% randn('state',sum(pn(2)*clock))

% initiate antlion and ant position
antlion_position=rand(dim,N).*(ub-lb)+lb;
ant_position=rand(dim,N).*(ub-lb)+lb;
l=0;% Loop counter

% Initialize variables to save the position of elite, sorted antlions, 
% convergence curve, antlions fitness, and ants fitness
Sorted_antlions=zeros(dim,N);
Elite_antlion_position=zeros(dim,1);
Elite_antlion_fitness=inf;
antlions_fitness=zeros(N,1);
ants_fitness=zeros(N,1);

% Calculate the fitness of initial antlions and sort them
for i=1:size(antlion_position,2)
    antlions_fitness(i,1)=feval(herrfunc,antlion_position(:,i),varargin{:});
end

[sorted_antlion_fitness,sorted_indexes]=sort(antlions_fitness);

for newindex=1:N
     Sorted_antlions(:,newindex)=antlion_position(:,sorted_indexes(newindex));
end
    
Elite_antlion_position=Sorted_antlions(:,1);
Elite_antlion_fitness=sorted_antlion_fitness(1);

% Main loop start from the second iteration since the first iteration 
% was dedicated to calculating the fitness of antlions
Current_iter=2; 
while Current_iter<Max_iter+1
    
    % This for loop simulate random walks
    for i=1:size(ant_position,2)
        % Select ant lions based on their fitness (the better anlion the higher chance of catching ant)
        Rolette_index=RouletteWheelSelection(1./sorted_antlion_fitness);
        if Rolette_index==-1  
            Rolette_index=1;
        end
      
        % RA is the random walk around the selected antlion by rolette wheel
        RA=Random_walk_around_antlion(dim,Max_iter,lb,ub, Sorted_antlions(:,Rolette_index),Current_iter);
        
        % RA is the random walk around the elite (best antlion so far)
        [RE]=Random_walk_around_antlion(dim,Max_iter,lb,ub, Elite_antlion_position(:,1),Current_iter);
        
        ant_position(:,i)= (RA(Current_iter,:)'+RE(Current_iter,:)')/2; % Equation (2.13) in the paper          
    end
    
    for i=1:size(ant_position,2)  
        
        % Boundar checking (bring back the antlions of ants inside search
        % space if they go beyoud the boundaries
        Flag4ub=ant_position(:,i)>ub;
        Flag4lb=ant_position(:,i)<lb;
        ant_position(:,i)=(ant_position(:,i).*(~(Flag4ub+Flag4lb)))+ub.*Flag4ub+lb.*Flag4lb;  
        
        ants_fitness(:,i)=feval(herrfunc,antlion_position(:,i),varargin{:});       
       
    end
    
    % Update antlion positions and fitnesses based of the ants (if an ant 
    % becomes fitter than an antlion we assume it was cought by the antlion  
    % and the antlion update goes to its position to build the trap)
    double_population=[Sorted_antlions,ant_position];
    double_fitness=[sorted_antlion_fitness,ants_fitness];
        
    [double_fitness_sorted I]=sort(double_fitness);
    double_sorted_population=double_population(:,I);
        
    antlions_fitness=double_fitness_sorted(1:N);
    Sorted_antlions=double_sorted_population(:,1:N);
        
    % Update the position of elite if any antlinons becomes fitter than it
    if antlions_fitness(1)<Elite_antlion_fitness 
        Elite_antlion_position=Sorted_antlions(:,1);
        Elite_antlion_fitness=antlions_fitness(1);
    end
      
    % Keep the elite in the population
    Sorted_antlions(:,1)=Elite_antlion_position;
    antlions_fitness(1)=Elite_antlion_fitness;
    
%     % Display the iteration and best optimum obtained so far
%     if mod(Current_iter,5)==0
%         display(['At iteration ', num2str(Current_iter), ' the elite fitness is ', num2str(Elite_antlion_fitness)]);
%     end

    Current_iter=Current_iter+1; 
end
pfinal = Elite_antlion_position;
efinal = Elite_antlion_fitness;