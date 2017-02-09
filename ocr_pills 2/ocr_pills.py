import requests
import json
import editdistance
import re

def ocr_space_file(filename, overlay=False, api_key='helloworld', language='eng'):
    """ OCR.space API request with local file.
        Python3.5 - not tested on 2.7
    :param filename: Your file path & name.
    :param overlay: Is OCR.space overlay required in your response.
                    Defaults to False.
    :param api_key: OCR.space API key.
                    Defaults to 'helloworld'.
    :param language: Language code to be used in OCR.
                    List of available language codes can be found on https://ocr.space/OCRAPI
                    Defaults to 'en'.
    :return: Result in JSON format.
    """

    payload = {'isOverlayRequired': overlay,
               'apikey': api_key,
               'language': language,
               }
    with open(filename, 'rb') as f:
        r = requests.post('https://api.ocr.space/parse/image',
                          files={filename: f},
                          data=payload,
                          )
    return r.content.decode()

def string_eq(str1, str2):

	dist = editdistance.eval(str1, str2)

	if len(str1) <= 2 and len(str2) <= 2:
		return dist == 0
	else:
		return dist < 3

def get_amount_to_take(str1):

	prog = re.compile('(((\d)-(\d))|((\d)+)) (TABLET|CAPSULE)(S){0,1}')
	m = re.search(prog, str1)

	if m is None:
		return None
	else:
		return m.group(0)

def get_delivery_method(str1):

	prog = re.compile('(BY MOUTH)|(BY DICK)|(SWALLOW (\w)+)')
	m = re.search(prog, str1)

	if m is None:
		return None
	else:
		return m.group(0)

def get_freq_to_take(str1):

	prog = re.compile('(EVERY (((\d)+ (\w)+)|((\w)+)))|((\w)+ DAILY)|(AT (\w)+)')
	m = re.search(prog, str1)

	if m is None:
		return None
	else:
		return m.group(0)

f = open('drugs_processed.txt', 'r')
drug_list = list(map(lambda s : s.rstrip().upper(), f.readlines()))

def find_drug_name_match(str1):

	for drug_name in drug_list:
		if drug_name == str1:
			return drug_name

	for drug_name in drug_list:
		if string_eq(drug_name, str1):
			return drug_name

	return None

def get_drug_name(str1):
	str_split = str1.split()

	for word in str_split:
		result = find_drug_name_match(word)
		if result:
			return result

	return None

# Use examples:
if 1:
	test_file_JSON = ocr_space_file(filename='test7.jpg', language='eng', api_key='0ad729224588957')

	test_file_parsed_results = json.loads(test_file_JSON)['ParsedResults'][0]['ParsedText']

	test_file_parsed_results = test_file_parsed_results.replace('\n','').replace('\r','')
else:
	#test_file_parsed_results = 'i OVAL WHITE TABLET 1• GG 936 May Cause Drowsiness Or Dizziness Take This Medicine With A Snack Or Small Meal If Stomach Upset Occurs Swallow Whole. Do Not Chew Or Crush. TAB NO (2 '

	#test_file_parsed_results = 'LAMOTRIGINE MFG TEVA - Generic for LAMICTAL TAKE 2 TABLETS BY MOUTH EVERY DAY Rx 0252633-1 1423 QTY 60 FILLS BEFORE 03/23/17 E FRANKLIN ST, CHAPEL HILL, NC 21514 (919) 918-3801 '

	test_file_parsed_results = 'DATE 01/19/17 PRAVASTATIN 40MG TABLETS MFG TEVA TAKE 1 TABLET BY MOUTH EVERY NIGHT AT BEDTIME AS DIRECTED RX 0576689-12413 90 REFILLS - DR. AUTH REQUIRED *zeuoL RD, KENOSHA, WI 53143 652-2396 USE BEFORE 01/19/18 STEPHEN FEUERBACH, MD YYY/JLSiJLS/ IJJW ONLY '

	#test_file_parsed_results = 'DIAZEPAM MFG MYLAN TAKE 1 TABLET BY MOUTH EVERY 12 HOURS FOR MUSCLE S 6-079 30 NO REFILLS - DR. AUTH REQUIRE: WEEGZEELL 118TH AVE, PLEASANT PRAIRIE, W (262) 857-9484'

test_file_parsed_results = ' '.join(test_file_parsed_results.split())
test_file_parsed_results = test_file_parsed_results.upper()

print("'" + test_file_parsed_results + "'")

parsed_result = {}
parsed_result['Name'] = get_drug_name(test_file_parsed_results)
parsed_result['Amount'] = get_amount_to_take(test_file_parsed_results)
parsed_result['Frequency'] = get_freq_to_take(test_file_parsed_results)
parsed_result['Delivery'] = get_delivery_method(test_file_parsed_results)

print(parsed_result)

#Name of Medication
#Amount to take
#How to take it
#How often to take it
#Purpose
