xquery version "1.0-ml";

import module namespace endpoints="http://marklogic.com/corona/endpoints" at "endpoints.xqy";
import module namespace functx="http://www.functx.com" at "/MarkLogic/functx/functx-1.0-nodoc-2007-01.xqy";

import module namespace config="http://marklogic.com/corona/index-config" at "../corona/lib/index-config.xqy";
import module namespace manage="http://marklogic.com/corona/manage" at "../corona/lib/manage.xqy";

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
		if (contains($path, '/range/')) then
			for $name in config:rangeNames()
			return
				replace($path, '\(?\[[^\[\]]+\]\+\)?', $name)
		else if (contains($path, '/bucketedrange/')) then
			for $name in config:bucketedRangeNames()
			return
				replace($path, '\(?\[[^\[\]]+\]\+\)?', $name)
		else if (contains($path, '/geospatial/')) then
			for $name in config:geoNames()
			return
				replace($path, '\(?\[[^\[\]]+\]\+\)?', $name)
		else if (contains($path, '/place/')) then
			for $name in config:placeNames()
			return
				replace($path, '\(?\[[^\[\]]+\]\+\)?', $name)
		else if (contains($path, '/transformer/')) then
			for $name in manage:getAllTransformerNames()
			return
				replace($path, '\(?\[[^\[\]]+\]\+\)?', $name)
		else if (contains($path, '/namespace/')) then
			for $name in manage:getAllNamespaces()/json:prefix
			return
				replace($path, '\(?\[[^\[\]]+\]\+\)?', $name)
		else
			$path
};

(: The following attempts to adhere to http://www.w3.org/Submission/wadl/, roughly tested with SOAPui 4.0 :)

<wadl:application xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://wadl.dev.java.net/2009/02 wadl.xsd"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:wadl="http://wadl.dev.java.net/2009/02">{
	
	(: TODO: all namespaces of elements being referenced in types. (none ever?) :)
	
		<wadl:resources base="http://{xdmp:get-request-header('HOST')}">{
		
			for $action in endpoints:options()/rest:request
			let $action-name := replace(replace(replace($action/@endpoint, '^/', ''), '\.xq(y)?$', ''), '[^\w\d\-_]+', ':')
			
			let $uri := replace(replace(replace($action/@uri, '^\^', ''), '\$$', ''), '/\?$', '')
			(: TODO: path is derived from uri pattern, should be expanded to all allowed variants.. (can that be calculated?) :)
			for $path in local:expand-path($uri)
			return
			
			<wadl:resource id="{$action-name}" path="{$path}">{
			
			
				let $methods :=
					if ($action/rest:http) then
						$action/rest:http
					else
						<rest:http method="GET"/>
				for $method in $methods
				return
				<wadl:method id="{$action-name}:{$method/@method}" name="{fn:upper-case($method/@method)}">
					
					<wadl:request>{
						for $param in ($action/rest:param, $method/rest:param)
						let $type := ($param/@as, 'string')[. != ''][1]
						let $type :=
							if (fn:matches($type, '^element\(\)$')) then
								"xs:any"
							else if (fn:matches($type, '^element\((.+)\)$')) then
								fn:replace($type, '^element\((.+)\)$', '$1')
							else
								concat('xs:', $type)
						let $required := ($param/@required, 'false')[. != ''][1]
						return
							<wadl:param name="{$param/@name}" type="{$type}" style="query" required="{$required}"/>
						
							(: TODO: other relevant attribs for params? :)
					}</wadl:request>
					
					<wadl:response status="{ if (fn:upper-case($method/@method) = ('PUT', 'DELETE')) then 204 else 200}">
						{
							(: TODO: returned types differ per uri. JSON is most default, xml sometimes optional, text and binary only when requesting such docs from store? :)

							if ($path = ('', '/explore', '/config/setup')) then
								<wadl:representation mediaType="text/html"/>
							else
							if ($path = ('/wadl', '/soapui')) then
								<wadl:representation mediaType="text/xml"/>
							else (
								<wadl:representation mediaType="application/json"/>,
								if ($action/rest:param[@name = 'outputFormat'] or contains($path, '/store')) then
									<wadl:representation mediaType="text/xml" element="xs:anyType"/>
								else ()
							),

							if (contains($path, '/store')) then (
								<wadl:representation mediaType="plain/text"/>,
								<wadl:representation mediaType="application/octet-stream"/>
							) else ()
						}
					</wadl:response>
					
					{
						for $i in (400, 404, 500) (: See common.xqy for details on returned error codes.. :)
						return
							<wadl:response status="{$i}" xmlns:corona="http://marklogic.com/corona">
								<wadl:representation mediaType="application/json"/>
								{
									if ($action/rest:param[@name = 'outputFormat']) then
										<wadl:representation mediaType="text/xml" element="corona:error"/>
									else ()
								}
							</wadl:response>
					}
					
				</wadl:method>
			}</wadl:resource>
		}</wadl:resources>
	}

</wadl:application>
