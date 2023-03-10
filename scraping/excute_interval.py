import time
from requests_html import HTMLSession


def print_newest_result():
    session = HTMLSession()
    r = session.get('https://baseball.yahoo.co.jp/npb/game/2021005352/score')  # 最新の情報
    r_html = r.html
    elems_te = r_html.xpath('//*[@id="pitchesDetail"]/section[2]/table[3]/tbody/tr/td[5]')
    elems_batter = r_html.xpath('//*[@id="gm_rslt"]/tbody/tr/td[1]/a')
    elems_pitch = r_html.xpath('//*[@id="gm_rslt"]/tbody/tr/td[2]')
    elems_pitcher = r_html.xpath('//*[@id="gm_rslt"]/tbody/tr/td[3]/a')
    if len(elems_batter) > 0:
        print(elems_batter[0].text)
    if len(elems_pitcher) > 0:
        print(elems_pitcher[0].text)
    if len(elems_te) > 0:
        print(elems_te[-1].text)
    else:
        print([])

def main():
    while True:
        print_newest_result()
        time.sleep(10)


if __name__ == '__main__':
    main()
