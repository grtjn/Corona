xquery version "1.0-ml";

import module namespace endpoints="http://marklogic.com/corona/endpoints" at "endpoints.xqy";

declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare namespace rest="http://marklogic.com/appservices/rest";

declare option xdmp:mapping "false";

<wadl:application xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://wadl.dev.java.net/2009/02 wadl.xsd"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:wadl="http://wadl.dev.java.net/2009/02"
	xmlns:x="http://www.w3.org/1999/xhtml">

	{
		<wadl:resources base="/">{
			for $action in endpoints:options()/rest:request
			let $action-name := replace(substring-before(substring-after($action/@endpoint, '/'), '.xqy'), '[^\w\d\-]+', ':')
			return
			<wadl:resource id="{$action-name}" path="{replace(translate($action/@uri, '^$', ''), '/\?$', '')}">{
				let $methods :=
					if ($action/rest:http) then
						$action/rest:http
					else
						<method method="GET"/>
				for $method in $methods
				return
				<wadl:method id="{$action-name}:{$method/@method}" name="{fn:upper-case($method/@method)}">
					<wadl:request>{
						for $param in ($action/rest:param, $method/rest:param)
						let $type := (fn:translate($param/@type, '?*+', ''), 'xs:string')[. != ''][1]
						let $type :=
							if (fn:matches($type, '^element\(\)$')) then
								"xs:any"
							else if (fn:matches($type, '^element\((.+)\)$')) then
								fn:replace($type, '^element\((.+)\)$', '$1')
							else
								$type
						let $required := fn:string(fn:not(fn:matches($param/@type, '(\?|\*)')))
						return
						<wadl:param name="{$param/@name}" type="{$type}" style="query" required="{$required}"/>
					}</wadl:request>
					<wadl:response status="200">
						<wadl:representation mediaType="plain/text" element="xs:anyType"/>
					</wadl:response>
				</wadl:method>
			}</wadl:resource>
		}</wadl:resources>
	}

</wadl:application>
