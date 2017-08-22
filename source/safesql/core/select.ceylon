/* Copyright 2017 Ilmo Euro

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License. */

import ceylon.collection {
    ArrayList,
    MutableList
}
import ceylon.language.meta.model {
    Attribute
}

"The entry point to a `SELECT` query, builds the `FROM` clause of the query.
 
 The `FROM` clause is **first**, because it then determines the table types
 that can be used in the rest of the query, which aids in type inference
 and autocompletion."
shared From<Source> from<Source>(
    "The first table to select from, that may be subject to joins"
    Table<Source> source,
    "The joins, applied in order."
    see(`function innerJoin`,
        `function leftJoin`,
        `function rightJoin`,
        `function crossJoin`)
    {Join<Source>*} joins = {}
) => From(source, joins);

"The auxiliary class used by [[from]]"
shared sealed class From<Source>(source, joins = {}) {
    Table<Source> source;
    {Join<Source>*} joins;
    
    "Build the `WHERE` cause of the query."
    shared Where<Source> where(condition) {
        "The condition of the `WHERE` clause"
        Condition<Source>? condition;
        return Where(source, joins, condition);
    }
}

"The auxiliary class used by [[From.where]]"
shared sealed class Where<Source>(source, joins, condition) {
    Table<Source> source;
    {Join<Source>*} joins;
    Condition<Source>? condition;
    
    "Build the `ORDER BY` clause of the query"
    shared OrderBy<Source> orderBy(ordering) {
        "The criteria to order the results by."
        {Ordering<Source>*} ordering;
        return OrderBy(source, joins, condition, ordering);
    }

    "Finish the `SELECT` query."
    shared SelectQuery<Result> select<Result>(columns) given Result satisfies Source {
        "The table to pick from the query as the result"
        Table<Result> columns;
        return selectQuery(columns, source, {}, condition);
    }
}

"The auxiliary class used by [[Where.orderBy]]"
shared sealed class OrderBy<Source>(source, joins, condition, ordering) {
    Table<Source> source;
    {Join<Source>*} joins;
    Condition<Source>? condition;
    {Ordering<Source>*} ordering;
    
    "Finish the `SELECT` query."
    shared SelectQuery<Result> select<Result>(columns)
            given Result satisfies Source {
        "The table to pick from the query as the result"
        Table<Result> columns;
        return selectQuery(columns, source, joins, condition, ordering);
    }
}

"A `SELECT` query.
 
 Use [[from]] to build instances of this class."
see(`function from`)
shared sealed class SelectQuery<Result>(query, params, resultTable) {
    "String representation of the query"
    shared String query;
    "The bundled query parameters that are required by this query."
    shared {[Attribute<>, Object]*} params;
    "The (aliased) table the result comes from, used for aliased column names."
    shared Table<Result> resultTable;
    
    string => "`` `class`.qualifiedName `` {
                   query=``query``,
                   params=``params``,
                   resultTable=``resultTable``
               }";
}

SelectQuery<Result> selectQuery<Result, Source>(
    columns,
    source,
    joins,
    condition = null,
    ordering = {}
) given Result satisfies Source {
    Table<Result> columns;
    Table<Source> source;
    {Join<Source>*} joins;
    Condition<Source>? condition;
    {Ordering<Source>*} ordering;
    
    value queryBuilder = StringBuilder();
    value queryParams = ArrayList<[Attribute<>, Object]>();
    value emitter = PgH2SqlEmitter(queryBuilder.append);

    emitter.select(columns);
    emitter.from(source);
    if (is {Join<Source>+} joins) {
        emitter.joins(joins);
    }
    if (exists condition) {
        emitter.where(condition);
        extractConditionParams(queryParams, condition);
    }
    if (is {Ordering<Source>+} ordering) {
        emitter.orderBy(ordering);
    }
    
    return SelectQuery<Result>(queryBuilder.string, queryParams, columns);
}

void extractConditionParams<Source>(MutableList<[Attribute<>, Object]> result, Condition<Source> where) {
    switch (where) 
    case (is Compare<Source>) {
        variable Object val = where.rhs;
        result.add([where.lhs.attribute, val]);
    }
    case (is BinaryCondition<Source>) {
        for (condition in where.conditions) {
            extractConditionParams(result, condition);
        }
    }
    case (is UnaryCondition<Source>) {
        extractConditionParams(result, where.inner);
    }
}