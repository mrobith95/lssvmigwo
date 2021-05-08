function [pfinal,efinal] = gwo(pn,herrfunc,varargin)

%
% Internal function based on 
% Mirjalili S, Mirjalili SM, Lewis A
% Grey Wolf Optimizer
% Advances of Engineering Software; 2014; Vol. 69; 46-61
% 
% Source Code for GWO obtained from
% https://au.mathworks.com/matlabcentral/fileexchange/44974-grey-wolf-optimizer-gwo


%switch length(varargin) %%set parameter
dim = size(pn,1);
SearchAgents_no = size(pn,2);
Max_iter = 100;
ub = 10;
lb = -10;
Positions=rand(dim,SearchAgents_no).*(ub-lb)+lb;
l=0;% Loop counter

% initialize alpha, beta, and delta_pos
Alpha_pos=zeros(dim,1);
Alpha_score=inf; %change this to -inf for maximization problems

Beta_pos=zeros(dim,1);
Beta_score=inf; %change this to -inf for maximization problems

Delta_pos=zeros(dim,1);
Delta_score=inf; %change this to -inf for maximization problems

rand('twister',sum(pn(1)*clock))
randn('state',sum(pn(2)*clock))

%%e0 = feval(herrfunc,pn,varargin{:});
%if any(e0<0), etol = -etol*etol^-2;end

% Main loop
while l<Max_iter
    for i=1:SearchAgents_no  
        
       % Return back the search agents that go beyond the boundaries of the search space
        Flag4ub=Positions(:,i)>ub;
        Flag4lb=Positions(:,i)<lb;
        Positions(:,i)=(Positions(:,i).*(~(Flag4ub+Flag4lb)))+ub.*Flag4ub+lb.*Flag4lb;               
        
        % Calculate objective function for each search agent
        fitness=feval(herrfunc,Positions(:,i),varargin{:});
        % Update Alpha, Beta, and Delta
        
        if fitness<Alpha_score 
            Alpha_score=fitness; % Update alpha
            Alpha_pos=Positions(:,i);
        end
        
        if fitness>Alpha_score && fitness<Beta_score 
            Beta_score=fitness; % Update beta
            Beta_pos=Positions(:,i);
        end
        
        if fitness>Alpha_score && fitness>Beta_score && fitness<Delta_score 
            Delta_score=fitness; % Update delta
            Delta_pos=Positions(:,i);
        end
    end
    
    
    a=2-l*((2)/Max_iter); % a decreases linearly fron 2 to 0
    
    % Update the Position of search agents including omegas
    for i=1:SearchAgents_no 
        for j=1:dim    
                       
            r1=rand(); % r1 is a random number in [0,1]
            r2=rand(); % r2 is a random number in [0,1]
            
            A1=2*a*r1-a; % Equation (3.3)
            C1=2*r2; % Equation (3.4)
            
            D_alpha=abs(C1*Alpha_pos(j)-Positions(j,i)); % Equation (3.5)-part 1
            X1=Alpha_pos(j)-A1*D_alpha; % Equation (3.6)-part 1
                       
            r1=rand();
            r2=rand();
            
            A2=2*a*r1-a; % Equation (3.3)
            C2=2*r2; % Equation (3.4)
            
            D_beta=abs(C2*Beta_pos(j)-Positions(j,i)); % Equation (3.5)-part 2
            X2=Beta_pos(j)-A2*D_beta; % Equation (3.6)-part 2       
            
            r1=rand();
            r2=rand(); 
            
            A3=2*a*r1-a; % Equation (3.3)
            C3=2*r2; % Equation (3.4)
            
            D_delta=abs(C3*Delta_pos(j)-Positions(j,i)); % Equation (3.5)-part 3
            X3=Delta_pos(j)-A3*D_delta; % Equation (3.5)-part 3             
            
            Positions(j,i)=(X1+X2+X3)/3;% Equation (3.7)
            
        end
    end
    l=l+1;
end
pfinal = Alpha_pos;
efinal = Alpha_score;