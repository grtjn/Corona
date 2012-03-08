xquery version "1.0-ml";

import module namespace endpoints="http://marklogic.com/corona/endpoints" at "endpoints.xqy";
import module namespace functx="http://www.functx.com" at "/MarkLogic/functx/functx-1.0-nodoc-2007-01.xqy";

import module namespace config="http://marklogic.com/corona/index-config" at "../corona/lib/index-config.xqy";
import module namespace manage="http://marklogic.com/corona/manage" at "../corona/lib/manage.xqy";

declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare namespace rest="http://marklogic.com/appservices/rest";
declare namespace json="http://marklogic.com/json";
declare namespace wadl="http://wadl.dev.java.net/2009/02";

declare option xdmp:mapping "false";

let $wadl := xdmp:invoke("wadl.xqy")
let $endpoint := data($wadl/wadl:resources/@base)
let $projname := 'Corona WADL'
return
	<con:soapui-project
		name="{ $projname }"
		resourceRoot=""
		soapui-version="4.0.1"
		xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
		xmlns:con="http://eviware.com/soapui/config">
		
		<con:settings/>
		
		<con:interface
			xsi:type="con:RestService"
			wadlVersion="http://wadl.dev.java.net/2009/02"
			name="{ $projname }"
			type="rest"
			definitionUrl="{ $endpoint }/wadl"
			basePath="">
			
			<con:settings/>
			<con:definitionCache/>
			<con:endpoints>
				<con:endpoint>{$endpoint}</con:endpoint>
			</con:endpoints>
			
			{
				for $resource in $wadl/wadl:resources/wadl:resource
				let $resourcepath := (data($resource/@path)[. != ''], '/')[1]
				return (
					<con:resource name="{ data($resource/@id) }" path="{ $resourcepath }">
						<con:settings/>
						<con:parameters/>
						{
							for $action in $resource/wadl:method
							return (
								<con:method name="{ data($action/@id) }" method="{ data($action/@name) }">
									<con:settings/>
									<con:parameters>
										{
											for $param in $action/wadl:param
											return
												<con:parameter required="{ not(xs:boolean($param/@required)) }">
													<con:name>{ data($param/@name) }</con:name>
													<con:value xsi:nil="true"/>
													<con:style>{ fn:upper-case($param/@style) }</con:style>
													<con:type xmlns:xs="http://www.w3.org/2001/XMLSchema">{ data($param/@type) }</con:type>
													<con:default xsi:nil="true"/>
												</con:parameter>
										}
									</con:parameters>
									
									{
										for $response in $action/wadl:response
										for $representation in $response/wadl:representation
										return (
											<con:representation type="RESPONSE" id="">
												<con:mediaType>{ data($representation/@mediaType) }</con:mediaType>
												<con:status>{ data($response/@status) }</con:status>
												{
													if (exists($representation/@element)) then
														<con:element xmlns:xs="http://www.w3.org/2001/XMLSchema">{ data($representation/@element) }</con:element>
													else ()
												}
												<con:description xsi:nil="true"/>
											</con:representation>
										)
									}
									
									<con:request name="Request 1">
										<con:settings/>
										<con:endpoint>{ $endpoint }</con:endpoint>
										<con:parameters/>
									</con:request>
								</con:method>
							)
						}
					</con:resource>
				)
			}
		</con:interface>
		
		<con:testSuite name="{ $projname } Test Suite">
			<con:description>Test Suite generated for REST Service [{ $projname }]</con:description>
			<con:settings/>
			<con:runType>SEQUENTIAL</con:runType>
			
			{
				for $resource in $wadl/wadl:resources/wadl:resource
				let $resourcepath := (data($resource/@path)[. != ''], '/')[1]
				where not(contains($resourcepath, '/soapui'))
				return (
					for $action in $resource/wadl:method
					let $hasrequiredparams := exists($action/wadl:param[@required = 'true'])
					return (
						<con:testCase
							failOnError="true"
							failTestCaseOnErrors="true"
							keepSession="false"
							maxResults="0"
							name="{ $resourcepath } TestCase"
							searchProperties="true"
							id="{xdmp:random()}">

							<con:description>Test Case generated for REST Resource [{ $resourcepath }-{ data($action/@name) }]</con:description>
							<con:settings/>
							
							{
								for $response in $action/wadl:response[1]
								for $representation in $response/wadl:representation
								return (
									<con:testStep type="restrequest" name="{ data($action/@id) }-{ data($response/@status) }-{ data($representation/@mediaType) }">
										<con:settings/>
										
										<con:config
											service="{ $projname }"
											resourcePath="{ $resourcepath }"
											methodName="{ data($action/@id) }"
											xsi:type="con:RestRequestStep">
											
												<con:restRequest name="{ $resourcepath }" mediaType="{ data($representation/@mediaType) }">
													<con:settings/>
													<con:endpoint>{ $endpoint }</con:endpoint>
													<con:request/>
													<con:parameters/>
													
													<con:assertion type="Simple NotContains">
														<con:configuration>
															<token>INTERNAL-ERROR</token>
															<ignoreCase>true</ignoreCase>
															<useRegEx>false</useRegEx>
														</con:configuration>
													</con:assertion>
													
													<con:assertion type="Simple NotContains">
														<con:configuration>
															<token>INCORRECTURI</token>
															<ignoreCase>true</ignoreCase>
															<useRegEx>false</useRegEx>
														</con:configuration>
													</con:assertion>
													
													<con:assertion type="Simple NotContains">
														<con:configuration>
															<token>UNSUPPORTEDMETHOD</token>
															<ignoreCase>true</ignoreCase>
															<useRegEx>false</useRegEx>
														</con:configuration>
													</con:assertion>
													
													<con:assertion type="Valid HTTP Status Codes" name="Valid HTTP Status Codes">
														<con:configuration>
															<codes>{ data($response/@status) }</codes>
														</con:configuration>
													</con:assertion>
													
												</con:restRequest>
										</con:config>
									</con:testStep>,
									
									(: if any params required, check for Missing Param error :)
									if ($hasrequiredparams)
									then
										<con:testStep type="restrequest" name="{ data($action/@id) }-{ data($response/@status) }-{ data($representation/@mediaType) }">
											<con:settings/>
											
											<con:config
												service="{ $projname }"
												resourcePath="{ $resourcepath }"
												methodName="{ data($action/@id) }"
												xsi:type="con:RestRequestStep">
												
												<con:restRequest name="{ $resourcepath }" mediaType="{ data($representation/@mediaType) }">
													<con:settings/>
													<con:endpoint>{ $endpoint }</con:endpoint>
													<con:request/>
													<con:parameters/>
													
													<con:assertion type="Simple NotContains">
														<con:configuration>
															<token>INTERNAL-ERROR</token>
															<ignoreCase>true</ignoreCase>
															<useRegEx>false</useRegEx>
														</con:configuration>
													</con:assertion>
													
													<con:assertion type="Simple NotContains">
														<con:configuration>
															<token>INCORRECTURI</token>
															<ignoreCase>true</ignoreCase>
															<useRegEx>false</useRegEx>
														</con:configuration>
													</con:assertion>
													
													<con:assertion type="Simple NotContains">
														<con:configuration>
															<token>UNSUPPORTEDMETHOD</token>
															<ignoreCase>true</ignoreCase>
															<useRegEx>false</useRegEx>
														</con:configuration>
													</con:assertion>
													
													<con:assertion type="Valid HTTP Status Codes" name="Valid HTTP Status Codes">
														<con:configuration>
															<codes>400</codes>
														</con:configuration>
													</con:assertion>
													
													<con:assertion type="Simple NotContains">
														<con:configuration>
															<token>REQUIREDPARAM</token>
															<ignoreCase>true</ignoreCase>
															<useRegEx>false</useRegEx>
														</con:configuration>
													</con:assertion>
												</con:restRequest>
											</con:config>
										</con:testStep>
									else ()
								)
							}
						</con:testCase>
					)
				)
			}
		</con:testSuite>
	</con:soapui-project>
