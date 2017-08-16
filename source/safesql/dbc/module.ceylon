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

native("jvm")
module safesql.dbc "1.0.0" {
    shared import java.base "8";
    shared import safesql.core "1.0.0";
    shared import ceylon.dbc "1.3.2";

    import ceylon.interop.java "1.3.2";
    import ceylon.logging "1.3.2";
    import safesql.backend "1.0.0";
}