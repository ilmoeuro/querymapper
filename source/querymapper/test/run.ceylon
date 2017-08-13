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

import querymapper.base {
    table,
    column,
    Table,
    from,
    leftJoin,
    _and,
    greaterThan,
    asc,
    _equal,
    Key,
    insert
}

table
shared class Employee(id, name, age, salary, company) {
    column
    shared Key<Employee> id;

    column
    shared String name;

    column
    shared Integer age;

    column
    shared Float salary;

    column
    shared Key<Company> company;
}

table
shared class Company(id, name) {
    column
    shared Key<Company> id;

    column
    shared String name;
}

shared void run() {
    value devs = Table("devs", `Employee`);
    value company = Table("company", `Company`);
    print(
        from {
            devs;
            leftJoin(
                company,
                devs.column(`Employee.company`),
                company.column(`Company.id`)
            )
        }
        .where (
            _and {
                greaterThan(devs.column(`Employee.age`), 50),
                _equal(company.column(`Company.name`), "ACME")
            }
        )
        .orderBy {
            asc(devs.column(`Employee.salary`))
        }
        .select(devs)
    );
    
    value dev = Employee {
        id = Key<Employee>(0);
        name = "John Doe";
        age = 43;
        salary = 50_000.00;
        company = Key<Company>(1);
    };
    
    print(insert(dev));
}