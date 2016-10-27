#!/usr/bin/python
# -*- coding: utf-8 -*-

from datetime import datetime
from iso8601 import parse_date
import os
import urllib
from robot.libraries.BuiltIn import BuiltIn

def subtract_from_time(date_time, subtr_min, subtr_sec):
    sub = datetime.strptime(date_time, "%d/%m/%Y %H:%M:%S")
    return str(sub).replace(' ', 'T') + '.000000+03:00'


def convert_datetime_to_opentender_format(isodate):
    iso_dt = parse_date(isodate)
    day_string = iso_dt.strftime("%d/%m/%Y %H:%M")
    return day_string


def convert_string_from_dict_opentender(string):
    return {
        u"грн": u"UAH",
        u"True": u"1",
        u"False": u"0",
        u'Код CAV': u'CAV',
        u'з урахуванням ПДВ': True,
        u'без урахуванням ПДВ': False,
        u'ОЧIКУВАННЯ ПРОПОЗИЦIЙ': u'active.tendering',
        u'Перiод уточнень': u'active.enquires',
        u'АУКЦIОН': u'active.auction',
        u'КВАЛIФIКАЦIЯ ПЕРЕМОЖЦЯ': u'active.qualification',
    }.get(string, string)


def adapt_procuringEntity(role_name, tender_data):
    if role_name == 'tender_owner':
        tender_data['data']['procuringEntity']['name'] = u"Опа-Опа"
    return tender_data


def adapt_view_data(value, field_name):
    if field_name == 'value.amount':
        value = float(value.split(' ')[0])
    elif field_name == 'value.currency':
        value = value.split(' ')[1]
    elif field_name == 'value.valueAddedTaxIncluded':
        value = ' '.join(value.split(' ')[2:])
    elif field_name == 'minimalStep.amount':
        value = float(value.split(' ')[0])
    elif 'unit.name' in field_name:
        value = value.split(' ')[1]
    elif 'quantity' in field_name:
        value = float(value.split(' ')[0])
    elif 'questions' in field_name and '.date' in field_name:
        value = subtract_from_time(value.split(' - ')[0], 0, 0)
    elif 'Date' in field_name:
        value = subtract_from_time(value, 0, 0)
    return convert_string_from_dict_opentender(value)


def adapt_view_item_data(value, field_name):
    if 'unit.name' in field_name:
        value = ' '.join(value.split(' ')[1:])
    elif 'quantity' in field_name:
        value = float(value.split(' ')[0])
    return convert_string_from_dict_opentender(value)


def get_upload_file_path():
    return os.path.join(os.getcwd(), 'src/robot_tests.broker.opentender/testFileForUpload.txt')