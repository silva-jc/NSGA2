%Validating real coded NSGA2...
clear
clc
%addpath([pwd '\BIN\']); copy: crowdingDistances and P0nondominatedsorting 
addpath([pwd '\REAL\']);
fprintf('\n=== Starting Constrained NSGA2 test ===\n')

%define your optimisation problem
nVars = 2;
problem = Problem([-1 -1], nVars);
%set real coded NSGA-II parameters
nGenerations = 1;
nIndividuals = 40;
pX = 0.9; %crossover probability
Nc = 20; %distribution index for Xoperator
pM = 1/(nVars); %mutation probability
Nm = 20; %distribution index for Xoperator
probs = [pX pM];
Didxs = [Nc Nm];
%get NSGA-II object
mobjga = Nsga2RealCoded(nIndividuals, probs, Didxs, problem);
%start loop
tic = cputime;
for gen = 1:nGenerations 
    fprintf('\ngeneration %d', gen);
    %non-dominated sorting
    [mobjga.F ,mobjga.Rt] = mobjga.nonDominatedSorting(); 
    %initialize P(t+1) and set the total number of fronts needed to create P(t+1)
    [newPopIdxs, lastFrontIdx] = mobjga.setNewPopulation();
    %get full P(t+1) 
    [mobjga.mpCandidates, mobjga.Pt, ~] = mobjga.getCrowdingDistances(lastFrontIdx, newPopIdxs); 
    %get mating pool
    mobjga.Mpool = mobjga.crowdedTSO(lastFrontIdx); 
    %get Q(t+1)
    mobjga.Qt = mobjga.getOffspring(); 
end
%get generation i solution
mobjga.finalFront = mobjga.getFinalFront();
toc = cputime - tic;
fprintf('\n-> elapsed CPU time: %.2fs', toc);
%plot final front
%plot(mobjga.finalFront(:,1), mobjga.finalFront(:,2), '*')
%get optimal pareto front
paretoFront = getOptimalFront(mobjga); 
%get optimal constrained pareto front
paretoConstrained = getOptimalConstrFront(mobjga);
%plot(paretoFront(:,1), paretoFront(:,2))
f1 = mobjga.finalFront(:,1);
f2 = mobjga.finalFront(:,2);
f1opt = paretoFront(:,1);
f2opt = paretoFront(:,2);
f1optc = paretoConstrained(:,1);
f2optc = paretoConstrained(:,2); 
plot(f1opt, f2opt,'b--');
hold on

plot(f1optc, f2optc ,'b');
plot(f1, f2, 'k*');
title('NSGA-II Test');
stringLegend = nGenerations + " generations," + " popsize = " + ...
    nIndividuals + ", pX = " + pX + ", pM = " + pM;
legend('pareto front', 'pareto constrained front',stringLegend);
xlabel('F1')
ylabel('F2')
hold off
fprintf('\nDone!\n');