*** Settings ***
Library  Selenium2Screenshots
Library  String
Library  DateTime
Library  opentender_service.py

*** Variables ***


*** Keywords ***

Підготувати дані для оголошення тендера
  [Arguments]  ${username}  ${tender_data}
  ${tender_data}=  adapt_procuringEntity  ${tender_data}
  [return]  ${tender_data}

Підготувати клієнт для користувача
  [Arguments]  ${username}
  Open Browser  ${USERS.users['${username}'].homepage}  ${USERS.users['${username}'].browser}  alias=${username}
  Set Window Size  @{USERS.users['${username}'].size}
  Set Window Position  @{USERS.users['${username}'].position}
  Run Keyword If  'Viewer' not in '${username}'  Login  ${username}

Login
  [Arguments]  ${username}
  Wait Until Page Contains Element  id=loginform-username  10
  Input text  id=loginform-username  ${USERS.users['${username}'].login}
  Input text  id=loginform-password  ${USERS.users['${username}'].password}
  Click Element  name=login-button

###############################################################################################################
######################################    СТВОРЕННЯ ТЕНДЕРУ    ################################################
###############################################################################################################

Створити тендер
  [Arguments]  ${username}  ${tender_data} 
  ${items}=  Get From Dictionary  ${tender_data.data}  items
  Switch Browser  ${username}
  Reload Page
  Wait Until Page Contains Element  xpath=//a[@href="/buyer/tenders"]  10
  Click Element  xpath=//a[@href="http://prozorroc.byustudio.in.ua/tenders"]
  Click Element  xpath=//a[contains(@href,"/buyer/tender/create")]
  Conv And Select From List By Value  name=Tender[value][valueAddedTaxIncluded]  ${tender_data.data.value.valueAddedTaxIncluded}
  ConvToStr And Input Text  name=Tender[value][amount]  ${tender_data.data.value.amount}
  ConvToStr And Input Text  name=Tender[minimalStep][amount]  ${tender_data.data.minimalStep.amount}
  Select From List By Value  name=Tender[value][currency]  ${tender_data.data.value.currency}
  Input text  name=Tender[title]  ${tender_data.data.title}
  Input text  name=Tender[description]  ${tender_data.data.description}
  Input Date  name=Tender[enquiryPeriod][endDate]  ${tender_data.data.enquiryPeriod.endDate}  
  Input Date  name=Tender[tenderPeriod][startDate]  ${tender_data.data.tenderPeriod.startDate}   
  Input Date  name=Tender[tenderPeriod][endDate]  ${tender_data.data.tenderPeriod.endDate}   
  Додати предмет  ${items[0]}  0
  Click Element  xpath= //button[@class="btn btn-default btn_submit_form"]
  Wait Until Page Contains Element  xpath=//span[@tid="tenderID"]  10
  ${tender_uaid}=  Get Text  xpath=//span[@tid="tenderID"]
  [return]  ${tender_uaid}

Додати предмет
  [Arguments]  ${item}  ${index}
  ${index}=  Convert To Integer  ${index}
  Input text  name=Tender[items][${index}][description]  ${item.description}
  Input text  name=Tender[items][${index}][quantity]  ${item.quantity}
  Select From List By Value  name=Tender[items][${index}][unit][code]  ${item.unit.code}
  Click Element  name=Tender[items][${index}][classification][description]
  Wait Until Element Is Visible  id=search
  Input text  id=search  ${item.classification.description}
  Wait Until Page Contains  ${item.classification.description}
  Click Element  xpath=//span[contains(text(),'${item.classification.description}')]
  Click Element  id=btn-ok
  Wait Until Element Is Not Visible  xpath=//div[@class="modal-backdrop fade"]  10
  Click Element  name=Tender[items][${index}][additionalClassifications][0][description]
  Input text  id=search  ${item.additionalClassifications[0].description}
  Wait Until Page Contains  ${item.additionalClassifications[0].description}
  Click Element  xpath=//div[@id="${item.additionalClassifications[0].id}"]/div/span[contains(text(), '${item.additionalClassifications[0].description}')]
  Click Element  id=btn-ok
  Wait Until Element Is Not Visible  xpath=//div[@class="modal-backdrop fade"]
  Input text  name=Tender[items][${index}][deliveryAddress][countryName]  ${item.deliveryAddress.countryName}
  Input text  name=Tender[items][${index}][deliveryAddress][region]  ${item.deliveryAddress.region}
  Input text  name=Tender[items][${index}][deliveryAddress][locality]  ${item.deliveryAddress.locality}
  Input text  name=Tender[items][${index}][deliveryAddress][streetAddress]  ${item.deliveryAddress.streetAddress}
  Input text  name=Tender[items][${index}][deliveryAddress][postalCode]  ${item.deliveryAddress.postalCode}
  Input Date  name=Tender[items][${index}][deliveryDate][endDate]  ${item.deliveryDate.endDate}
  Select From List By Value  name=Tender[procuringEntity][contactPoint][fio]  24

Завантажити документ
  [Arguments]  ${username}  ${filepath}  ${tender_uaid}
  Switch Browser  ${username}
  Go to  ${USERS.users['${username}'].homepage}
  Click Element  xpath=//button[@tid="tender_dropdown"]
  Click Element  xpath=//a[@href="/buyer/tenders"]
  Click Element  xpath=//span[text()='${tender_uaid}']/ancestor::div[@class="thumbnail"]/descendant::a
  Click Element  xpath=//a[contains(text(),'Редагувати')]
  Choose File  name=FileUpload[file]  ${filepath}
  Click Button  xpath=//button[@class="btn btn-default btn_submit_form"]

Пошук тендера по ідентифікатору
  [Arguments]  ${username}  ${tender_uaid}
  Switch browser  ${username}
  Go To  http://prozorroc.byustudio.in.ua/tenders/
  Input text  name=TendersSearch[tender_cbd_id]  ${tender_uaid}
  Click Element  xpath=//button[@tid="search"]
  Wait Until Keyword Succeeds  30x  400ms  Перейти на сторінку з інформацією про тендер  ${tender_uaid}

Перейти на сторінку з інформацією про тендер
  [Arguments]  ${tender_uaid}
  Wait Until Element Contains  xpath=//div[@class="summary"]/b[2]  1
  Click Element  xpath=//span[text()='${tender_uaid}']/ancestor::div[@class="thumbnail"]/descendant::a
  Wait Until Element Is Visible  xpath=//span[@tid="tenderID"]

Оновити сторінку з тендером
  [Arguments]  ${username}  ${tenderID}
  Reload Page

Внести зміни в тендер
  [Arguments]  ${username}  ${tenderID}  ${field_name}  ${field_value}
  opentender.Пошук тендера по ідентифікатору  ${username}  ${tenderID}
  Click Element  xpath=//a[contains(text(),'Редагувати')]
  Input text  name=Tender[${field_name}]  ${field_value}
  Click Element  xpath=//button[@class="btn btn-default btn_submit_form"]
  Wait Until Page Contains  ${field_value}  30

###############################################################################################################
############################################    ПИТАННЯ    ####################################################
###############################################################################################################

Задати питання
  [Arguments]  ${username}  ${tender_uaid}  ${question}
  opentender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Click Element  xpath=//a[contains(@href, '/questions')]
  Input Text  name=Question[title]  ${question.data.title}
  Input Text  name=Question[description]  ${question.data.description}
  Click Element  name=question_submit
  Wait Until Page Contains  ${question.data.description}
  
Відповісти на питання
  [Arguments]  ${username}  ${tenderID}  ${question}  ${answer_data}  ${question_id}
  opentender.Пошук тендера по ідентифікатору  ${username}  ${tenderID}
  Click Element  xpath=//a[contains(@href, '/questions')]
  Wait Until Element Is Visible  name=Tender[0][answer]
  Input text  name=Tender[0][answer]  ${answer_data.data.answer}
  Click Element  name=answer_question_submit
  Wait Until Page Contains  ${answer_data.data.answer}  30
  
###############################################################################################################
###################################    ВІДОБРАЖЕННЯ ІНФОРМАЦІЇ    #############################################
###############################################################################################################

Отримати інформацію із тендера
  [Arguments]  ${username}  ${field_name}
  ${red}=  Evaluate  "\\033[1;31m"
  Run Keyword If  '${field_name}' == 'status'  Click Element   xpath=//a[text()='Інформація про закупівлю']
  ${value}=  Run Keyword If  'unit.code' in '${field_name}'  Log To Console   ${red}\n\t\t\t Це поле не виводиться на opentender
  ...  ELSE IF  'unit' in '${field_name}'  Get Text  xpath=//*[@tid="items.quantity"]
  ...  ELSE IF  'deliveryLocation' in '${field_name}'  Log To Console  ${red}\n\t\t\t Це поле не виводиться на opentender
  ...  ELSE IF  'items' in '${field_name}'  Get Text  xpath=//*[@tid="${field_name.replace('[0]', '')}"]
  ...  ELSE IF  'questions' in '${field_name}'  opentender.Отримати інформацію із запитання  ${field_name}
  ...  ELSE IF  'value' in '${field_name}'  Get Text  xpath=//*[@tid="value.amount"]
  ...  ELSE  Get Text  xpath=//*[@tid="${field_name}"]
  ${value}=  adapt_view_data  ${value}  ${field_name}
  [return]  ${value}
  
Отримати інформацію із запитання
  [Arguments]  ${field_name}
  Click Element  xpath=//a[contains(@href, '/questions')]
  ${value}=  Get Text  xpath=//*[@tid="${field_name.replace('[0]', '')}"]
  [return]  ${value}
  
###############################################################################################################
#######################################    ПОДАННЯ ПРОПОЗИЦІЙ    ##############################################
###############################################################################################################  
  
Подати цінову пропозицію
  [Arguments]  ${username}  ${tender_uaid}  ${bid}
  Capture Page Screenshot
  opentender.Пошук тендера по ідентифікатору   ${username}  ${tender_uaid}
  ConvToStr And Input Text  xpath=//input[contains(@name, '[value][amount]')]  ${bid.data.value.amount}
  Click Element  xpath=//button[contains(text(), 'Вiдправити')]
  Wait Until Element Is Visible  xpath=//div[contains(@class, 'alert-success')]
  
Скасувати цінову пропозицію
  [Arguments]  ${username}  ${tender_uaid}  ${bid}
  opentender.Пошук тендера по ідентифікатору   ${username}  ${tender_uaid}
  Execute Javascript  window.confirm = function(msg) { return true; }
  Click Element  xpath=//button[@name="delete_bids"]
  
Змінити цінову пропозицію
  [Arguments]  ${username}  ${tender_uaid}  ${fieldname}  ${fieldvalue}
  opentender.Пошук тендера по ідентифікатору   ${username}  ${tender_uaid}
  ConvToStr And Input Text  xpath=//input[contains(@name, '[value][amount]')]  ${fieldvalue}
  Click Element  xpath=//button[contains(text(), 'Вiдправити')]
  Wait Until Element Is Visible  xpath=//div[contains(@class, 'alert-success')]
  
Завантажити документ в ставку
  [Arguments]  ${username}  ${path}  ${tender_uaid}  ${doc_type}=documents
  opentender.Пошук тендера по ідентифікатору   ${username}  ${tender_uaid}
  Choose File  name=FileUpload[file]  ${path} 
  Click Element  xpath=//button[contains(text(), 'Вiдправити')]
  Wait Until Element Is Visible  xpath=//div[contains(@class, 'alert-success')]
  
Змінити документ в ставці
  [Arguments]  ${username}  ${path}  ${bidid}  ${docid}
  Wait Until Keyword Succeeds   30 x   10 s   Дочекатися вивантаження файлу до ЦБД
  Execute Javascript  window.confirm = function(msg) { return true; }
  Choose File  xpath=//div[contains(text(), 'Замiнити')]/form/input  ${path}
  Click Element  xpath=//button[contains(text(), 'Вiдправити')]
  Wait Until Element Is Visible  xpath=//div[contains(@class, 'alert-success')]
  
###############################################################################################################
##############################################    АУКЦІОН    ##################################################
###############################################################################################################

Отримати посилання на аукціон для глядача
  [Arguments]  ${username}  ${tender_uaid}  ${lot_id}=${Empty}
  opentender.Пошук тендера по ідентифікатору   ${username}  ${tender_uaid}
  ${auction_url}  Get Element Attribute  xpath=//a[contains(text(), 'Аукцiон')]@href
  [return]  ${auction_url}
  
Отримати посилання на аукціон для учасника
  [Arguments]  ${username}  ${tender_uaid}
  opentender.Пошук тендера по ідентифікатору   ${username}  ${tender_uaid}
  ${auction_url}  Get Element Attribute  xpath=//a[contains(text(), 'Аукцiон')]@href
  [return]  ${auction_url}
  
###############################################################################################################
  
ConvToStr And Input Text
  [Arguments]  ${elem_locator}  ${smth_to_input}
  ${smth_to_input}=  Convert To String  ${smth_to_input}
  Input Text  ${elem_locator}  ${smth_to_input}
  
Conv And Select From List By Value
  [Arguments]  ${elem_locator}  ${smth_to_select}
  ${smth_to_select}=  Convert To String  ${smth_to_select}
  ${smth_to_select}=  convert_string_from_dict_opentender  ${smth_to_select}
  Select From List By Value  ${elem_locator}  ${smth_to_select}
  
Input Date
  [Arguments]  ${elem_locator}  ${date}
  ${date}=  convert_datetime_to_opentender_format  ${date}
  Input Text  ${elem_locator}  ${date}

Дочекатися вивантаження файлу до ЦБД
  Reload Page
  Wait Until Element Is Visible   xpath=//div[contains(text(), 'Замiнити')]
  
Ввести текст
  [Arguments]  ${locator}  ${text}
  Wait Until Element Is Visible  ${locator}
  Input Text  ${locator}  ${text}