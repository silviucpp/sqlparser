% common

-record(table, {name, alias}).
-record(all, {table}).
-record(subquery, {name, subquery }).
-record(key, {alias, name, table}).
-record(value, {name, value}).
-record(condition, {nexo, op1, op2}).
-record(function, {name, params, alias}).
-record(operation, {type, op1, op2}).
-record(variable, {name, label, scope}).
-record(system_set, {'query'}).

-type sql() :: show() | select() | update() | delete() | insert() | create_table() | drop_table() | truncate_table().

% show

-record(show, {type, full, from, conditions}).
-type show() :: #show{}.

% select

-record(select, {params, tables, conditions, group, order, limit, offset}).
-record(order, {key, sort}).
-type select() :: #select{}.

% update

-record(update, {table, set, conditions}).
-record(set, {key, value}).

-type update() :: #update{}.

% delete

-record(delete, {table, conditions}).
-type delete() :: #delete{}.

% insert

-record(insert, {table, values}).
-type insert() :: #insert{}.

% describe

-record(describe, {table}).
-type describe() :: #describe{}.

% create table

-record(create_table, {table, fields}).
-type create_table() :: #create_table{}.

-record(field, {
    name,
    type,
    default,
    unique = false,
    primary = false,
    null = true
}).

% drop table

-record(drop_table, {table}).
-type drop_table() :: #drop_table{}.

% truncate table

-record(truncate_table, {table}).
-type truncate_table() :: #truncate_table{}.

% database administration statements

-record(management, {action :: action(), data :: account() | permission() }).
-record(account, {access}).
-record(permission, {on, account, conditions}).

-type action() :: create | drop | grant | rename | revoke | setpasswd.
-type account() :: #account{}.
-type permission() :: #permission{}.
