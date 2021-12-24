%%%-------------------------------------------------------------------
%%% @author User
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. 12月 2021 15:17
%%%-------------------------------------------------------------------
-module(astar).
-author("oujl").

-compile(export_all).

-define(X_START,0).
-define(Y_START,0).
-define(X_END,11).
-define(Y_END,11).

-define(GRID_V, 10). 	%% 垂直代价
-define(GRID_D, 14).	%% 对角代价

-record(a_node, {
    id = 0
    ,x = 0
    ,y = 0
    ,cost = 0   %% 代价系数比如陆地系数为1
}).

%%-record(a_path, {
%%    now = 0
%%    ,tar = 0
%%    ,open_list = []
%%    ,close_list = []
%%    ,path = []
%%}).

start(Start, End) ->
    Now_node = lists:keyfind(Start, #a_node.id, get_map()),
    Target_node = lists:keyfind(End, #a_node.id, get_map()),
    search(Now_node, 0,Target_node, [], [], []).

search(Target_node, _, Target_node, _Open_list, _Close_list, Path) ->
    Path ++ [Target_node];

search(Now_node, Last_node,Target_node, Open_list, Close_list, Path) ->
    MapList = get_map(),
    Close_list1111 = case Close_list of
        [] ->
            lists:foldl(fun(Node, Acc) ->
            #a_node{cost = C} = Node ,
            case C =:= 0 of
                true ->
                    Acc ++ [Node];
                false ->
                    Acc
            end
            end, [] , MapList);
        _ -> Close_list
    end,
%%    io:format("~n Now_Node:~p ~n",[Now_node]),
    Close_list1 = [Now_node] ++ Close_list1111,
%%    io:format("~n 1 ~n"),
    Nearby_list = get_nearby_node(Now_node, Close_list1),
    List = lists:seq(1, length(Nearby_list)),
    Res = case Last_node of
        0 ->
            {0, Now_node};
        _ ->
            Father_G = get_G(Last_node, Now_node),
            Other_node = get_other_node(Now_node, Open_list),
%%            io:format("~p",[Other_node]),
            Other_node_min_G = lists:map(fun(X) ->
                {X, get_G(Last_node, X)}
            end, Other_node),
            {Node11, _} = lists:nth(1, lists:ukeysort(2, Other_node_min_G)),
            case Father_G =< Other_node_min_G of
                true ->
                    {0, Now_node};
                false ->
                    {1, Node11}
            end
    end,
    New_List = lists:map(fun(P) ->
        Node = lists:nth(P, Nearby_list),
        #a_node{id = Id} = Node,
        G = get_G(Now_node, Node),
        H = get_H(Node, Target_node),
        {Id, G + H}
                         end, List),
    {New_Node, _} = lists:nth(1, (lists:ukeysort(2, New_List))),
%%    io:format("~n New_Node:~p ~n",[New_Node]),
    New_Node11 = lists:keyfind(New_Node, #a_node.id, MapList),
%%    io:format("~n New_Node11:~p ~n",[New_Node11]),
    {New_Node1, Last_node1, Target_node1, Open_list1, Close_list11} = case Res of
        {0, AAA} ->

            {New_Node11, AAA, Target_node, get_open_lists(New_Node11, Open_list, Close_list1), Close_list1};
        {1, BBB} ->
            {New_Node11, BBB, Target_node, get_open_lists(New_Node11, Open_list, Close_list1), Close_list1}
    end,
    Path1 = Path ++ [Now_node],
    search(New_Node1, Last_node1, Target_node1, Open_list1, Close_list11, Path1).

get_open_lists(Node,Open_List,Close_List) ->
%%    io:format("2 ~n"),
%%    io:format("Node:~p ~n",[Node]),
    Nearby_Node = get_nearby_node(Node, Close_List),
    New_List = lists:filter(fun(X) ->
        case lists:member(X, Open_List) of
            false ->true;
            true ->false
        end
        end, Nearby_Node),
    New_List ++ Open_List.

get_other_node(Now_node, Open_list) ->
%%    io:format("~p",[Now_node]),
    #a_node{x = X, y = Y} = Now_node,
    Node_List = [(X-1)*100+Y,(X+1)*100+Y,Y+1+X,Y-1+X],
    Other_node_list = lists:foldl(fun(Z, Acc2) ->
        case lists:keyfind(Z, #a_node.id, Open_list) of
            false ->
                Acc2;
            List ->
                Acc2 ++ [List]
        end
                                   end, [], Node_List),
    Other_node_list.

get_nearby_node(Node, Close_list) ->
%%    io:format("Node:~p ~n",[Node]),
    #a_node{x = X, y = Y} = Node,
    Map = get_map(),
    X1 = [X + 1, X, X - 1],
    Y1 = [Y + 1, Y, Y - 1],
    IdList = lists:foldl(fun(XX, Acc) ->
            Acc ++ lists:foldl(fun(YY, Acc1) ->
                                    [XX * 100 + YY] ++ Acc1
                               end, [], Y1)
                         end, [], X1),
    Nearby_node_list = lists:foldl(fun(Z, Acc2) ->
        case lists:keyfind(Z, #a_node.id, Map) of
            false ->
                Acc2;
            List ->
                #a_node{id = ID99} = List,
%%                io:format("~p ~n ID:~p ~n id:~p list:~p ~n",[Close_list,ID99,#a_node.id,List]),
%%                io:format("~n ***************************"),
               Result = case lists:keyfind(ID99, #a_node.id, Close_list) of
                   false ->
                       [List];
                   _ ->
                       []
               end,
                  Result ++ Acc2
        end
              end, [], IdList),
    Nearby_node_list.

get_G(Node1, Node2) ->
    #a_node{x= X, y = Y} = Node1,
    #a_node{x= X1, y = Y1, cost = Cost} = Node2,
    (abs(X - X1) + abs(Y - Y1)) * Cost.

get_H(Node1, End_Node) ->
    #a_node{x= X, y = Y} = Node1,
    #a_node{x= X1, y = Y1} = End_Node,
    (abs(X - X1) + abs(Y - Y1)) * ?GRID_V.

calculate_F(Path) ->
    List = lists:seq(1, length(Path) - 1),
    G = lists:foldl(fun(X, Acc) ->
        #a_node{x = XX2, y = YY2} = lists:nth(X + 1, Path),
        #a_node{x = XX1, y = YY1} = lists:nth(X, Path),
        case abs(XX2 - XX1) + abs(YY2 -YY1) of
            1 -> Acc + ?GRID_V;
            2 -> Acc + ?GRID_D;
            _ -> Acc
        end
    end, 0, List),
    #a_node{x = Start_X, y = Start_Y} = lists:nth(1, Path),
    #a_node{x = End_X, y = End_Y} = lists:last(Path),
    H = (abs(Start_X - End_X) + abs(Start_Y -End_Y)) * ?GRID_V,
    H + G.

get_map() ->
    X_list = lists:seq(?X_START, ?X_END),
    Y_list = lists:seq(?Y_START, ?Y_END),
    lists:foldl(fun(X, Acc1) ->
        lists:foldl(fun(Y, Acc2) ->
            case X =:= ?X_START orelse Y =:= ?Y_START orelse X =:= ?X_END orelse Y =:= ?Y_END of
                true ->
                    [#a_node{id = X * 100 + Y,x = X, y = Y ,cost = 0}] ++ Acc2;
                false ->
                    [#a_node{id = X * 100 + Y,x = X, y = Y ,cost = 1}] ++ Acc2
            end
            end, [], Y_list) ++ Acc1
        end, [], X_list).

%%show() ->
%%    MapList = get_map(),
%%    lists:foldl(fun(Node, Acc) ->
%%        #a_node{cost = C} = Node ,
%%        case C =:= 0 of
%%            true ->
%%                Acc ++ [Node];
%%            false ->
%%                Acc
%%        end
%%                end, [] , MapList),
%%    Now_node = lists:keyfind(201, #a_node.id, get_map()).



%%%% @doc 通过遍历去重
%%-spec unique_1(List) -> Return when
%%    List        :: list(),
%%    Return      :: list().
%%unique_1(List) ->
%%    unique_1(List, []).
%%
%%unique_1([], ResultList) -> ResultList;
%%unique_1([H|L], ResultList) ->
%%    case lists:member(H, ResultList) of
%%        true -> unique_1(L, ResultList);
%%        false -> unique_1(L, [H|ResultList])
%%    end.
