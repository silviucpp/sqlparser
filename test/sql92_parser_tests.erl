-module(sql92_parser_tests).

-include_lib("eunit/include/eunit.hrl").

-define(HANDLER, sql92_parser).

transaction_test() ->
    unit_test_parser:transaction_test(?HANDLER).

describe_test() ->
    unit_test_parser:transaction_test(?HANDLER).

delete_simple_test() ->
    unit_test_parser:describe_test(?HANDLER).

delete_where_test() ->
    unit_test_parser:delete_where_test(?HANDLER).

insert_simple_test() ->
    unit_test_parser:insert_simple_test(?HANDLER).

insert_keys_test() ->
    unit_test_parser:insert_keys_test(?HANDLER).

insert_set_test() ->
    unit_test_parser:insert_set_test(?HANDLER).

%%insert_on_duplicate_test() ->
%%    unit_test_parser:insert_on_duplicate_test(?HANDLER).

show_test() ->
    unit_test_parser:show_test(?HANDLER).

show_like_test() ->
    unit_test_parser:show_like_test(?HANDLER).

set_test() ->
    unit_test_parser:set_test(?HANDLER).

select_variable_test() ->
    unit_test_parser:select_variable_test(?HANDLER).

select_in_test() ->
    unit_test_parser:select_in_test(?HANDLER).

select_all_test() ->
    unit_test_parser:select_all_test(?HANDLER).

select_strings_test() ->
    unit_test_parser:select_strings_test(?HANDLER).

select_simple_test() ->
    unit_test_parser:select_simple_test(?HANDLER).

select_simple_multiparams_test() ->
    unit_test_parser:select_simple_multiparams_test(?HANDLER).

select_simple_subquery_test() ->
    unit_test_parser:select_simple_subquery_test(?HANDLER).

select_from_test() ->
    unit_test_parser:select_from_test(?HANDLER).

select_from_subquery_test() ->
    unit_test_parser:select_from_subquery_test(?HANDLER).

select_where_test() ->
    unit_test_parser:select_where_test(?HANDLER).

select_function_test() ->
    unit_test_parser:select_function_test(?HANDLER).

select_groupby_test() ->
    unit_test_parser:select_groupby_test(?HANDLER).

select_orderby_test() ->
    unit_test_parser:select_orderby_test(?HANDLER).

select_limit_test() ->
    unit_test_parser:select_limit_test(?HANDLER).

select_arithmetic_test() ->
    unit_test_parser:select_arithmetic_test(?HANDLER).

update_simple_test() ->
    unit_test_parser:update_simple_test(?HANDLER).

update_multiparams_test() ->
    unit_test_parser:update_multiparams_test(?HANDLER).

update_where_test() ->
    unit_test_parser:update_where_test(?HANDLER).
%%
%%create_table_test() ->
%%    unit_test_parser:create_table_test(?HANDLER).

truncate_table_test() ->
    unit_test_parser:truncate_table_test(?HANDLER).

drop_table_test() ->
    unit_test_parser:drop_table_test(?HANDLER).
