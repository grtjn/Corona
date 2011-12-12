xquery version "1.0-ml";

import module namespace endpoints="http://marklogic.com/corona/endpoints" at "endpoints.xqy";
import module namespace functx="http://www.functx.com" at "/MarkLogic/functx/functx-1.0-nodoc-2007-01.xqy";

import module namespace config="http://marklogic.com/corona/index-config" at "../corona/lib/index-config.xqy";
import module namespace manage="http://marklogic.com/corona/manage" at "../corona/lib/manage.xqy";

import module namespace template="http://marklogic.com/corona/template" at "/corona/htools/template.xqy";

import module namespace rest="http://marklogic.com/appservices/rest" at "../corona/lib/rest/rest.xqy";

declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare namespace json="http://marklogic.com/json";

declare option xdmp:mapping "false";

declare function local:expand-matches($parts as element()*, $prevs as xs:string*)
	as xs:string*
{
    if (exists($parts)) then
        let $first := $parts[1]
        let $remainder := $parts[position() > 1]
        return
			for $i in if ($first[self::matches]) then $first/match else $first
			for $p in $prevs
			return
				local:expand-matches($remainder, concat($p, $i))
    else
		$prevs
};


declare function local:expand-path($uri as xs:string)
	as xs:string*
{
	let $parts :=
		for $n in functx:get-matches-and-non-matches($uri, "\(((([^|\(\)]+(\([^\(\)]+\)[^|\(\)]*)*)|(\([^\(\)]+\)[^|\(\)]*))\|)+(([^|\(\)]+(\([^\(\)]+\)[^|\(\)]*)*)|(\([^\(\)]+\)[^|\(\)]*))\)")
		return
			if ($n[self::match]) then
				<matches>{
					for $t in tokenize(substring($n, 2, string-length($n) - 2), '\|')
					return
						<match>{$t}</match>
				}</matches>
			else
				$n
	for $path in 
        local:expand-matches($parts, "")
	return
		$path
};


let $params := rest:process-request(endpoints:request("/config/explore.xqy"))
let $page := max((map:get($params, "page"), 0))

let $numDocs := xdmp:estimate(doc())
let $numJSONDocs := xdmp:estimate(/json:json)
let $numTextDocs := xdmp:estimate(/text())
let $numBinaryDocs := xdmp:estimate(/binary())
let $numXMLDocs := xdmp:estimate(/*) - $numJSONDocs

let $page-size := 20
let $max-page := $numDocs div $page-size

let $start := $page * $page-size
let $end := ($page + 1) * $page-size - 1

return

template:apply(
	<div>
		<div>
			<b>Statistics</b><br/>
			<div>XML docs : {$numXMLDocs}</div>
			<div>JSON docs: {$numJSONDocs}</div>
			<div>Text docs: {$numTextDocs}</div>
			<div>Bin docs : {$numBinaryDocs}</div>
		</div>
		<div>
			{ if ($page gt 0) then <a href="?page={$page - 1}">prev</a> else () }
			<ul>{
				for $uri in cts:uris()[$start to $end]
				return
					<li><a href="/store?uri={encode-for-uri($uri)}" target="_blank">{$uri}</a></li>
			}</ul>
			{ if ($page lt $max-page) then <a href="?page={$page + 1}">next</a> else () }
		</div>
	</div>,
	
	"Corona explore",
	
	for $action in endpoints:options()/rest:request
	let $action-name := replace(replace(replace($action/@endpoint, '^/', ''), '\.xq(y)?$', ''), '[^\w\d\-_]+', ':')
	let $uri := replace(replace(replace($action/@uri, '^\^', ''), '\$$', ''), '/\?$', '')
		for $path in distinct-values(local:expand-path($uri))
		where $action[empty(rest:http) or rest:http[@method eq 'GET']] and not(matches($path, '\(?\[[^\[\]]+\]\+\)?'))
		return
			<li><a href="{$path}?outputFormat=xml" target="{if ($path = ('', '/explore')) then '' else '_blank'}">{if ($path eq '') then '/' else $path}</a></li>,
	
	$page,
	
	()
)
