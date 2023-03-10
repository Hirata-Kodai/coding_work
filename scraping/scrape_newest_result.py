import time
import argparse
from requests_html import HTMLSession
from playsound import playsound
import win32com.client as wincl
from dataclasses import dataclass
from typing import List


@dataclass
class GameData:
    home_name: str
    home_score: int
    visitor_name: str
    visitor_score: int
    pitcher: str
    batter: str
    first_base: bool
    second_base: bool
    third_base: bool
    result_match: List


class Scraper:
    """スクレイピングして GameData クラスのインスタンスを返すクラス"""
    def __init__(self, url: str):
        self.url = url

    def scrape(self) -> GameData:
        session = HTMLSession()
        r = session.get(self.url)
        r_html = r.html
        home_name: str = r_html.xpath("")
        home_score: int = r_html.xpath("")
        visitor_name: str = r_html.xpath("")
        visitor_score: int = r_html.xpath("")
        pitcher: str = r_html.xpath("")
        batter: str = r_html.xpath("")
        first_base: bool = r_html.xpath("")
        second_base: bool = r_html.xpath("")
        third_base: bool = r_html.xpath("")
        result_match: List = r_html.xpath("")

        pitcher_lst = r_html.xpath('//*[@id="gm_rslt"]/tbody/tr/td[1]')
        batter_lst = r_html.xpath('//*[@id="gm_rslt"]/tbody/tr/td[3]')
        if pitcher_lst:
            pitcher = pitcher_lst[0].text
        if batter_lst:
            batter = batter_lst[0].text
        return GameData(
            home_name,
            home_score,
            visitor_name,
            visitor_score,
            pitcher,
            batter,
            first_base,
            second_base,
            third_base,
            result_match
        )



class Reporter:
    def __init__(self, scraper):
        "データの更新を確認し、テキスト出力や音声出力するクラス"
        self.scraper: Scraper = scraper
        self.current_gameData = self.scraper.scrape()

    def check_change_of_score(self):
        pass

    def check_change_of_base(self):
        pass

    def check_change_of_inning(self):
        pass

    def check_change_of_batter(self):
        pass

    def check_change_of_pitcher(self):
        pass

    def check_change_of_ballcount(self):
        pass


def is_updated(result_tr_list, newest_result_tr_list):
    '''
    結果の更新があったかを判定する関数
    pram: result_tr_list: List[<Element 'tr' >] １状態前の結果リスト
    pram: newest_result_tr_list: List[<Element 'tr' >] 現在の状態の結果リスト
    res: bool
    '''
    return len(result_tr_list) != len(newest_result_tr_list)


def get_and_print_newest_result(result_tr_list, url: str):
    session = HTMLSession()
    url = url  # 最新の情報
    # url = 'https://baseball.yahoo.co.jp/npb/game/2021005340/score?index=0920300'  # 固定の情報
    r = session.get(url)

    r_html = r.html
    pitcher_lst = r_html.xpath('//*[@id="gm_rslt"]/tbody/tr/td[1]')
    batter_lst = r_html.xpath('//*[@id="gm_rslt"]/tbody/tr/td[3]')
    if pitcher_lst:
        pitcher = pitcher_lst[0].text
    if batter_lst:
        batter = batter_lst[0].text
    newest_result_tr_list = r_html.xpath('//*[@id="pitchesDetail"]/section[2]/table[3]/tbody/tr')
    if is_updated(result_tr_list, newest_result_tr_list) and len(newest_result_tr_list) >= 1:
        print(f'{pitcher} v.s. {batter}')
        result = newest_result_tr_list[0].text.split('\n')[2:]
        msg = ' '.join(result)
        # result = newest_result_tr_list[0].text.split('[')[0].split('\n')[:-1][-1]
        print(msg)
        print()
        result_tr_list = newest_result_tr_list
        playsound('./XFL84QD-catch-baseball.mp3')
        voice = wincl.Dispatch("SAPI.SpVoice")
        voice.Speak(msg)
    return newest_result_tr_list

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('URL', type=str, help='URL of the game.')
    args = ap.parse_args()

    result_tr_list = []
    INTERVAL = 10
    while True:
        result_tr_list = get_and_print_newest_result(result_tr_list, args.URL)
        time.sleep(INTERVAL)


if __name__ == '__main__':
    main()
