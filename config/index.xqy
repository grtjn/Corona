xquery version "1.0-ml";

import module namespace endpoints="http://marklogic.com/corona/endpoints" at "endpoints.xqy";
import module namespace functx="http://www.functx.com" at "/MarkLogic/functx/functx-1.0-nodoc-2007-01.xqy";

import module namespace config="http://marklogic.com/corona/index-config" at "../corona/lib/index-config.xqy";
import module namespace manage="http://marklogic.com/corona/manage" at "../corona/lib/manage.xqy";

import module namespace template="http://marklogic.com/corona/template" at "/corona/htools/template.xqy";

declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare namespace rest="http://marklogic.com/appservices/rest";
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

template:apply(
	<div>
		<p>Welcome, this is the Corona index page. On the left you see a list of all endpoints you can view with the browser.
		Note in particular /config/setup. Make sure to run that before you start to use Corona.</p>
	</div>,
	"Corona index",
	
	for $action in endpoints:options()/rest:request
	let $action-name := replace(replace(replace($action/@endpoint, '^/', ''), '\.xq(y)?$', ''), '[^\w\d\-_]+', ':')
	let $uri := replace(replace(replace($action/@uri, '^\^', ''), '\$$', ''), '/\?$', '')
		for $path in distinct-values(local:expand-path($uri))
		where $action[empty(rest:http) or rest:http[@method eq 'GET']] and not(matches($path, '\(?\[[^\[\]]+\]\+\)?'))
		return
			<li><a href="{$path}?outputFormat=xml" target="{if ($path = ('', '/explore')) then '' else '_blank'}">{if ($path eq '') then '/' else $path}</a></li>,
	
	0,
	()
)
