%pkg load statistics
clear all;
s=Sinput;

s.Type = 'Bernoulli';
r=RndSeq(s);
r.GenerateSample;
r.PlotSample;

s.Type = 'GaussMarkov';
r=RndSeq(s);
r.GenerateSample;
r.PlotSample;

s.Type = 'RandomWalk';
r=RndSeq(s);
r.GenerateSample;
r.PlotSample;

s.Type = 'WhiteNoise';
r=RndSeq(s);
r.GenerateSample;
r.PlotSample;

s.Type = 'Wiener';
r=RndSeq(s);
r.GenerateSample;
r.PlotSample;

