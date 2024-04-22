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
ROP = 150;

% Batch size.
Q = 757;

% How many samples of the simulation to run.
NumSamples = 10;

% Run each sample for this many days.
MaxTime = 100;

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

% Make a figure with one set of axes.
fig = figure();
t = tiledlayout(fig,1,1);
ax = nexttile(t);

% Histogram of the cost per day.
h1 = histogram(ax, TotalCosts/MaxTime, Normalization="probability", ...
    BinWidth=5);

% Add title and axis labels
title(ax, "Daily total cost");
xlabel(ax, "Dollars");
ylabel(ax, "Probability");

% Fix the axis ranges
ylim(ax, [0, 0.5]);
xlim(ax, [240, 290]);

h3 = histogram(fracofdays);
title("Fraction of days with a non-zero backlog");
xlabel("Fraction");
ylabel("Probability");
fprintf("Mean fraction of days with a non-zero backlog: %f\n", mean(fracofdays));

h5 = histogram(vertcat(amount{:}));
title("The backlog amount for days that experience a backlog");
xlabel("Amount");
ylabel("Probability");
fprintf("Mean backlog amount for days that experience a backlog: %f\n", mean(vertcat(amount{:})));