%%  coding: latin-1
%%------------------------------------------------------------
%%
%% Implementation stub file
%% 
%% Target: TimeBase_IntervalT
%% Source: /net/isildur/ldisk/daily_build/18_prebuild_master-opu_o.2015-06-23_20/otp_src_18/lib/cosTime/src/TimeBase.idl
%% IC vsn: 4.4
%% 
%% This file is automatically generated. DO NOT EDIT IT.
%%
%%------------------------------------------------------------

-module('TimeBase_IntervalT').
-ic_compiled("4_4").


-include("TimeBase.hrl").

-export([tc/0,id/0,name/0]).



%% returns type code
tc() -> {tk_struct,"IDL:omg.org/TimeBase/IntervalT:1.0","IntervalT",
                   [{"lower_bound",tk_ulonglong},
                    {"upper_bound",tk_ulonglong}]}.

%% returns id
id() -> "IDL:omg.org/TimeBase/IntervalT:1.0".

%% returns name
name() -> "TimeBase_IntervalT".



