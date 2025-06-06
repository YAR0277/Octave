classdef Sinput < handle
  % Input structure for Random Sequence class

  properties
    length        % length of random sample
    height        % number of random samples
    prbSuccess    % probability of success in Bernoulli trials
    beta          % time constant of Markov process
    timestep      % time interval between samples in Markov process
    type          % type of random sequence {'Constant','Bernoulli','GaussMarkov','RandomWalk','White','Wiener'}
    var           % variance of sequence
  endproperties

  methods % Public

    function [obj] = Sinput()
      obj.length = 30;
      obj.height = 100;
      obj.prbSuccess = 0.5;
      obj.beta = 1;
      obj.timestep = 0.1;
      obj.type = 'White';
      obj.var = 1;
    endfunction

    function [] = SetHeight(this,n)
      this.height = n;
    endfunction

    function [] = SetLength(this,n)
      this.length = n;
    endfunction

    function [] = SetPrbSuccess(this,p)
      this.prbSuccess = p;
    endfunction

    function [] = SetBeta(this,b)
      this.beta = b;
    endfunction

    function [] = SetVar(this,s2)
      this.var = s2;
    endfunction

    function [] = SetTimestep(this,dt)
      this.timestep = dt;
    endfunction

    function [] = SetType(this,type)
      if ismember(type,{'Constant','Bernoulli','GaussMarkov','RandomWalk','White','Wiener'})
        this.type = type;
      end
    endfunction

  endmethods
endclassdef
