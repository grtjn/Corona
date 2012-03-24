(:
Copyright 2011 MarkLogic Corporation

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

import module namespace functx="http://www.functx.com" at "/MarkLogic/functx/functx-1.0-nodoc-2007-01.xqy";

declare option xdmp:mapping "false";


let $requestMethod := xdmp:get-request-method()
let $params := rest:process-request(endpoints:request("/corona/manage/namespace.xqy", $requestMethod))
let $prefix := map:get($params, "prefix")
let $uri := map:get($params, "uri")
let $outputFormat := (map:get($params, "outputFormat"), 'json')[1]

let $existing := manage:getNamespaceURI($prefix)

return common:output(
    if($requestMethod = "GET")
    then
		let $json :=
			if(string-length($prefix))
			then
				if(exists($existing))
				then $existing
				else common:error("corona:NAMESPACE-NOT-FOUND", "Namespace not found", "json")
			else json:array(manage:getAllNamespaces())
		return
			if ($outputFormat eq 'xml') then
				<namespace>{
					functx:change-element-ns-deep($json, "", "")
				}</namespace>
			else $json

    else if($requestMethod = "POST")
    then
        if(string-length($prefix))
        then
            if(not(matches($prefix, "^[A-Za-z_][A-Za-z0-9_\.]*$")))
            then common:error("corona:INVALID-PARAMETER", "Invalid namespace prefix", "json")
            else manage:setNamespaceURI($prefix, $uri)
        else common:error("corona:INVALID-PARAMETER", "Must specify a prefix for the namespace", "json")

    else if($requestMethod = "DELETE")
    then
        if(string-length($prefix))
        then
            if(exists($existing))
            then manage:deleteNamespace($prefix)
            else common:error("common:NAMESPACE-NOT-FOUND", "Namespace not found", "json")
        else manage:deleteAllNamespaces()
    else common:error("corona:UNSUPPORTED-METHOD", concat("Unsupported method: ", $requestMethod), "json")
)
