classdef Sinput < handle
  % Input structure for Random Sequence class

  properties
    Drift         % δ-drift factor for random walk: x(t) = x(t-1) + δ + w(t)
    Initval       % initial value of sequence
    Length        % length of random sample
    Height        % number of random samples
    PrbSuccess    % probability of success in Bernoulli trials
    Beta          % time constant of Markov process
    Timestep      % time interval between samples in Markov process
    Type          % type of random sequence {'Constant','Bernoulli','GaussMarkov','RandomWalk','White','Wiener'}
    Var           % variance of sequence
  endproperties

  methods % Public

    function [obj] = Sinput()
      obj.Drift = 0;
      obj.Initval = 0;
      obj.Length = 30;
      obj.Height = 100;
      obj.PrbSuccess = 0.5;
      obj.Beta = 1;
      obj.Timestep = 0.1;
      obj.Type = 'WhiteNoise';
      obj.Var = 1;
    endfunction

    function [r] = get.Drift(this)
      r = this.Drift;
    endfunction

    function [] = set.Drift(this,x)
      this.Drift = x;
    endfunction

    function [r] = get.Initval(this)
      r = this.Initval;
    endfunction

    function [] = set.Initval(this,x)
      this.Initval = x;
    endfunction

    function [] = set.Height(this,n)
      this.Height = n;
    endfunction

    function [] = set.Length(this,n)
      this.Length = n;
    endfunction

    function [] = set.PrbSuccess(this,p)
      this.PrbSuccess = p;
    endfunction

    function [] = set.Beta(this,b)
      this.Beta = b;
    endfunction

    function [] = set.Var(this,s2)
      this.Var = s2;
    endfunction

    function [] = set.Timestep(this,dt)
      this.Timestep = dt;
    endfunction

    function [] = set.Type(this,type)
      if ismember(type,{'Constant','Bernoulli','GaussMarkov','RandomWalk','WhiteNoise','Wiener'})
        this.Type = type;
      end
    endfunction

  endmethods
endclassdef
