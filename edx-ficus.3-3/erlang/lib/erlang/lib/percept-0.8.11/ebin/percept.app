%%
%% %CopyrightBegin%
%% 
%% Copyright Ericsson AB 2007-2012. All Rights Reserved.
%% 
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.
%% 
%% %CopyrightEnd%
%%

{application,percept, [
    {description, "PERCEPT Erlang Concurrency Profiling Tool"},
    {vsn, "0.8.11"},
    {modules, [
	egd,
	egd_font,
	egd_png,
	egd_primitives,
	egd_render,
	percept,
	percept_analyzer,
	percept_db,
	percept_graph,
	percept_html,
	percept_image
    ]},
    {registered, [percept_db,percept_port]},
    {applications, [kernel,stdlib]},
    {env,[]},
    {runtime_dependencies, ["stdlib-2.0","runtime_tools-1.8.14","kernel-3.0",
			    "inets-5.10","erts-6.0"]}
]}.


%% vim: syntax=erlang
