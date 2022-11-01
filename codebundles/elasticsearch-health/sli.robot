*** Settings ***
Documentation     Check an Elasticsearch cluster's health
Metadata          Name    elasticsearch-health
Metadata          Type    SLI
Metadata          Author    Vui Le
Force Tags        Elasticsearch    cluster    health
Library           RW.Core
Library           RW.Elasticsearch

*** Tasks ***
Check Elasticsearch Cluster Health
    Import User Variable    SERVICE_DESCR
    Import User Variable    ELASTICSEARCH_URL
#    ${res} =    RW.Elasticsearch.Get Health Status    ${ELASTICSEARCH_URL}    verbose=True
    ${res} =    RW.Elasticsearch.Get Shard Health Status    ${ELASTICSEARCH_URL}    index=.geoip_databases    verbose=True
    Info Log    ${res}
    Console Log    HTTP status code: ${res.status_code} (${res.reason})
    Console Log    Elasticsearch cluster health status: ${res.cluster_status}
    Console Log    ${res.content}
    Push Metric    ${res.ok}    descr=${SERVICE_DESCR}
    ...    status_code=${res.status_code}
    ...    cluster_name=${res.cluster_name}
    ...    cluster_status=${res.cluster_status}
    ...    ok_status=${res.ok_status}
