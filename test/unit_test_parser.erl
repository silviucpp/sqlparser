-module(unit_test_parser).

-include_lib("eunit/include/eunit.hrl").
-include("sql.hrl").

-export([
    transaction_test/1,
    describe_test/1,
    delete_simple_test/1,
    delete_where_test/1,
    insert_simple_test/1,
    insert_keys_test/1,
    insert_set_test/1,
    insert_on_duplicate_test/1,
    show_test/1,
    show_like_test/1,
    set_test/1,
    select_variable_test/1,
    select_in_test/1,
    select_all_test/1,
    select_strings_test/1,
    select_simple_test/1,
    select_simple_multiparams_test/1,
    select_simple_subquery_test/1,
    select_from_test/1,
    select_from_subquery_test/1,
    select_where_test/1,
    select_function_test/1,
    select_groupby_test/1,
    select_orderby_test/1,
    select_limit_test/1,
    select_arithmetic_test/1,
    update_simple_test/1,
    update_multiparams_test/1,
    update_where_test/1,
    create_table_test/1,
    drop_table_test/1
]).

transaction_test(Handler) ->
    ?assertEqual('begin', Handler:parse("begin")),
    ?assertEqual('commit', Handler:parse("commit")),
    ?assertEqual('rollback', Handler:parse("rollback")).

describe_test(Handler) ->
    ?assertEqual(#describe{table = #table{name = <<"streams">>, alias = <<"streams">>}}, Handler:parse("DESCRIBE `streams`")).

delete_simple_test(Handler) ->
    ?assertEqual(#delete{table=#table{name = <<"mitabla">>, alias = <<"mitabla">>}}, Handler:parse("delete from mitabla")).

delete_where_test(Handler) ->
    ?assertEqual(#delete{
        table = #table{name = <<"songs">>, alias = <<"songs">>},
        conditions = #condition{
            nexo = eq,
            op1 = #key{name = <<"name">>, alias = <<"name">>},
            op2 = #value{value = <<"this ain't a love song">>}
        }
    }, Handler:parse("delete from songs where name = 'this ain''t a love song'")).

insert_simple_test(Handler) ->
    ?assertEqual(#insert{table = #table{name = <<"mitabla">>, alias = <<"mitabla">>},
            values = [#value{value = 1},
                      #value{value = 2},
                      #value{value = 3}]
    }, Handler:parse("insert into mitabla values (1,2,3)")).

insert_keys_test(Handler) ->
    ?assertEqual(#insert{
        table = #table{name = <<"mitabla">>, alias = <<"mitabla">>},
        values = [
            #set{key = <<"id">>, value = #value{value = 1}},
            #set{key = <<"author">>, value = #value{value = <<"bonjovi">>}},
            #set{key = <<"song">>, value = #value{value = <<"these days">>}}
        ]
    }, Handler:parse("insert into mitabla(id,author,song) values(1,'bonjovi', 'these days')")).

insert_set_test(Handler) ->
    ?assertEqual(#insert{
        table = #table{name = <<"mitabla">>, alias = <<"mitabla">>},
        values = [
            #set{key = <<"id">>, value = #value{value = 1}},
            #set{key = <<"author">>, value = #value{value = <<"bonjovi">>}},
            #set{key = <<"song">>, value = #value{value = <<"these days">>}}
        ]
    }, Handler:parse("insert into mitabla set id=1, author='bonjovi', song='these days'")).

insert_on_duplicate_test(Handler) ->
    ?assertEqual(ok, Handler:parse("INSERT INTO table1 (col1, col2, col3, col4) VALUES (1, 'val2', 0, FROM_UNIXTIME(123456)) ON DUPLICATE KEY UPDATE col3 = 0, last_update = FROM_UNIXTIME(123456)")).

show_test(Handler) ->
%%    expected: {show,databases,undefined,undefined,undefined}
%%    got: {show,databases,false,undefined,undefined}

    ?assertEqual(#show{type = databases}, Handler:parse("SHOW databases")),
    ?assertEqual(#show{type = variables}, Handler:parse("SHOW variables")),
    ?assertEqual(#show{type = tables, full = true}, Handler:parse("SHOW FULL tables")),
    ?assertEqual(#show{type = tables, full = false}, Handler:parse("SHOW tables")),
    ?assertEqual(#show{type = fields, full = true, from = <<"streams">>}, Handler:parse("SHOW FULL FIELDS FROM `streams`")),
    ?assertEqual(#show{type = fields, full = false, from = <<"streams">>}, Handler:parse("SHOW FIELDS FROM `streams`")),
    ?assertEqual(#show{type = tables, full = false, conditions = {like, <<"streams">>}}, Handler:parse("SHOW TABLES LIKE 'streams'")),
    ?assertEqual(#show{type = create_table, from = <<"streams">>}, Handler:parse("SHOW CREATE TABLE `streams`")),
    ?assertEqual(#show{type = variables, conditions = #condition{
        nexo = eq, op1 = #key{alias = <<"Variable_name">>, name = <<"Variable_name">>}, op2 = #value{value = <<"character_set_client">>}}
    }, Handler:parse("SHOW VARIABLES WHERE Variable_name = 'character_set_client'")),
    ?assertEqual(#show{type = collation, conditions = #condition{
        nexo = eq, op1 = #key{alias = <<"Charset">>, name= <<"Charset">>}, op2 = #value{value = <<"utf8">>}}}, Handler:parse("show collation where Charset = 'utf8'")).

show_like_test(Handler) ->
    ?assertEqual(#show{type=variables, conditions = {like, <<"sql_mode">>}}, Handler:parse("SHOW VARIABLES LIKE 'sql_mode'")).

set_test(Handler) ->
    ?assertEqual(#system_set{query = [{#variable{name = <<"a">>, scope = session}, #value{value = 0}}]}, Handler:parse("SET a=0")),
    ?assertEqual(#system_set{query = [{#variable{name = <<"NAMES">>, scope = session}, #value{value = <<"utf8">>}}]}, Handler:parse("SET NAMES 'utf8'")),
    ?assertEqual(#system_set{query = [{#variable{name = <<"NAMES">>, scope = session}, #value{value = <<"utf8">>}}]}, Handler:parse("SET NAMES utf8")),

    ?assertEqual(#system_set{query=[
        {#variable{name = <<"SQL_AUTO_IS_NULL">>, scope = session}, #value{value = 0}},
        {#variable{name = <<"NAMES">>, scope = session}, #value{value = <<"utf8">>}},
        {#variable{name = <<"wait_timeout">>, scope = local}, #value{value = 2147483}}
    ]}, Handler:parse("SET SQL_AUTO_IS_NULL=0, NAMES 'utf8', @@wait_timeout = 2147483")).

select_variable_test(Handler) ->
    ?assertEqual(#select{params = [#variable{name = <<"max_allowed_packet">>, scope = local}]}, Handler:parse("SELECT @@max_allowed_packet")),
    ?assertEqual(#select{params = [#variable{name = <<"global.max_allowed_packet">>, scope = local}]}, Handler:parse("SELECT @@global.max_allowed_packet")).

select_in_test(Handler) ->
    ?assertEqual(#select{
        params = [#all{}],
        tables = [#table{name = <<"b">>, alias = <<"b">>}],
        conditions = #condition{nexo = in, op1 = #key{alias = <<"n">>, name= <<"n">>}, op2 = #subquery{subquery = [<<"a">>,<<"b">>]}},
        order = [#order{key = <<"a">>, sort = asc}]
    }, Handler:parse(<<"SELECT * from b where n in ('a','b') order by a">>)),

    ?assertEqual(#select{
        params = [#all{}],
        tables = [#table{name = <<"b">>, alias = <<"b">>}],
        conditions = #condition{nexo = not_in, op1 = #key{alias = <<"n">>, name= <<"n">>}, op2 = #subquery{subquery = [<<"a">>,<<"b">>]}},
        order = [#order{key = <<"a">>, sort = desc}]
    }, Handler:parse(<<"SELECT * from b where n not in ('a','b') order by a DESC">>)).

select_all_test(Handler) ->
    ?assertEqual(#select{params=[#all{}]}, Handler:parse("select *")),
    ?assertEqual(#select{params=[#all{}]}, Handler:parse("SELECT *")),
    ?assertEqual(#select{params=[#all{}]}, Handler:parse(" Select    *   ")).

select_strings_test(Handler) ->
    ?assertEqual(#select{params = [#value{value = <<"hola'mundo">>}]}, Handler:parse("select 'hola''mundo'")).

select_simple_test(Handler) ->
    ?assertEqual(#select{params=[#value{name = <<"message">>,value = <<"hi">>}]}, Handler:parse("select 'hi' as message")),
    ?assertEqual(#select{params=[#value{value = <<"hi">>}]}, Handler:parse("select 'hi'")),
    ?assertEqual(#select{params=[#key{alias = <<"hi">>,name = <<"hi">>}]}, Handler:parse("select hi")),
    ?assertEqual(#select{params=[#key{alias = <<"hello">>,name = <<"hi">>}]}, Handler:parse("select hi as hello")),
    ?assertEqual(#select{params=[#key{alias = <<"hi">>,name = <<"hi">>,table = <<"a">>}]}, Handler:parse("select a.hi")),
    ?assertEqual(#select{params=[#key{alias = <<"hello">>,name = <<"hi">>,table = <<"aa">>}]}, Handler:parse("select aa.hi as hello")).

select_simple_multiparams_test(Handler) ->
    ?assertEqual(#select{params=[#value{name = <<"message">>,value = <<"hi">>}, #value{name = <<"id">>,value=1}]}, Handler:parse("select 'hi' as message, 1 as id")),
    ?assertEqual(#select{params=[#value{value = <<"hi">>},#value{value=1}]}, Handler:parse("select 'hi', 1")),
    ?assertEqual(#select{params=[#key{alias = <<"hi">>,name = <<"hi">>}, #key{alias = <<"message">>,name = <<"message">>}]}, Handler:parse("select hi, message")),
    ?assertEqual(#select{params=[#key{alias = <<"hello">>,name = <<"hi">>}, #key{alias = <<"msg">>,name = <<"message">>}]}, Handler:parse("select hi as hello, message as msg")),
    ?assertEqual(#select{params=[#key{alias = <<"hi">>,name = <<"hi">>,table = <<"a">>}, #key{alias = <<"message">>,name = <<"message">>,table = <<"a">>}]}, Handler:parse("select a.hi, a.message")),
    ?assertEqual(#select{params=[#key{alias = <<"hello">>,name = <<"hi">>,table = <<"aa">>}, #key{alias = <<"msg">>,name = <<"message">>,table = <<"aa">>}]}, Handler:parse("select aa.hi as hello, aa.message as msg")),
    ?assertEqual(#select{params=[#all{table = <<"a">>}, #all{table = <<"b">>}]}, Handler:parse("select a.*, b.*")),
    ?assertEqual(#select{params=[#all{}, #all{table = <<"a">>}, #all{table = <<"b">>}]}, Handler:parse("select *, a.*, b.*")).

select_simple_subquery_test(Handler) ->
    ?assertEqual(#select{params=[#subquery{subquery=#select{params=[#all{}]}}]}, Handler:parse("select (select *)")),
    ?assertEqual(#select{params=[#subquery{subquery=#select{params=[#all{}]}}, #key{alias = <<"id">>,name = <<"id">>}]}, Handler:parse("select (select *), id")),
    ?assertEqual(#select{params=[#subquery{name = <<"uno">>, subquery=#select{params=[#key{alias = <<"uno">>,name = <<"uno">>}]}}, #key{alias = <<"dos">>,name = <<"dos">>}]}, Handler:parse("select (select uno) as uno, dos")),
    ok.

select_from_test(Handler) ->
    ?assertEqual(#select{params=[#all{}],tables=[#table{name = <<"data">>,alias = <<"data">>}]}, Handler:parse("select * from data")),
    ?assertEqual(#select{params = [#key{alias = <<"uno">>,name = <<"uno">>},
                  #key{alias = <<"dos">>,name = <<"dos">>}],
        tables = [#table{name = <<"data">>,alias = <<"data">>},
                  #table{name = <<"data2">>,alias = <<"data2">>}]}, Handler:parse("select uno, dos from data, data2")),
    ?assertEqual(#select{params = [#key{alias = <<"uno">>,name = <<"uno">>, table = <<"d">>},
                  #key{alias = <<"dos">>,name = <<"dos">>,table = <<"d2">>}],
        tables = [#table{name = <<"data">>,alias = <<"d">>},
                  #table{name = <<"data2">>,alias = <<"d2">>}]}, Handler:parse("select d.uno, d2.dos from data as d, data2 as d2")),
    ?assertEqual(#select{params = [#all{table = <<"streams">>}], tables =[#table{name= <<"streams">>, alias = <<"streams">>}],
      order = [#order{key= <<"name">>, sort = asc}], limit =1},
        Handler:parse("SELECT `streams`.* FROM `streams` ORDER BY `streams`.`name` ASC LIMIT 1")).

select_from_subquery_test(Handler) ->
    Uno = #value{name = <<"uno">>, value = 1},
    Dos = #value{name = <<"dos">>, value = 2},
    Undef = #value{name = undefined, value = 1},
    Undef2 = #value{value = 2},
    ?assertEqual(#select{params = [#all{}], tables = [#subquery{subquery = #select{params = [Uno,Dos]}}]}, Handler:parse("select * from (select 1 as uno,2 as dos)")),
    ?assertEqual(#select{params = [#subquery{name = <<"id">>,
                                    subquery = #select{params = [Undef]}},
                          #key{alias = <<"uno">>,
                               name = <<"uno">>,
                               table = <<"t">>}],
                tables = [#subquery{name = <<"t">>,
                                    subquery = #select{params = [Undef2]}}]}, Handler:parse("select (select 1) as id, t.uno from (select 2) as t")),
    ?assertEqual(#select{params = [#all{}],
                tables = [#table{name = <<"clientes">>,
                                 alias = <<"clientes">>}],
                conditions = #condition{nexo = in,
                                        op1 = #key{alias = <<"id">>,name = <<"id">>},
                                        op2 = #subquery{subquery = [1,2,3]}}}, Handler:parse("select * from clientes where id in ( 1, 2, 3 )")).

select_where_test(Handler) ->
    ?assertEqual(#select{params = [#all{}],
        tables = [#table{name = <<"tabla">>,alias = <<"tabla">>}],
        conditions = #condition{nexo = eq,
                                op1 = #key{alias = <<"uno">>,name = <<"uno">>},
                                op2 = #value{value = 1}}}, Handler:parse("select * from tabla where uno=1")),
    ?assertEqual(#select{
    params = [#all{}],
    tables = [#table{name = <<"tabla">>,alias = <<"tabla">>}],
    conditions =
        #condition{
            nexo = nexo_and,
            op1 =
                #condition{
                    nexo = eq,
                    op1 =
                        #key{alias = <<"uno">>,name = <<"uno">>},
                    op2 = #value{value = 1}},
            op2 =
                #condition{
                    nexo = lt,
                    op1 =
                        #key{alias = <<"dos">>,name = <<"dos">>},
                    op2 = #value{value = 2}}}}, Handler:parse("select * from tabla where uno=1 and dos<2")),
    ?assertEqual(#select{
    params = [#all{}],
    tables = [#table{name = <<"tabla">>,alias = <<"tabla">>}],
    conditions =
        #condition{
            nexo = nexo_and,
            op1 =
                #condition{
                    nexo = eq,
                    op1 =
                        #key{alias = <<"uno">>,name = <<"uno">>},
                    op2 = #value{value = 1}},
            op2 =
                #condition{
                    nexo = nexo_and,
                    op1 =
                        #condition{
                            nexo = lt,
                            op1 =
                                #key{alias = <<"dos">>,name = <<"dos">>},
                            op2 = #value{value = 2}},
                    op2 =
                        #condition{
                            nexo = gt,
                            op1 =
                                #key{alias = <<"tres">>,name = <<"tres">>},
                            op2 = #value{value = 3}}}}},
        Handler:parse("select * from tabla where uno=1 and dos<2 and tres>3")),
    ?assertEqual(Handler:parse("select * from tabla where uno=1 and dos<=2 and tres>=3"), Handler:parse("select * from tabla where uno=1 and (dos=<2 and tres=>3)")),
    ?assertEqual(#select{
    params = [#all{}],
    tables = [#table{name = <<"a">>,alias = <<"a">>}],
    conditions =
        #condition{
            nexo = nexo_and,
            op1 =
                #condition{
                    nexo = nexo_and,
                    op1 =
                        #condition{
                            nexo = eq,
                            op1 = #key{alias = <<"a">>,name = <<"a">>},
                            op2 = #value{value = 1}},
                    op2 =
                        #condition{
                            nexo = eq,
                            op1 = #key{alias = <<"b">>,name = <<"b">>},
                            op2 = #value{value = 2}}},
            op2 =
                #condition{
                    nexo = eq,
                    op1 = #key{alias = <<"c">>,name = <<"c">>},
                    op2 = #value{value = 3}}}}
    , Handler:parse("select * from a where (a=1 and b=2) and c=3")).

select_function_test(Handler) ->
    ?assertEqual(#select{params = [#function{name = <<"count">>, params = [#all{}]}]}, Handler:parse("select count(*)")),
    ?assertEqual(#select{params = [#function{name = <<"concat">>,
                            params = [#value{value = <<"hola">>},
                                      #value{value = <<"mundo">>}]}]}, Handler:parse("select concat('hola', 'mundo')")).

select_groupby_test(Handler) ->
    ?assertEqual(#select{params = [#key{alias = <<"fecha">>,
                       name = <<"fecha">>},
                  #function{name = <<"count">>,
                            params = [#all{}],
                            alias = <<"total">>}],
        tables = [#table{name = <<"datos">>,alias = <<"datos">>}],
        group = [<<"fecha">>]}, Handler:parse("select fecha, count(*) as total from datos group by fecha")),
    ?assertEqual(#select{params = [#key{alias = <<"fecha">>,
                       name = <<"fecha">>},
                  #function{name = <<"count">>,
                            params = [#all{}],
                            alias = undefined}],
        tables = [#table{name = <<"datos">>,alias = <<"datos">>}],
        group = [<<"fecha">>]}, Handler:parse("select fecha, count(*) from datos group by fecha")),
    ?assertEqual(#select{params = [#all{}], tables = [#table{name = <<"a">>,alias = <<"a">>}], group = [1]}, Handler:parse("select * from a group by 1")).

select_orderby_test(Handler) ->
    ?assertEqual(#select{
            params=[#all{}],
            tables=[#table{alias = <<"tabla">>, name = <<"tabla">>}],
            order=[#order{key=1,sort=asc}]
        }, Handler:parse("select * from tabla order by 1")),
    ?assertEqual(#select{
            params=[#all{}],
            tables=[#table{alias = <<"tabla">>, name = <<"tabla">>}],
            order=[#order{key=1,sort=desc}]
        }, Handler:parse("select * from tabla order by 1 desc")).

select_limit_test(Handler) ->
    ?assertEqual(#select{params=[#all{}], tables=[#table{alias = <<"tabla">>, name = <<"tabla">>}], limit=10}, Handler:parse("select * from tabla limit 10")),
    ?assertEqual(#select{params=[#all{}], tables=[#table{alias = <<"tabla">>, name = <<"tabla">>}], limit=10, offset=5}, Handler:parse("select * from tabla limit 10 offset 5")),
    ok.

select_arithmetic_test(Handler) ->
    ?assertEqual(#select{params = [#operation{type = <<"+">>, op1 = #value{value = 2}, op2 = #value{value = 3}}]}, Handler:parse("select 2+3")),
    ?assertEqual(Handler:parse("select 2+3"), Handler:parse("select (2+3)")),
    ?assertNotEqual(Handler:parse("select (2+3)*4"), Handler:parse("select 2+3*4")),
    ?assertEqual(#select{params = [#operation{type = <<"*">>, op1 = #operation{type = <<"+">>, op1 = #value{value = 2}, op2 = #value{value = 3}}, op2 = #value{value = 4}}]}, Handler:parse("select (2+3)*4")),
    ?assertEqual(#select{params = [#all{}], tables = [#table{name = <<"data">>,alias = <<"data">>}], conditions = #condition{nexo = eq,
                                op1 = #key{alias = <<"a">>,name = <<"a">>},
                                op2 = #operation{type = <<"*">>,
                                                 op1 = #key{alias = <<"b">>,name = <<"b">>},
                                                 op2 = #value{value = 3}}}},
        Handler:parse("select * from data where a = b*3")).

update_simple_test(Handler) ->
    ?assertEqual(#update{table=#table{alias = <<"mitabla">>, name = <<"mitabla">>}, set=[#set{key = <<"dato">>, value=#value{value=1}}]}, Handler:parse("update mitabla set dato=1")),
    ?assertEqual(Handler:parse(" Update   mitabla SET dato  =  1    "), Handler:parse("UPDATE mitabla SET dato=1")).

update_multiparams_test(Handler) ->
    ?assertEqual(
        #update{
            table=#table{alias = <<"mitabla">>, name = <<"mitabla">>},
            set=[
                #set{key = <<"dato1">>, value=#value{value = 1}},
                #set{key = <<"dato2">>, value=#value{value = <<"bon jovi">>}},
                #set{key = <<"dato3">>, value=#value{value = <<"this ain't a love song">>}}
            ]
        }, Handler:parse("update mitabla set dato1=1, dato2='bon jovi', dato3='this ain''t a love song'")
    ).

update_where_test(Handler) ->
    ?assertEqual(#update{
            table=#table{alias = <<"mitabla">>, name = <<"mitabla">>},
            set=[#set{key = <<"dato">>, value=#value{value=1}}],
            conditions=#condition{
                nexo=eq,
                op1=#key{alias = <<"dato">>, name = <<"dato">>},
                op2=#value{value=5}
            }
        }, Handler:parse("update mitabla set dato=1 where dato=5")),
    ok.

create_table_test(Handler) ->
    ?assertEqual(
        #create_table{
            table = #table{alias = <<"my_table">>, name = <<"my_table">>},
            fields = [
                #field{name = <<"id">>, type = integer, primary = true},
                #field{name = <<"username">>, type = {text, undefined}}
            ]
        }, Handler:parse("create table my_table(id int primary key, username text)")).

drop_table_test(Handler) ->
    ?assertEqual(#drop_table{table = #table{alias = <<"my_table">>, name = <<"my_table">>}}, Handler:parse("drop table my_table")).
