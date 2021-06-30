*** Settings ***
Library     Collections
Library     RequestsLibrary

*** Variables ***
${URL}=  https://api.quotable.io

*** Test Cases ***

Quotes Endpoint HealthCheck
    [Documentation]  TC to ensure Endpoint state is healthy
    HEAD  ${URL}/quotes    expected_status=200


GET Quotes Endpoint
    [Documentation]  TC to validate response is in expected form
    ${response}=  GET  ${URL}/quotes    expected_status=200
    dictionary should contain item  ${response.json()}  count  20
    dictionary should contain item  ${response.json()}  page    1
    dictionary should contain key  ${response.json()}  count
    dictionary should contain key  ${response.json()}  totalCount
    dictionary should contain key  ${response.json()}  page
    dictionary should contain key  ${response.json()}  totalPages
    dictionary should contain key  ${response.json()}  lastItemIndex
    dictionary should contain key  ${response.json()}  results


GET Quotes Endpoint With Page Parameters Test
    [Documentation]  TC to check quotes endpoint with page parameter
    ${response}=  GET  ${URL}/quotes  params=page=3  expected_status=200
    dictionary should contain item  ${response.json()}  count  20
    dictionary should contain item  ${response.json()}  page    3


GET Quotes Endpoint With Tags Parameters Test
    [Documentation]  TC to check quotes endpoint with tags parameter
    ${response}=  GET  ${URL}/quotes  params=tags=technology  expected_status=200
    ${json}=  set variable  ${response.json()}
    :FOR    ${key}    IN    @{json['results']}
     \   list should contain value  ${key['tags']}  technology


GET Quotes Endpoint With Multiple Tags using OR Parameters Test
    [Documentation]  TC to check quotes endpoint multiple tags with OR parameter
    ${response}=  GET  ${URL}/quotes  params=tags=technology|wisdom  expected_status=200
    ${json}=  set variable  ${response.json()}
    @{tagsList}=    Create List
    :FOR    ${key}    IN    @{json['results']}
     \  append to list  ${tagsList}  ${key['tags']}
    :FOR    ${tags}    IN    @{tagsList}
    \   log  ${tags}
    \   Run Keyword unless  ${tags}==['wisdom'] or ${tags}==['technology']      pass execution  Tags Present


GET Quotes Endpoint With Multiple Tags using AND Parameters Test
    [Documentation]  TC to check quotes endpoint multiple tags with AND parameter
    ${response}=  GET  ${URL}/quotes  params=tags=friendship,famous-quotes  expected_status=200
    ${json}=  set variable  ${response.json()}
    @{tagsList}=    Create List
    :FOR    ${key}    IN    @{json['results']}
     \  append to list  ${tagsList}  ${key['tags']}
    log  ${tagsList}
    ${expectedList}=  create list  famous-quotes  friendship
    :FOR    ${tags}    IN    @{tagsList}
    \   pass execution if  ${tags}==${expectedList}  Tags List Matching


GET Quotes Endpoint With Tags AND Page Parameters Test
    [Documentation]  TC to check quotes endpoint multiple query parameter using Tags and Page
    ${response}=  GET  ${URL}/quotes  params=tags=technology&page=2   expected_status=200
    dictionary should contain item  ${response.json()}  page    2
    ${json}=  set variable  ${response.json()}
    @{tagsList}=    Create List
    :FOR    ${key}    IN    @{json['results']}
     \  append to list  ${tagsList}  ${key['tags'][0]}
    log  ${tagsList}
    list should contain value  ${tagsList}  technology



GET Quotes Endpoint With Author Parameters Test
    [Documentation]  TC to check quotes endpoint using Author query parameter
    ${response}=  GET  ${URL}/quotes  params=author=Henry%20Ford  expected_status=200
    ${json}=  set variable  ${response.json()}
    :FOR    ${key}    IN    @{json['results']}
     \   log  ${key['author']}
     \   should be equal as strings  ${key['author']}  Henry Ford


GET Quotes Endpoint With Multiple Author Parameters Test
    [Documentation]  TC to check quotes endpoint multiple Authors with OR parameter
    ${response}=  GET  ${URL}/quotes  params=author=Henry%20Ford|Laozi  expected_status=200
    ${json}=  set variable  ${response.json()}
    @{authorsList}=    Create List
    :FOR    ${key}    IN    @{json['results']}
     \  append to list  ${authorsList}  ${key['author']}
    :FOR    ${authors}    IN    @{authorsList}
    \   log  ${authors}
    \   Run Keyword unless  '${authors}'=='Henry Ford' or '${authors}'=='Laozi'      pass execution  Tags Present


GET Quotes Endpoint With Author AND Tags Parameters Test
    [Documentation]  TC to check quotes endpoint multiple query parameter using Authors and Tags
    ${response}=  GET  ${URL}/quotes  params=author=Francis+Bacon&tags=wisdom  expected_status=200
    ${json}=  set variable  ${response.json()}
    @{tagsList}=    Create List
    @{authorsList}=    Create List
    :FOR    ${key}    IN    @{json['results']}
     \  append to list  ${tagsList}  ${key['tags'][0]}
     \  append to list  ${authorsList}  ${key['author']}
    list should contain value  ${tagsList}  wisdom
    list should contain value  ${authorsList}  Francis Bacon


GET Quotes Endpoint With Author AND Tags AND Page Parameters Test
    [Documentation]  TC to check quotes endpoint multiple query parameter using Page, Authors and Tags
    ${response}=  GET  ${URL}/quotes  params=author=Francis+Bacon&tags=wisdom&page=1  expected_status=200
    ${json}=  set variable  ${response.json()}
    should be equal as strings  ${json['page']}  1
    @{tagsList}=    Create List
    @{authorsList}=    Create List
    :FOR    ${key}    IN    @{json['results']}
     \  append to list  ${tagsList}  ${key['tags'][0]}
     \  append to list  ${authorsList}  ${key['author']}
    list should contain value  ${tagsList}  wisdom
    list should contain value  ${authorsList}  Francis Bacon

GET Quotes Endpoint With Invalid Author Test
    [Documentation]  TC to check quotes endpoint invalid author parameters and validate response
    ${response}=  GET  ${URL}/quotes  params=author=156713    expected_status=200
    ${json}=  set variable  ${response.json()}
    should be empty  ${json['results']}
    ${response}=  GET  ${URL}/quotes  params=author=ajdh1893    expected_status=200
    ${json}=  set variable  ${response.json()}
    should be empty  ${json['results']}
    ${response}=  GET  ${URL}/quotes  params=author=@!*&@#    expected_status=200
    ${json}=  set variable  ${response.json()}
    should be empty  ${json['results']}


GET Quotes Endpoint With Invalid Tags Test
    [Documentation]  TC to check quotes endpoint invalid tags parameters and validate response
    ${response}=  GET  ${URL}/quotes  params=tags=156713    expected_status=200
    ${json}=  set variable  ${response.json()}
    should be empty  ${json['results']}
    ${response}=  GET  ${URL}/quotes  params=tags=ajdh1893    expected_status=200
    ${json}=  set variable  ${response.json()}
    should be empty  ${json['results']}
    ${response}=  GET  ${URL}/quotes  params=tags=@!*&@#    expected_status=200
    ${json}=  set variable  ${response.json()}
    should be empty  ${json['results']}

GET Quotes Endpoint With Invalid Page Parameters Test
    [Documentation]  TC to check quotes endpoint invalid page parameters and validate response
    ${response}=  GET  ${URL}/quotes  params=page=ajdh1893    expected_status=200
    ${json}=  set variable  ${response.json()}
    should not be empty  ${json['results']}
    should be equal as strings  ${json['count']}  20

    ${response}=  GET  ${URL}/quotes  params=page=@!*&@#    expected_status=200
    ${json}=  set variable  ${response.json()}
    should not be empty  ${json['results']}
    should be equal as strings  ${json['count']}  20
