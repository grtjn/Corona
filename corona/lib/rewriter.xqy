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

import module namespace manage="http://marklogic.com/corona/manage" at "manage.xqy";
import module namespace common="http://marklogic.com/corona/common" at "common.xqy";
import module namespace rest="http://marklogic.com/appservices/rest" at "rest/rest.xqy";
import module namespace endpoints="http://marklogic.com/corona/endpoints" at "/config/endpoints.xqy";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare option xdmp:mapping "false";

let $url := xdmp:get-request-url()
let $log :=
    if(manage:getDebugLogging())
    then (
        common:log("Request", concat(xdmp:get-request-method(), " ", $url)),

        for $header in xdmp:get-request-header-names()
        for $value in xdmp:get-request-header($header)
        return common:log("Header", concat("    ", $header, ": ", $value)),

        for $param in xdmp:get-request-field-names()
        for $value in xdmp:get-request-field($param)
        return common:log("Parameter", concat("    ", $param, ": ", $value))
    )
    else ()
return
	if(starts-with($url, "/test") or starts-with($url, "/corona/htools/"))
    then $url
    else
		rest:rewrite(endpoints:options())
