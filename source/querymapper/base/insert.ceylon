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
    ArrayList
}
import ceylon.language.meta.model {
    Class
}

shared Query insert<Insertable>(Insertable insertable)
        given Insertable satisfies Object {
    value queryBuilder = StringBuilder();
    value queryParams = ArrayList<Anything>();
    value emitter = PgH2SqlEmitter(queryBuilder.append);
    value fnName = `function insert`.name;
    value insertableName = `Insertable`.string;

    "``fnName`` expects a class type parameter, given ``insertableName``"
    assert (is Class<> type = `Insertable`);
    emitter.insert(type);
    
    for (attribute in columnAttributes(type)) {
        if (columnAnnotation(attribute).insert) {
            variable Anything val = attribute.bind(insertable).get();
            if (is Key<out Anything, out Object> key = val) {
                val = key.field;
            }
            queryParams.add(val);
        }
    }

    return Query(queryBuilder.string, queryParams);
}