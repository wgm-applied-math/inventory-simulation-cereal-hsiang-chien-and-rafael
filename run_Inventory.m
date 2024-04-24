%% Run samples of the Inventory simulation
%
% Collect statistics and plot histograms along the way.

%% Set up

% Set-up and administrative cost for each batch requested.
K = 25.00;

% Per-unit production cost.
c = 3.00;

% Lead time for production requests.
L = 2;

% Holding cost per unit per day.
h = 0.05/7;

% Reorder point.
ROP = 141.5220;

% Batch size.
Q = 757.6279;

% How many samples of the simulation to run.
NumSamples = 100;

% Run each sample for this many days.
MaxTime = 1000;

%% Run simulation samples

% Make this reproducible
rng("default");

% Samples are stored in this cell array of Inventory objects
InventorySamples = cell([NumSamples, 1]);

% Run samples of the simulation.
% Log entries are recorded at the end of every day
for SampleNum = 1:NumSamples
    fprintf("Working on %d\n", SampleNum);
    inventory = Inventory( ...
        RequestCostPerBatch=K, ...
        RequestCostPerUnit=c, ...
        RequestLeadTime=L, ...
        HoldingCostPerUnitPerDay=h, ...
        ReorderPoint=ROP, ...
        OnHand=Q, ...
        RequestBatchSize=Q);
    run_until(inventory, MaxTime);
    InventorySamples{SampleNum} = inventory;
    fracoforder(SampleNum) = sum([inventory.FracofOrders{:}])/length(inventory.FracofOrders);
    fracofdays(SampleNum) = length(inventory.Log.Backlog(inventory.Log.Backlog~=0))/MaxTime;
    delaytime{SampleNum} = inventory.DelayTime;
    amount{SampleNum} = inventory.Log.Backlog(inventory.Log.Backlog~=0);
end

%% Collect statistics

% Pull the RunningCost from each complete sample.
TotalCosts = cellfun(@(i) i.RunningCost, InventorySamples);

% Express it as cost per day and compute the mean, so that we get a number
% that doesn't depend directly on how many time steps the samples run for.
meanDailyCost = mean(TotalCosts/MaxTime);
fprintf("Mean daily cost: %f\n", meanDailyCost);

%% Make pictures

% Histogram of the cost per day.
h1 = histogram(TotalCosts/MaxTime, Normalization="probability",BinWidth=5);
title("Daily total cost");
xlabel("Dollars");
ylabel("Probability");
fprintf("Mean daily cost: %f\n", meanDailyCost);


h2 = histogram(fracoforder, Normalization="probability", BinWidth=0.005);
title("Fraction of orders that get backlogged");
xlabel("Fraction");
ylabel("Probability");
fprintf("Mean fraction of orders that get backlogged: %f\n", mean(fracoforder));

h3 = histogram(fracofdays, Normalization="probability", BinWidth=0.005);
title("Fraction of days with a non-zero backlog");
xlabel("Fraction");
ylabel("Probability");
fprintf("Mean fraction of days with a non-zero backlog: %f\n", mean(fracofdays));



dtime = horzcat(delaytime{:});
dtime = cell2mat(dtime);
dtime = dtime(dtime~=0);
h4 = histogram(dtime, Normalization="probability");
title("Fraction of days with a non-zero backlog");
xlabel("Time");
ylabel("Probability");
fprintf("Mean delay time of orders that get backlogged: %f\n", mean(dtime));

h5 = histogram(vertcat(amount{:}), Normalization="probability", BinWidth=5);
title("The backlog amount for days that experience a backlog");
xlabel("Amount");
ylabel("Probability");
fprintf("Mean backlog amount for days that experience a backlog: %f\n", mean(vertcat(amount{:})));