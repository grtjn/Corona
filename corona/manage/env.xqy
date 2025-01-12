(:
Copyright 2011 Swell Lines LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
:)

xquery version "1.0-ml";

import module namespace manage="http://marklogic.com/corona/manage" at "../lib/manage.xqy";
import module namespace common="http://marklogic.com/corona/common" at "../lib/common.xqy";
import module namespace json="http://marklogic.com/json" at "../lib/json.xqy";

import module namespace rest="http://marklogic.com/appservices/rest" at "../lib/rest/rest.xqy";
import module namespace endpoints="http://marklogic.com/corona/endpoints" at "/config/endpoints.xqy";

declare option xdmp:mapping "false";


let $requestMethod := xdmp:get-request-method()
let $params := rest:process-request(endpoints:request("/corona/manage/env.xqy", $requestMethod))
let $name := map:get($params, "name")

return common:output(
    try {
        if($requestMethod = ("POST", "DELETE") and string-length($name) = 0)
        then common:error("corona:INVALID-PARAMETER", "Must specify an environment variable name")

		else if($requestMethod = "GET")
		then
            if(string-length($name))
            then json:object(($name, manage:getEnvVar($name)))
            else manage:getEnvVars()
		else if($requestMethod = "POST")
		then (
			xdmp:set-response-code(204, "Variable saved"),
            manage:setEnvVar($name, map:get($params, "value"))
		)
		else if($requestMethod = "DELETE")
		then manage:deleteEnvVar($name)
		else ()
    }
    catch ($e) {
        common:errorFromException($e, "json")
    }
)

