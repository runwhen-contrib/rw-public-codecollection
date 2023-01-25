*** Settings ***
Documentation     Basic Hello-World TaskSet
Library           RW.Core
Suite Setup       Suite Initialization

*** Keywords ***
Suite Initialization
    ${REQUIRED_VALUE}=    RW.Core.Import User Variable    REQUIRED_VALUE
    ...    type=string
    ...    description=A required form value.
    ...    pattern=\w*
    ...    example=My example required value.
    ...    default=Default required value.
    ...    required=True
    ${OPTIONAL_VALUE}=    RW.Core.Import User Variable    OPTIONAL_VALUE
    ...    type=string
    ...    description=A optional form value.
    ...    pattern=\w*
    ...    example=My example optional value.
    ...    default=Default optional value.
    ...    required=False
    ${IMPLICIT_VALUE}=    RW.Core.Import User Variable    IMPLICIT_VALUE
    ...    type=string
    ...    description=A implicit optional form value.
    ...    pattern=\w*
    ...    example=My example implicit optional value.
    ...    default=Default implicit optional value.
    Set Suite Variable    ${REQUIRED_VALUE}    ${REQUIRED_VALUE}
    Set Suite Variable    ${OPTIONAL_VALUE}    ${OPTIONAL_VALUE}
    Set Suite Variable    ${IMPLICIT_VALUE}    ${IMPLICIT_VALUE}

*** Tasks ***
Hello World
    Log    Hello World

Add One String To Report
    Add To Report    A String To Be Added To The Report

Add Form Values To Report
    Add To Report    Required string: ${REQUIRED_VALUE}
    Add To Report    Explicit Optional string: ${OPTIONAL_VALUE}
    Add To Report    Implicit Optional string: ${IMPLICIT_VALUE}
