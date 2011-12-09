xquery version "1.0-ml";

import module namespace endpoints="http://marklogic.com/corona/endpoints" at "endpoints.xqy";

declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare namespace rest="http://marklogic.com/appservices/rest";

declare option xdmp:mapping "false";

(: The following attempts to adhere to http://www.w3.org/Submission/wadl/, roughly tested with SOAPui 4.0 :)

<wadl:application xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://wadl.dev.java.net/2009/02 wadl.xsd"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:wadl="http://wadl.dev.java.net/2009/02">{
	
	(: TODO: all namespaces of elements being referenced in types. (none ever?) :)
	
		<wadl:resources base="http://{xdmp:get-request-header('HOST')}">{
		
			for $action in endpoints:options()/rest:request
			let $action-name := replace(substring-before(substring-after($action/@endpoint, '/'), '.xqy'), '[^\w\d\-]+', ':')
			(: TODO: more robust method of making a name (necessary?) :)
			return
			
			<wadl:resource id="{$action-name}" path="{replace(translate($action/@uri, '^$', ''), '/\?$', '')}">{
			
				(: TODO: path is derived from uri pattern, should be expanded to all allowed variants.. (can that be calculated?) :)
			
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
					
					<wadl:response status="200">
						<wadl:representation mediaType="text/xml" element="xs:anyType"/>
						<wadl:representation mediaType="plain/text" />
					</wadl:response>
					
					{
						(: Check returned mime for JSON.. :)
						(: TODO: add responses like 400 (bad param), 401 (auth), 404 (not found) (500 too?) :)
					}
					
				</wadl:method>
			}</wadl:resource>
		}</wadl:resources>
	}

</wadl:application>
