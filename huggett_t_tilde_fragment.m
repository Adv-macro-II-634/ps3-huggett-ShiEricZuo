% PROGRAM NAME: ps3huggett.m
clear, clc

% PARAMETERS
beta = .9932; % discount factor 
sigma = 1.5; % coefficient of risk aversion
b = 0.5; % replacement ratio (unemployment benefits)
y_s = [1, b]; % endowment in employment states
PI=[.97 .03; .5 .5]; % transition matrix
PIlr = PI^499;

% ASSET VECTOR
a_lo = -2; %lower bound of grid points
a_hi = 5;%upper bound of grid points
num_a = 10;

a = linspace(a_lo, a_hi, num_a); % asset (row) vector
n=1
% INITIAL GUESS FOR q
q_min = 0.98;
q_max = 1;
q_guess = (q_min + q_max) / 2;

% ITERATE OVER ASSET PRICES
aggsav = 1 ;
while abs(aggsav) >= 0.01 
    
    % CURRENT RETURN (UTILITY) FUNCTION
    cons = bsxfun(@minus, a', q_guess * a);
    cons = bsxfun(@plus, cons, permute(y_s, [1 3 2]));
    ret = (cons .^ (1-sigma)) ./ (1 - sigma); % current period utility
    ret(cons<0) = -inf;
    % INITIAL VALUE FUNCTION GUESS
    v_guess = zeros(2, num_a);
    i=1
    % VALUE FUNCTION ITERATION
    v_tol = 1;
    while v_tol >.0001
        % CONSTRUCT RETURN + EXPECTED CONTINUATION VALUE
        value_func=ret+beta*repmat(permute((PIlr*v_guess),[3 2 1]),[num_a 1 1]);
        % CHOOSE HIGHEST VALUE (ASSOCIATED WITH a' CHOICE)
        [vfn,policy_index]=max(value_func,[],2);
        
        
        
        vfn=permute(vfn,[3 1 2]);
        
        dis_abs=abs(vfn(:) - v_guess(:));
        dis = max(dis_abs);
        
        v_guess = vfn;
        i=i+1;
    end
     % KEEP DECSISION RULE
     policy_index=permute(policy_index, [3 1 2]);
     g=a(policy_index);
    % SET UP INITITAL DISTRIBUTION
    Mu=rand(length(y_s), num_a);
    mudis=1;
    % ITERATE OVER DISTRIBUTIONS
while mudis>1e-8
    [emp_ind, a_ind, mass] = find(Mu > 0); % find non-zero indices
    
    MuNew = zeros(size(Mu));
    for ii = 1:length(emp_ind)
        apr_ind = pol_index(emp_ind(ii), a_ind(ii)); % which a prime does the policy fn prescribe?
        MuNew(:, apr_ind) = MuNew(:, apr_ind) + ... % which mass of households goes to which exogenous state?
            (PI(emp_ind(ii), :) * mass)';
    end
 mudis= max(abs(MuNew(:)-Mu(:)));
        Mu= MuNew;
        
end


M_C=sum(sum(g.*Mu));
if M_C>0.001
    q_min=(q_min+q_max)/2;
else
     q_max=(q_min+q_max)/2;
end
q_guess=(q_min+q_max)/2;
q=q+guess;
aggsav=M_C;
n=n+1;

end

Eincome=a+1;
Uincome=a+0.5;
income=[Eincome Uincome].*Mu(:)';

sort=sort(income);
percentile=income/sum(income(:));

population=Mu(:)';
population=population(sort);


for i = 2:length(income)
     percentile(i) = percentile(i)+percentile(i-1);
     population(i) = population(i)+population(i-1);
end

plot(population, percentile);
title('lorenz curve')