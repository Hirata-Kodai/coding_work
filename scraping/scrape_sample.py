# selenium を使った web 上のコード
'''
Traceback (most recent call last):
  File "scrape_sample.py", line 9, in <module>
    driver = webdriver.Chrome()
  File "/home/hiratako/work/scraping/scraping_venv/lib/python3.8/site-packages/selenium/webdriver/chrome/webdriver.py", line 70, in __init__
    super(WebDriver, self).__init__(DesiredCapabilities.CHROME['browserName'], "goog",
  File "/home/hiratako/work/scraping/scraping_venv/lib/python3.8/site-packages/selenium/webdriver/chromium/webdriver.py", line 90, in __init__
    self.service.start()
  File "/home/hiratako/work/scraping/scraping_venv/lib/python3.8/site-packages/selenium/webdriver/common/service.py", line 81, in start
    raise WebDriverException(
selenium.common.exceptions.WebDriverException: Message: 'chromedriver' executable needs to be in PATH. Please see https://chromedriver.chromium.org/home
'''

from selenium import webdriver
import time
import csv
import datetime
from selenium.common.exceptions import NoSuchElementException

driver = webdriver.Chrome()
driver.get('https://baseball.yahoo.co.jp/npb/game/2021005340/score?index=0920300')
csv_date = datetime.datetime.today().strftime("%Y%m%d")
csv_file_name = "carp_data_" + csv_date + ".csv"
f = open(csv_file_name, "w", encoding="CP932", errors="ignore")

writer = csv.writer(f, lineterminator="\n")
csv_header = ["球数", "投手", "投", "打者", "打席", "球種", "球速", "結果", "コース", "一塁", "二塁", "三塁"]
writer.writerow(csv_header)

i = 0
item = 1
while True :
    i = i + 1
    time.sleep(5)
    try:
        elem_pitcher = driver.find_element_by_xpath('//*[@id="gm_rslt"]/tbody/tr/td[1]/a')
        elem_pitch = driver.find_element_by_xpath('//*[@id="gm_rslt"]/tbody/tr/td[2]')
        elem_batter = driver.find_element_by_xpath('//*[@id="gm_rslt"]/tbody/tr/td[3]/a')
        elem_bat = driver.find_element_by_xpath('//*[@id="gm_rslt"]/tbody/tr/td[4]')
        elem_1B = driver.find_elements_by_xpath('//*[@id="base1"]/span')
        elem_2B = driver.find_elements_by_xpath('//*[@id="base2"]/span')
        elem_3B = driver.find_elements_by_xpath('//*[@id="base3"]/span')
    except NoSuchElementException:
        pass
    except AttributeError:
        pass
    elems_tb = driver.find_elements_by_xpath('//*[@id="pitchesDetail"]/section[2]/table[3]/tbody/tr/td[3]')
    elems_tc = driver.find_elements_by_xpath('//*[@id="pitchesDetail"]/section[2]/table[3]/tbody/tr/td[4]')
    elems_te = driver.find_elements_by_xpath('//*[@id="pitchesDetail"]/section[2]/table[3]/tbody/tr/td[5]')
    elems_td = driver.find_elements_by_xpath('//*[@id="pitchesDetail"]/section[2]/table[1]/tbody/tr/td/div/span')
    for elem_tb, elem_tc, elem_te, elem_td in zip(elems_tb, elems_tc, elems_te, elems_td):
        print(elem_pitcher.text)
        print(elem_pitch.text)
        print(elem_batter.text)
        print(elem_bat.text)
        pitch_position = elem_td.get_attribute('style')
        print(pitch_position)
        print(elem_1B.text)
        print(elem_2B.text)
        print(elem_3B.text)
        csvlist = [str(item), elem_pitcher.text, elem_pitch.text, elem_batter.text, elem_bat.text, elem_tb.text, elem_tc.text, elem_te.text, elem_1B.text, elem_2B.text, elem_3B.text]
        writer.writerow(csvlist)
        item = item + 1
    next_link = driver.find_element_by_id('btn_next')
    driver.get(next_link.get_attribute('href'))
driver.close()
