(*Written by Gregory Klevans, December 11, 2020*)

bidf[c_, e_] := Max[55, c]; (*Initialize bid function to that of asymptotic standard case, also similar to asymptotic solution for nrp auction*)
hc = 5;  (*length of grid square*) 
he = 5; (*width of grid square*)
minupdate = .01; (*minimum payoff increase required to update bid*)
maxiter = 10;(*number of iterations*)
nsim = 1000; (*number of samples in simulation*)
(*Turn off needless messages*)
Off[Interpolation::inhr];
Off[InterpolatingFunction::dmval];
(*Compute bid function at center of each grid square*)
barray = Table[{c+hc/2, e+he/2, 1.bidf[c+hc/2, e+he/2]}, {c, 10, 100-hc, hc}, {e, -5, 5-he, he}] // Flatten[#,1] &;
bidinterp = Interpolation[barray]; (*Interpolate (and extrapolate) bid function over region*)
Plot3D[{c, bidinterp[c,e]+.1}, {c,10,100}, {e,-5,5}, AxesLabel-> {"Cost","Noise","Bid"}, Exclusions-> None,
  PlotRange-> {{10,100}, {-45,45}}, Ticks-> {{10,55,100},{-5,0,5},{10,55,100}}]
(*Draw nsim samples of 15 bidders.*)
SeedRandom[50682479]
Do[
  bigsim = {};
(*Each bidder represented by cost, error, and bid*)
  Do[
    sample = Table[{RandomReal[{10,100}], RandomReal[{-5,5}]}, {i,1,15}];
    sim = Table[{sample[[i,1]], sample[[i,2]], bidinterp[sample[[i,1]], sample[[i,2]] ]}, {i,1,15}];
  AppendTo[bigsim, sim], {i,nsim}];
  (*newbarray will be filled with updated bids*)
SetSharedVariable[newbarray];
newbarray = {};
(*Parallelize to speed computation*)
ParallelDo[
  Off[Interpolation::inhr];
  f[b0_] := Module[{b=b0}, payoff=0;(*f[b] is estimated expected payoff from bid b*)
  Do[
    sample = Append[bigsim[[s]], {c+hc/2, e+he/2, b}]; (*Add bidder to sample of opposing bidders*)
    sample = Transpose[Insert[Transpose[sample], sample[[All,1]]+sample[[All,2]], -1]]; (*Add cost estimate for each bidder*)
    scores = ConstantArray[0,16]; (*initialize scores*)
    (*Computes reference price for each bidder by adding bids of four opponents with lowest difference in estimated cost relative to bidder*)
    Do[
      costestdiff = (Abs[#-sample[[n,1]]-sample[[n,2]] ]) & /@ sample[[All,-1]];
    sortsample = SortBy[Transpose[Insert[Transpose[sample], costestdiff, -1]], Last];
    (*If[RandomReal[]<.01,Print[sortsample]];*)(*Double-checked that done correctly*)
    refprice = Sum[sortsample[[i,3]], {i,2,5}]/4;
    scores[[n]] = sample[[n,3]]/refprice+refprice/50 (*compute score for each bidder*),{n,1,16}
  ];
  payoff = payoff+(b-c-hc/2)Boole[scores[[16]] <= Sort[scores][[8]] ] (*compute bidder's payoff*), {s,1,nsim}
];
payoff = payoff/nsim (*convert payoff sum to average*)];
currentbid = bidinterp[c+hc/2, e+he/2];
newbid = b/.Last[NMaximize[f[b], {b, c+hc/2, 110}, MaxIterations->10000]];
newbid = If[f[newbid]-f[currentbid] < minupdate, currentbid, newbid];
AppendTo[newbarray, {c+1.hc/2, e+1.he/2, newbid}], {c,10,100-hc,hc}, {e,-5,5-he,he}];
(*Print and plot new bid function*)
Print[SortBy[newbarray,First]];
bidinterp = Interpolation[newbarray];
Print[Plot3D[{c,bidinterp[c,e]+.1}, {c,10,100}, {e,-5,5}, AxesLabel->{"Cost","Noise","Bid"}, Exclusions->None,
  PlotRange -> {{0, 100}, {-5, 5}, {0, 110}}, Ticks -> {{10, 55, 100}, {-5, 0, 5}, {10, 55, 100}}, 
  BoxRatios -> {10, 1, 10}, PlotStyle -> Opacity[0.75], ViewPoint -> {-3, -2, 1}]],
{iter,maxiter}]

