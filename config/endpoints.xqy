xquery version "1.0-ml";

module namespace endpoints="http://marklogic.com/corona/endpoints";

import module namespace rest="http://marklogic.com/appservices/rest" at "/corona/lib/rest/rest.xqy";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare option xdmp:mapping "false";

declare variable $endpoints:ENDPOINTS as element(rest:options) :=
<options xmlns="http://marklogic.com/appservices/rest">
    <request uri="^/?$" endpoint="/config/index.xqy" user-params="allow">
        <http method="GET"/>
	</request>
	
    <request uri="^/explore/?$" endpoint="/config/explore.xqy" user-params="allow">
        <param name="page" as="integer" required="true" default="1"/>
        <http method="GET"/>
	</request>
	
    <!-- Manage documents in the database -->
    <request uri="^/store/?$" endpoint="/corona/store-get.xqy">
        <param name="uri" required="false"/>
        <param name="stringQuery" required="false"/>
        <param name="structuredQuery" required="false"/>
        <param name="extractPath" required="false"/>
        <param name="applyTransform" required="false"/>
        <param name="include" alias="include[]" repeatable="true" required="false" default="content"/>
        <param name="outputFormat" required="false" values="json|xml" default="json"/>
    </request>

    <request uri="^/store/?$" endpoint="/corona/store.xqy">
        <param name="uri" required="false"/>
        <param name="txid" required="false"/>

        <!--http method="GET">
            <param name="stringQuery" required="false"/>
            <param name="structuredQuery" required="false"/>
            <param name="extractPath" required="false"/>
            <param name="applyTransform" required="false"/>
            <param name="include" alias="include[]" repeatable="true" required="false" default="content"/>
			<param name="outputFormat" required="false" values="json|xml" default="json"/>
        </http-->
        <http method="POST">
            <param name="contentType" required="false" values="json|xml|text|binary"/>
            <param name="collection" alias="collection[]" repeatable="true" required="false"/>
            <param name="addCollection" alias="addCollection[]" repeatable="true" required="false"/>
            <param name="removeCollection" alias="removeCollection[]" repeatable="true" required="false"/>
            <param name="property" alias="property[]" repeatable="true" required="false"/>
            <param name="addProperty" alias="addProperty[]" repeatable="true" required="false"/>
            <param name="removeProperty" alias="removeProperty[]" repeatable="true" required="false"/>
            <param name="permission" alias="permission[]" repeatable="true" required="false"/>
            <param name="addPermission" alias="addPermission[]" repeatable="true" required="false"/>
            <param name="removePermission" alias="removePermission[]" repeatable="true" required="false"/>
            <param name="quality" required="false"/>
            <param name="contentForBinary" required="false"/>
            <param name="moveTo" required="false"/>
            <param name="extractMetadata" required="false" as="boolean" default="true"/>
            <param name="extractContent" required="false" as="boolean" default="true"/>
        </http>
        <http method="PUT">
            <param name="contentType" required="false" values="json|xml|text|binary"/>
            <param name="collection" alias="collection[]" repeatable="true" required="false"/>
            <param name="property" alias="property[]" repeatable="true" required="false"/>
            <param name="permission" alias="permission[]" repeatable="true" required="false"/>
            <param name="quality" required="false"/>
            <param name="contentForBinary" required="false"/>
            <param name="extractMetadata" required="false" as="boolean" default="true"/>
            <param name="extractContent" required="false" as="boolean" default="true"/>
        </http>
        <http method="DELETE">
            <param name="stringQuery" required="false"/>
            <param name="structuredQuery" required="false"/>
            <param name="bulkDelete" required="false" as="boolean" default="false"/>
            <param name="include" alias="include[]" repeatable="true" required="false"/>
            <param name="limit" required="false" as="integer"/>
			<param name="outputFormat" required="false" values="json|xml" default="json"/>
        </http>
    </request>

    <!-- Search endpoint -->
    <request uri="^/search/?$" endpoint="/corona/search.xqy">
        <param name="txid" required="false"/>
        <param name="stringQuery" required="false"/>
        <param name="structuredQuery" required="false"/>
        <param name="start" required="false" as="positiveInteger" default="1"/>
        <param name="length" required="false" as="positiveInteger" default="10"/>
        <param name="include" alias="include[]" repeatable="true" required="false" default="content"/>
        <param name="filtered" required="false" default="false" as="boolean"/>
        <param name="extractPath" required="false"/>
        <param name="applyTransform" required="false"/>
        <param name="collection" alias="collection[]" required="false" repeatable="true"/>
        <param name="underDirectory" required="false"/>
        <param name="inDirectory" required="false"/>
        <param name="outputFormat" required="false" values="json|xml" default="json"/>
        <http method="GET"/>
        <http method="POST"/>
    </request>

    <!-- Key value queryies -->
    <request uri="^/kvquery/?$" endpoint="/corona/kvquery.xqy">
        <param name="txid" required="false"/>
        <param name="key" required="false"/>
        <param name="element" required="false"/>
        <param name="attribute" required="false"/>
        <param name="property" required="false"/>
        <param name="value" required="false"/>
        <param name="start" required="false" as="positiveInteger" default="1"/>
        <param name="length" required="false" as="positiveInteger" default="1"/>
        <param name="include" alias="include[]" repeatable="true" required="false" default="content"/>
        <param name="extractPath" required="false"/>
        <param name="applyTransform" required="false"/>
        <param name="collection" alias="collection[]" required="false" repeatable="true"/>
        <param name="underDirectory" required="false"/>
        <param name="inDirectory" required="false"/>
        <param name="outputFormat" required="false" values="json|xml" default="json"/>
        <http method="GET"/>
        <http method="POST"/>
    </request>

    <!-- Facets -->
    <request uri="^/facet/([A-Za-z0-9_\-,]+)/?$" endpoint="/corona/facet.xqy">
        <param name="txid" required="false"/>
        <uri-param name="facets">$1</uri-param>
        <param name="stringQuery" required="false"/>
        <param name="structuredQuery" required="false"/>
        <param name="limit" as="integer" default="25" required="false"/>
        <param name="order" required="false" default="frequency" values="descending|ascending|frequency"/>
        <param name="frequency" required="false" default="document" values="document|key"/>
        <param name="includeAllValues" required="false" default="no" values="no|yes"/>
        <param name="collection" alias="collection[]" required="false" repeatable="true"/>
        <param name="underDirectory" required="false"/>
        <param name="inDirectory" required="false"/>
        <param name="outputFormat" required="false" values="json|xml" default="json"/>
        <http method="GET"/>
        <http method="POST"/>
    </request>

    <!-- Transaction management -->
    <request uri="^/transaction/(status|create|commit|rollback)/?$" endpoint="/corona/transaction.xqy">
        <uri-param name="action">$1</uri-param>
        <param name="txid" required="false"/>
        <param name="outputFormat" required="false" values="json|xml" default="json"/>
        <param name="timeLimit" required="false" as="decimal"/>
        <http method="GET"/>
        <http method="POST"/>
    </request>

    <!-- Named query management -->
    <request uri="^/namedquery/?$" endpoint="/corona/named-query.xqy">
        <param name="outputFormat" required="false" values="json|xml" default="json"/>
        <http method="GET">
            <param name="name" required="false"/>
            <param name="property" required="false"/>
            <param name="value" required="false"/>
            <param name="collection" alias="collection[]" required="false" repeatable="true"/>
            <param name="start" required="false" as="positiveInteger" default="1"/>
            <param name="length" required="false" as="positiveInteger" default="1"/>
        </http>
        <http method="POST">
            <param name="name" required="true"/>
            <param name="description" required="false"/>
            <param name="stringQuery" required="false"/>
            <param name="structuredQuery" required="false"/>
            <param name="collection" alias="collection[]" repeatable="true" required="false"/>
            <param name="property" alias="property[]" repeatable="true" required="false"/>
            <param name="permission" alias="permission[]" repeatable="true" required="false"/>
        </http>
        <http method="DELETE">
            <param name="name" required="true"/>
        </http>
    </request>


    <!-- Index management -->

    <request uri="^/manage/?$" endpoint="/corona/manage/summary.xqy" user-params="ignore">
        <http method="GET">
			<param name="outputFormat" required="false" values="json|xml" default="json"/>
		</http>
        <http method="DELETE"/>
    </request>

    <request uri="^/manage/?$" endpoint="/corona/manage/state.xqy">
        <http method="POST">
            <param name="isManaged" as="boolean" required="false"/>
        </http>
    </request>

    <request uri="^/manage/(ranges|range/([A-Za-z0-9_-]+))/?$" endpoint="/corona/manage/range.xqy">
        <uri-param name="name" as="string">$2</uri-param>
        <http method="GET">
			<param name="outputFormat" required="false" values="json|xml" default="json"/>
		</http>
        <http method="POST">
            <param name="key" required="false"/>
            <param name="element" required="false"/>
            <param name="attribute" required="false"/>
            <param name="type" required="true"/>
            <param name="collation" required="false"/>
        </http>
        <http method="DELETE"/>
    </request>

    <request uri="^/manage/(bucketedranges|bucketedrange/([A-Za-z0-9_-]+))/?$" endpoint="/corona/manage/bucketedrange.xqy">
        <uri-param name="name" as="string">$2</uri-param>
        <http method="GET">
			<param name="outputFormat" required="false" values="json|xml" default="json"/>
		</http>
        <http method="POST">
            <param name="key" required="false"/>
            <param name="element" required="false"/>
            <param name="attribute" required="false"/>
            <param name="type" required="true"/>
            <param name="buckets" required="false"/>
            <param name="bucketInterval" required="false"/>
            <param name="startingAt" required="false"/>
            <param name="stoppingAt" required="false"/>
            <param name="format" required="false"/>
            <param name="firstFormat" required="false"/>
            <param name="lastFormat" required="false"/>
            <param name="collation" required="false"/>
        </http>
        <http method="DELETE"/>
    </request>

    <request uri="^/manage/(geospatials|geospatial/([A-Za-z0-9_-]+))/?$" endpoint="/corona/manage/geo.xqy">
        <uri-param name="name" as="string">$2</uri-param>
        <http method="GET">
			<param name="outputFormat" required="false" values="json|xml" default="json"/>
		</http>
        <http method="POST">
            <param name="key" required="false"/>
            <param name="element" required="false"/>
            <param name="parentKey" required="false"/>
            <param name="parentElement" required="false"/>
            <param name="latKey" required="false"/>
            <param name="longKey" required="false"/>
            <param name="latElement" required="false"/>
            <param name="longElement" required="false"/>
            <param name="latAttribute" required="false"/>
            <param name="longAttribute" required="false"/>
            <param name="coordinateSystem" required="false" default="wgs84"/>
            <param name="comesFirst" required="false" default="latitude"/>
        </http>
        <http method="DELETE"/>
    </request>

    <request uri="^/manage/(namespaces|namespace/([^/]+))/?$" endpoint="/corona/manage/namespace.xqy">
        <uri-param name="prefix" as="string">$2</uri-param>
        <http method="GET">
			<param name="outputFormat" required="false" values="json|xml" default="json"/>
		</http>
        <http method="POST">
            <param name="uri" required="true"/>
        </http>
        <http method="DELETE"/>
    </request>

    <request uri="^/manage/(transformers|transformer/([^/]+))/?$" endpoint="/corona/manage/transformer.xqy">
        <uri-param name="name" as="string">$2</uri-param>
        <http method="GET">
			<param name="outputFormat" required="false" values="json|xml" default="json"/>
		</http>
        <http method="PUT"/>
        <http method="DELETE"/>
    </request>

    <request uri="^/manage/(place|places|place/([^/]+))/?$" endpoint="/corona/manage/places.xqy">
        <uri-param name="scope" as="string">$1</uri-param>
        <uri-param name="name" as="string">$2</uri-param>
        <http method="GET">
			<param name="outputFormat" required="false" values="json|xml" default="json"/>
		</http>
        <http method="PUT">
            <param name="mode" required="false" default="textContains"/>
        </http>
        <http method="POST">
            <param name="key" required="false"/>
            <param name="element" required="false"/>
            <param name="attribute" required="false"/>
            <param name="place" required="false"/>
            <param name="type" required="false" default="include"/>
            <param name="weight" required="false" default="1.0" as="decimal"/>
        </http>
        <http method="DELETE">
            <param name="key" required="false"/>
            <param name="element" required="false"/>
            <param name="attribute" required="false"/>
            <param name="place" required="false"/>
            <param name="type" required="false" default="include"/>
        </http>
    </request>

    <request uri="^/config/setup/?$" endpoint="/config/setup.xqy" user-params="allow">
        <http method="GET"/>
        <http method="POST"/>
    </request>

    <request uri="^/wadl/?$" endpoint="/config/wadl.xqy">
        <http method="GET"/>
    </request>

    <request uri="^/soapui/?$" endpoint="/config/soapui.xqy">
        <http method="GET"/>
    </request>

</options>;

declare function endpoints:options(
) as element(rest:options)
{
    $ENDPOINTS
};

declare function endpoints:request(
    $module as xs:string,
	$method as xs:string
) as element(rest:request)?
{
    ($ENDPOINTS/rest:request[@endpoint = $module][(empty(rest:http) and ($method eq 'GET')) or ($method eq rest:http/@method)])[1]
};
